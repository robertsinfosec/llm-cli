<#
.SYNOPSIS
Interact with Ollama models from the command line using PowerShell.

.DESCRIPTION
Sends a prompt (and optional piped context) to an Ollama API endpoint.
Handles environment variables for configuration and command-line overrides.

.PARAMETER Prompt
The main prompt text to send to the model.

.PARAMETER Model
Specifies the model to use. Overrides the LLM_MODEL environment variable.
Default is determined by $env:LLM_MODEL or 'qwen3:4b'.

.PARAMETER Host
Specifies the Ollama host URL. Overrides the LLM_HOST environment variable.
Default is determined by $env:LLM_HOST or 'http://127.0.0.1:11434'.

.PARAMETER Raw
If specified, outputs the raw JSON response from Ollama instead of the parsed text.

.INPUTS
System.String. Text piped into the script will be used as context before the prompt.

.OUTPUTS
System.String. The processed response from the LLM or the raw JSON response if -Raw is specified.

.EXAMPLE
PS> llm "Explain the concept of recursion."
# Sends the prompt to the default model and host.

.EXAMPLE
PS> Get-Content code.py | llm "Review this Python code for potential bugs."
# Pipes the content of code.py as context before the prompt.

.EXAMPLE
PS> Get-ChildItem | llm -Model "mistral:latest" "Describe these files."
# Pipes the output of Get-ChildItem as context and uses the 'mistral:latest' model.

.EXAMPLE
PS> llm "What is the capital of France?" -Raw
# Sends the prompt and outputs the full raw JSON response from the API.

.NOTES
Requires PowerShell 7+ for optimal compatibility with Invoke-RestMethod features.
Ensure the Ollama service is running and accessible at the specified host.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Prompt = "",

    [Parameter(Mandatory=$false)]
    [string]$Model = ($env:LLM_MODEL -if $null -or ($env:LLM_MODEL.Trim() -eq '') then 'qwen3:4b' else $env:LLM_MODEL),

    [Parameter(Mandatory=$false)]
    [string]$Host = ($env:LLM_HOST -if $null -or ($env:LLM_HOST.Trim() -eq '') then 'http://127.0.0.1:11434' else $env:LLM_HOST),

    [Parameter(Mandatory=$false)]
    [switch]$Raw
)

# Strict mode equivalent
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Input Handling ---

# Read piped input if present
$pipedInput = ""
if ($MyInvocation.ExpectingInput) {
    # Read all piped input as a single string, limit size
    $pipedBytes = [System.Text.Encoding]::UTF8.GetBytes(($Input | Out-String))
    $maxInputSize = 100000 # ~100KB limit
    if ($pipedBytes.Length -gt $maxInputSize) {
        Write-Warning "Piped input truncated at $($maxInputSize / 1KB)KB."
        $pipedInput = [System.Text.Encoding]::UTF8.GetString($pipedBytes, 0, $maxInputSize)
    } else {
        $pipedInput = [System.Text.Encoding]::UTF8.GetString($pipedBytes)
    }
    $pipedInput = $pipedInput.Trim()
}

# --- Prompt Construction ---

$finalPrompt = ""
if (($pipedInput -ne "") -and ($Prompt -ne "")) {
    $finalPrompt = "Context:`n$pipedInput`n`nPrompt: $Prompt"
} elseif ($pipedInput -ne "") {
    $finalPrompt = $pipedInput
} elseif ($Prompt -ne "") {
    $finalPrompt = $Prompt
} else {
    Write-Error "No prompt provided via argument or stdin."
    # Display simplified help on error
    Write-Host "Usage: llm [-Model <string>] [-Host <string>] [-Raw] [<Prompt>]"
    Write-Host "Use 'Get-Help llm -Full' for detailed help."
    exit 1
}

# Check prompt size (approximate)
$maxPromptSize = 100000 # ~100KB limit (apply to final combined prompt)
$promptBytes = [System.Text.Encoding]::UTF8.GetBytes($finalPrompt)
if ($promptBytes.Length -gt $maxPromptSize) {
    Write-Error "Final prompt exceeds size limit ($($promptBytes.Length) > $maxPromptSize bytes)."
    Write-Host "Suggestion: Reduce prompt length or piped input size."
    exit 1
fi

# --- Payload Generation ---

$payload = @{
    model = $Model
    stream = $false
    prompt = $finalPrompt
} | ConvertTo-Json -Depth 3

# --- API Call ---

$apiUrl = "$($Host.TrimEnd('/'))/api/generate"
$rawResponse = $null
$responseObject = $null

try {
    Write-Verbose "Sending request to $apiUrl with model $Model"
    $rawResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType 'application/json' -Body $payload -TimeoutSec 300 # 5 minute timeout
    # Invoke-RestMethod automatically parses JSON if Content-Type is correct
    $responseObject = $rawResponse
    Write-Verbose "Received response from API."
} catch [System.Net.WebException] {
    $statusCode = 0
    if ($_.Exception.Response -ne $null) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        $errorBody = ""
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $errorStream.Close()
        } catch {
            $errorBody = "(Failed to read error response body)"
        }
        Write-Error "API request failed with status code $statusCode. URL: $apiUrl"
        Write-Error "Response Body: $errorBody"
    } else {
        Write-Error "API request failed: $($_.Exception.Message). URL: $apiUrl"
        Write-Error "Check if the Ollama service is running and accessible at '$Host'."
    }
    exit 1
} catch {
    Write-Error "An unexpected error occurred during the API call: $($_.Exception.Message)"
    exit 1
}

# --- Response Processing ---

if ($Raw.IsPresent) {
    # Output the raw JSON object as JSON string
    Write-Output ($responseObject | ConvertTo-Json -Depth 5)
    exit 0
}

# Extract the 'response' field
$parsedResponse = $responseObject | Select-Object -ExpandProperty response -ErrorAction SilentlyContinue

if ($null -eq $parsedResponse -or $parsedResponse -eq "") {
    Write-Warning "Ollama returned an empty response."
    Write-Host "Raw response object:"
    Write-Output ($responseObject | ConvertTo-Json -Depth 5)
    exit 2 # Different exit code for empty response
}

# --- Output Cleaning ---
# Remove the <think>...</think> block and the following blank line.
# Also trim leading/trailing whitespace from the final output.

$lines = $parsedResponse -split '(\r?\n)'
$cleanedLines = New-Object System.Collections.Generic.List[string]
$inThinkBlock = $false
$skipNextBlank = $false

foreach ($line in $lines) {
    if ($line -match '^<think>$') {
        $inThinkBlock = $true
        continue
    }
    if ($line -match '^</think>$') {
        $inThinkBlock = $false
        $skipNextBlank = $true
        continue
    }
    if ($skipNextBlank -and $line -match '^\s*$') {
        $skipNextBlank = $false
        continue
    }
    if (-not $inThinkBlock) {
        $cleanedLines.Add($line)
    }
}

$cleanedResponse = ($cleanedLines -join '').Trim()

Write-Output $cleanedResponse

exit 0
