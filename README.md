# llm-cli: Command-Line LLM Interaction

A versatile command-line interface designed to facilitate seamless interaction with local or remote Ollama-compatible Large Language Model (LLM) APIs directly from your terminal. This toolset provides both a Bash script (`llm.sh`) and a PowerShell script (`llm.ps1`) to cater to 
different shell environments, offering a consistent experience across platforms.

> [!TIP]
> For a comprehensive blog post about how to use these scripts, visit:
>  
> > **[https://robertsinfosec.com/posts/llm-powered-cli/](https://robertsinfosec.com/posts/llm-powered-cli/)**

## Overview

The primary goal of `llm-cli` is to make querying LLMs as intuitive as using standard command-line utilities like `grep`, `sed`, or `awk`. You can provide prompts directly as arguments or pipe text content (like source code, logs, or command output) into the script to serve as context for your prompt.

Both scripts (`llm.sh` and `llm.ps1`) are engineered for robustness, featuring:

*   **Flexible Input:** Accepts prompts via command-line arguments and/or standard input (stdin).
*   **Configurability:** Utilizes environment variables for default settings (API host, model) which can be overridden by command-line options.
*   **Error Handling:** Implements checks for dependencies (like `jq` for the bash script) and provides informative error messages for API issues or invalid input.
*   **Output Control:** Allows fetching the raw JSON response from the API or the processed, cleaned-up text output.
*   **Platform Support:** Provides functional parity between the Bash (`llm.sh`) and PowerShell (`llm.ps1`) versions.

## Core Functionality

1.  **Construct Prompt:** Combines any text received via standard input (piped content) with the prompt text provided as a command-line argument. If only one is provided, that is used as the final prompt.
2.  **API Request:** Packages the final prompt and the selected model name into a JSON payload.
3.  **Send to Ollama:** Transmits the payload to the configured Ollama API endpoint (e.g., `http://127.0.0.1:11434/api/generate`).
4.  **Process Response:** Parses the JSON response from the API.
5.  **Clean Output:** By default, it removes specific meta-tags (like `<think>...</think>` blocks sometimes included by models) and trims whitespace.
6.  **Display Result:** Prints the final, cleaned-up text response to standard output (stdout).

## Configuration

You can configure the default behavior using the following environment variables:

*   `LLM_HOST`: Specifies the base URL of the Ollama API endpoint.
    *   **Default:** `http://127.0.0.1:11434`
    *   **Example (Bash):** `export LLM_HOST="http://ollama.example.com:11434"`
    *   **Example (PowerShell):** `$env:LLM_HOST = "http://ollama.example.com:11434"`
*   `LLM_MODEL`: Defines the default model to be used for the requests.
      * **Default:** `qwen3:4b`  
        > **Note:** The examples below use `mistral:latest` to demonstrate overriding the default value.  
      * **Example (Bash):** `export LLM_MODEL="mistral:latest"`
      * **Example (PowerShell):** `$env:LLM_MODEL = "mistral:latest"`

These defaults can be overridden on a per-command basis using the `-H` (`--host`) / `-Host` and `-m` (`--model`) / `-Model` command-line options.

## Usage Examples

Here are various ways to utilize the `llm-cli` scripts. Examples are shown for Bash (`llm` assuming `llm.sh` is in your PATH or aliased) and PowerShell (`llm` assuming `llm.ps1` is accessible).

**1. Simple Prompt (Argument Only)**

*   **Bash:**
    ```bash
    llm "Translate 'hello world' to French."
    ```
*   **PowerShell:**
    ```powershell
    llm "Translate 'hello world' to French."
    ```

**2. Using Piped Input as Context (Beginning of Chain)**

Provide context via stdin, followed by the specific prompt as an argument.

*   **Bash:**
    ```bash
    cat ./src/llm.sh | llm "Summarize this bash script."
    ```
*   **PowerShell:**
    ```powershell
    Get-Content ./src/llm.ps1 | llm "Summarize this PowerShell script."
    ```

**3. Using Piped Input as the Sole Prompt (No Argument)**

If no prompt argument is given, the entire piped input becomes the prompt.

*   **Bash:**
    ```bash
    echo "Explain the concept of standard input and standard output in Linux." | llm
    ```
*   **PowerShell:**
    ```powershell
    "Explain the concept of pipelines in PowerShell." | llm
    ```

**4. Using `llm-cli` in the Middle or End of a Chain**

Process the output of another command.

*   **Bash:**
    ```bash
    # Get disk usage, then ask the LLM to explain the largest directories
    du -h /var/log | sort -hr | head -n 10 | llm "Explain what these log directories are typically used for."
    ```
*   **PowerShell:**
    ```powershell
    # Get the 5 newest files, then ask the LLM to describe them
    Get-ChildItem | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 5 | Out-String | llm "Describe these files based on their names and types."
    ```

**5. Overriding Configuration with Options**

Specify a different model or host for a single query.

*   **Bash:**
    ```bash
    llm --model "llama3:latest" --host "http://192.168.1.100:11434" "Why is the sky blue?"
    ```
*   **PowerShell:**
    ```powershell
    llm -Model "llama3:latest" -Host "http://192.168.1.100:11434" "Why is the sky blue?"
    ```

**6. Getting the Raw API Response**

Retrieve the complete JSON output from the Ollama API.

*   **Bash:**
    ```bash
    llm --raw "Give me a short JSON example."
    ```
*   **PowerShell:**
    ```powershell
    llm -Raw "Give me a short JSON example."
    ```

## Dependencies

*   **`llm.sh` (Bash):** Requires `curl` and `jq` to be installed and available in the system's PATH.
*   **`llm.ps1` (PowerShell):** Requires PowerShell version 5.1 or later (7+ recommended). `Invoke-RestMethod` and `ConvertTo-Json` cmdlets are used.

## Error Handling

The scripts include checks for:
*   Missing dependencies.
*   Failure to connect to the `LLM_HOST`.
*   Non-successful HTTP status codes from the API.
*   Errors during JSON parsing (both request generation and response parsing).
*   Missing prompt input (neither argument nor stdin provided).
*   Excessively large input prompts (to prevent potential issues).

Error messages are directed to standard error (stderr), and the scripts exit with non-zero status codes upon failure.
