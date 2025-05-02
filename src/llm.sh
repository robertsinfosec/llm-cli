#!/usr/bin/env bash
# llm-cli: Interact with Ollama models from the command line.

# Strict mode
set -euo pipefail

# Default configuration (can be overridden by environment variables)
: "${LLM_HOST:=http://127.0.0.1:11434}" # Default to localhost
: "${LLM_MODEL:=qwen3:4b}"

# --- Dependencies Check ---
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' command not found. Please install jq." >&2
  exit 1
fi
if ! command -v curl &> /dev/null; then
  echo "Error: 'curl' command not found. Please install curl." >&2
  exit 1
fi

# --- Functions ---

# Display help message
show_help() {
  cat <<EOF
Usage:
  llm [OPTIONS] "your prompt here"
  cat context.txt | llm [OPTIONS] "your prompt here"
  echo "some prompt" | llm [OPTIONS]
  some_program | llm [OPTIONS]

Description:
  Sends a prompt (and optional piped context) to an Ollama API endpoint.

Options:
  -h, --help     Show this help message and exit.
  -m, --model    Specify the model to use (overrides LLM_MODEL env var).
                 Default: $LLM_MODEL
  -H, --host     Specify the Ollama host URL (overrides LLM_HOST env var).
                 Default: $LLM_HOST
  --raw          Output the raw JSON response from Ollama.

Environment Variables:
  LLM_HOST       Ollama host URL (default: $LLM_HOST)
  LLM_MODEL      Ollama model name (default: $LLM_MODEL)

Examples:
  llm "Explain the concept of recursion."
  cat code.py | llm "Review this Python code for potential bugs."
  ls -l | llm --model "mistral:latest" "Describe these files."
EOF
}

# Cleanup function to remove temporary files
cleanup() {
  rm -f "$tmp_prompt_file" "$tmp_payload_file"
}

# --- Argument Parsing ---

prompt_arg=""
output_raw=false

# Use getopt for robust argument parsing
TEMP=$(getopt -o 'hm:H:' --long 'help,model:,host:,raw' -n 'llm' -- "$@")
if [ $? -ne 0 ]; then
  echo "Error parsing options." >&2
  show_help >&2
  exit 1
fi
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
    '-h'|'--help')
      show_help
      exit 0
      ;;
    '-m'|'--model')
      LLM_MODEL="$2"
      shift 2
      ;;
    '-H'|'--host')
      LLM_HOST="$2"
      shift 2
      ;;
    '--raw')
      output_raw=true
      shift 1
      ;;
    '--')
      shift
      break
      ;;
    *)
      echo "Internal error!" >&2
      exit 1
      ;;
  esac
done

# The remaining argument is the prompt
prompt_arg="${1:-}" # Use default empty string if no prompt arg

# --- Input Handling ---

# Read piped input if present (non-blocking)
piped_input=""
if [ ! -t 0 ]; then
  # Read up to max_prompt_size bytes to prevent excessive memory usage
  piped_input=$(head -c 100000)
  # Check if more data was available (indicates truncation)
  if IFS= read -r -t 0.1; then
      echo "Warning: Piped input truncated at 100KB." >&2
  fi
fi

# --- Prompt Construction ---

final_prompt=""
if [[ -n "$piped_input" && -n "$prompt_arg" ]]; then
  # Combine context and prompt
  final_prompt=$(printf "Context:\n%s\n\nPrompt: %s" "$piped_input" "$prompt_arg")
elif [[ -n "$piped_input" ]]; then
  # Use piped input as the only prompt
  final_prompt="$piped_input"
elif [[ -n "$prompt_arg" ]]; then
  # Use argument as the only prompt
  final_prompt="$prompt_arg"
else
  # No input provided
  echo "Error: No prompt provided via argument or stdin." >&2
  show_help >&2
  exit 1
fi

# --- Temporary Files & Cleanup ---

# Create temporary files securely
tmp_prompt_file=$(mktemp)
tmp_payload_file=$(mktemp)

# Ensure cleanup runs on script exit or interruption
trap cleanup EXIT INT TERM

# Save final_prompt content to the temp file
printf "%s" "$final_prompt" > "$tmp_prompt_file"

# Check prompt size (using the file size)
prompt_size=$(wc -c < "$tmp_prompt_file")
max_prompt_size=100000 # ~100KB limit

if (( prompt_size > max_prompt_size )); then
  echo "Error: Final prompt exceeds size limit (${prompt_size} > ${max_prompt_size} bytes)." >&2
  echo "Suggestion: Reduce prompt length or piped input size." >&2
  exit 1
fi

# --- Payload Generation ---

# Use jq to create the JSON payload, reading the prompt from the file
if ! jq -n --arg model "$LLM_MODEL" --arg prompt "$(cat "$tmp_prompt_file")" \
  '{model: $model, stream: false, prompt: $prompt}' > "$tmp_payload_file"; then
  echo "Error: Failed to generate JSON payload using jq." >&2
  exit 1
fi

# Validate payload file creation
if [[ ! -s "$tmp_payload_file" ]]; then
  echo "Error: Generated JSON payload file is empty." >&2
  exit 1
fi

# --- API Call ---

# Send the payload to Ollama using curl
# Use --fail to exit with an error if the HTTP request fails (non-2xx response)
# Use --silent to suppress progress meter but show errors
# Use --show-error to show curl errors even with --silent
raw_response=$(curl --silent --show-error --fail \
  -X POST "$LLM_HOST/api/generate" \
  -H "Content-Type: application/json" \
  --data-binary "@$tmp_payload_file")

# Check curl exit code
curl_exit_code=$?
if [ $curl_exit_code -ne 0 ]; then
    echo "Error: curl command failed with exit code $curl_exit_code." >&2
    # raw_response might contain error details from curl (--show-error)
    echo "curl output: $raw_response" >&2
    exit 1
fi


# --- Response Processing ---

if [[ "$output_raw" == true ]]; then
  printf "%s\n" "$raw_response"
  exit 0 # Success, raw output requested
fi

# Parse the response using jq
# Use 'e' flag to exit if jq encounters an error
# Provide a default empty string if .response is null or missing
parsed_response=$(echo "$raw_response" | jq -e -r '.response // ""')

# Check jq exit code
jq_exit_code=$?
if [ $jq_exit_code -ne 0 ]; then
    echo "Error: jq failed to parse the Ollama response (exit code $jq_exit_code)." >&2
    echo "Raw response: $raw_response" >&2
    exit 1
fi


if [[ -z "$parsed_response" ]]; then
  echo "Warning: Ollama returned an empty response." >&2
  echo "Raw response: $raw_response" >&2
  # Exit with a different code to indicate empty response vs error
  exit 2
fi

# --- Output Cleaning ---
# Remove the <think>...</think> block and the following blank line.
# Also trim leading/trailing whitespace from the final output.
cleaned_response=$(printf "%s\n" "$parsed_response" | \
  awk 'BEGIN{p=1} /^<think>$/{p=0;next} /^<\/think>$/{p=0; skip_next=1; next} skip_next==1 && /^$/{skip_next=0; p=1; next} p' | \
  sed 's/^[ \t]*//;s/[ \t]*$//')

printf "%s\n" "$cleaned_response"

# Exit with success
exit 0