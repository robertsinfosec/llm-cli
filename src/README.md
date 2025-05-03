# `llm-cli` Usage Inspiration

This directory contains the core `llm.sh` (Bash) and `llm.ps1` (PowerShell) scripts. Below are various examples demonstrating how you can integrate LLM capabilities directly into your command-line workflows across different domains. Adapt these patterns to your specific needs!

*(Assume `llm` is an alias or link to either `llm.sh` or `llm.ps1`)*

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Cybersecurity \& Compliance](#cybersecurity--compliance)
  - [Analyzing Security Logs and Events](#analyzing-security-logs-and-events)
  - [Reviewing Security Configurations](#reviewing-security-configurations)
  - [Generating Security Documentation](#generating-security-documentation)
- [Platform Engineering \& DevOps](#platform-engineering--devops)
  - [Analyzing Infrastructure Code](#analyzing-infrastructure-code)
  - [Troubleshooting Deployments](#troubleshooting-deployments)
  - [Generating Infrastructure Code](#generating-infrastructure-code)
  - [Optimizing CI/CD Pipelines](#optimizing-cicd-pipelines)
- [Software Development](#software-development)
  - [Understanding Code](#understanding-code)
  - [Code Generation and Examples](#code-generation-and-examples)
  - [Code Refactoring and Improvement](#code-refactoring-and-improvement)
- [System Administration](#system-administration)
  - [Analyzing System Logs and Configurations](#analyzing-system-logs-and-configurations)
  - [Generating System Commands and Scripts](#generating-system-commands-and-scripts)
  - [Troubleshooting System Issues](#troubleshooting-system-issues)
  - [Formatting System Reports](#formatting-system-reports)
- [Cloud Engineering (AWS, Azure, GCP)](#cloud-engineering-aws-azure-gcp)
  - [Understanding Cloud Resources](#understanding-cloud-resources)
  - [Generating Cloud CLI Commands](#generating-cloud-cli-commands)
  - [Analyzing Cloud Costs](#analyzing-cloud-costs)
  - [Generating Infrastructure as Code](#generating-infrastructure-as-code)
  - [Troubleshooting Cloud Connectivity](#troubleshooting-cloud-connectivity)


## Cybersecurity & Compliance

This section covers how security professionals can leverage LLM capabilities for analyzing security data, reviewing configurations, generating compliance artifacts, and enhancing security operations.

### Analyzing Security Logs and Events

These examples help identify suspicious patterns, potential threats, and Indicators of Compromise (IOCs) in various log formats.

#### Bash

```bash
# Analyze firewall rules for security risks
sudo iptables -L -n -v | llm "Analyze these iptables rules for potential \
    security risks or overly permissive entries. Summarize findings in \
    Markdown." | glow -p

# Analyze login attempts for brute-force patterns
grep 'Failed password' /var/log/auth.log | tail -n 20 | llm "Explain these failed \
    login attempts. Are there patterns suggesting a brute-force attack?"

# Advanced alias for comprehensive log analysis
alias sec-analyselog='cat "$1" | llm "Act as a meticulous Senior Security Analyst \
    specializing in threat hunting. Analyze the provided log entries for potential \
    Indicators of Compromise (IOCs), suspicious patterns (e.g., brute-force, C2 \
    communication, data exfiltration), or anomalies compared to standard baseline \
    activity. Provide a concise summary in Markdown, listing findings by severity \
    (Critical, High, Medium, Low) and recommend immediate containment or \
    investigation steps."'
```

#### PowerShell

```powershell
# Analyze cloud security alerts from a JSON file
function Explain-CloudAlert ($AlertJsonPath) {
    Get-Content $AlertJsonPath | llm "Act as a Cloud Security Operations Center `
        (CSOC) analyst. Interpret this cloud security alert JSON data from `
        ($AlertJsonPath). Explain the alert's meaning, potential impact, affected `
        resources, and recommended triage/investigation steps based on standard `
        operating procedures. Summarize in clear, actionable language."
}
```

### Reviewing Security Configurations

Tools to assess the security of configuration files, helping identify misconfigurations, vulnerabilities, and deviations from best practices.

#### Bash

```bash
# Check Nginx config for security issues
cat /etc/nginx/nginx.conf | llm "Identify potential security misconfigurations \
    in this Nginx config. Focus on SSL/TLS settings, headers, and access controls. \
    Output findings as a list." | grep 'SSL/TLS'

# Review CloudFormation/Terraform for insecure defaults
cat template.yaml | llm "Review this CloudFormation template for insecure \
configurations, like public S3 buckets or unrestricted security groups."

# Advanced alias for reviewing firewall rules
alias sec-reviewfw='cat "$1" | llm "Act as a Principal Network Security Engineer \
    obsessed with least privilege. Review the provided firewall rules (e.g., iptables, \
    nftables, cloud security group output). Identify overly permissive rules, \
    potential bypasses, redundant rules, and deviations from security best \
    practices. Output a Markdown report with findings categorized and specific \
    remediation advice."'
```

#### PowerShell

```powershell
# Analyze scripts for security vulnerabilities
function Check-ScriptSecurity ($ScriptPath) {
    Get-Content $ScriptPath | llm "Act as a paranoid Application Security Engineer. `
        Perform a static analysis review of this script ($ScriptPath). Identify `
        potential security vulnerabilities such as injection flaws (SQLi, Command `
        Injection), insecure handling of secrets, improper input validation, weak `
        cryptography, or logic errors that could be exploited. List findings by `
        OWASP category and severity (Critical/High/Medium/Low) with remediation `
        guidance."
}
```

### Generating Security Documentation

Tools for creating various security artifacts such as policies, compliance reports, and security awareness materials.

#### Bash

```bash
# Generate a password policy
llm "Generate a short password policy requiring 12+ chars, upper, lower, 
    number, symbol." > password_policy.txt

# Advanced alias for generating compliance evidence
alias sec-compliance='cat "$1" | llm "Act as a Compliance Officer preparing for an \
    audit (e.g., SOC2, ISO27001). Based on the provided input data (e.g., \
    configuration snippet, log excerpt), generate a concise narrative explaining how \
    this demonstrates compliance with a specific control objective (you may need to \
    specify the objective in the provided input or prompt). Focus on clarity, accuracy, \
    and direct relevance to audit requirements."'
```

#### PowerShell

```powershell
# Generate phishing awareness materials
function Generate-PhishingExample ($Topic) {
    llm "Act as a Security Awareness Trainer. Create a short, realistic example `
        of a phishing email based on the topic '$Topic'. Include common red flags `
        that users should look out for. Format as plain text suitable for an `
        awareness bulletin."
}
```

## Platform Engineering & DevOps

This section covers how platform engineers and DevOps practitioners can use LLMs to analyze infrastructure code, troubleshoot deployments, optimize configurations, and automate common tasks.

### Analyzing Infrastructure Code

Tools for reviewing and explaining Kubernetes manifests, Terraform plans, and other infrastructure definitions.

#### Bash

```bash
# Explain Kubernetes resource YAML
kubectl get deployment my-app -o yaml | llm "Explain this Kubernetes Deployment \
    YAML in simple terms. What does it deploy and how?"

# Advanced alias for reviewing Kubernetes manifests
alias k8s-review='cat "$1" | llm "Act as a principal platform engineer focused on \
    Kubernetes reliability, security, and cost-efficiency. Review the provided manifest \
    for potential issues, deviations from best practices (e.g., missing resource \
    limits/requests, lack of probes, insecure security contexts, improper labels, \
    inefficient scheduling), and suggest improvements. Format as Markdown with clear \
    sections for each finding and suggested code changes."'

# Advanced alias for explaining Terraform plans
alias tf-explain='cat "$1" | llm "Act as a senior DevOps engineer specializing in \
    Infrastructure as Code safety. Analyze the provided Terraform plan output. \
    Provide a detailed summary focusing on resource creation, modification, and \
    destruction. Highlight potentially risky changes (e.g., data loss, service \
    interruption), unexpected modifications, and confirm if the plan aligns with \
    standard safe deployment practices. Output in Markdown."'
```

#### PowerShell

```powershell
# Optimize IaC templates for cost and performance
function Optimize-IacTemplate ($TemplatePath) {
    Get-Content $TemplatePath | llm "Act as a Cloud FinOps expert and Platform `
        Engineer. Review this Infrastructure as Code template ($TemplatePath - specify `
        if CloudFormation, ARM, etc.). Identify opportunities for cost optimization `
        (e.g., right-sizing instances, using spot instances, optimizing storage tiers) `
        and performance improvements (e.g., caching, autoscaling configurations). `
        Also check for security best practices. Provide actionable recommendations `
        with estimated impact."
}
```

### Troubleshooting Deployments

Tools for analyzing logs, identifying root causes of failures, and suggesting remediation actions for various deployment issues.

#### Bash

```bash
# Analyze failing Kubernetes pod logs
kubectl logs my-failing-pod -p --tail=50 | llm "Analyze these logs from a failing \
    Kubernetes pod. What is the likely cause of the crash? Suggest troubleshooting \
    steps. Output as a format Markdown document with: background, problem, and \
    solution." > ./troubleshooting.md
```

#### PowerShell

```powershell
# Detailed Kubernetes pod log analysis
function Troubleshoot-K8sPodLog ($LogFilePath) {
    Get-Content $LogFilePath | llm "Act as an experienced SRE troubleshooting a `
        Kubernetes incident. Analyze these logs from a failing pod ($LogFilePath). `
        Identify the root cause of errors or crashes. Look for patterns, specific `
        error messages, resource exhaustion, or dependency failures. Suggest concrete `
        `kubectl` commands or configuration changes to investigate further or resolve `
        the issue. Format as a Markdown troubleshooting guide."
}
```

### Generating Infrastructure Code

Tools for creating various infrastructure artifacts such as Dockerfiles, CI/CD pipelines, and container configurations.

#### Bash

```bash
# Generate a Dockerfile
llm "Generate a basic Dockerfile for a Python Flask application listening on \
    port 5000." > Dockerfile

# Convert docker run to docker-compose
echo 'docker run -d --name redis -p 6379:6379 redis:alpine' | llm "Convert this \
    docker run command into a docker-compose.yml format." > docker-compose.yml

# Advanced alias for generating CI/CD pipelines
alias cicd-gen='llm "Act as a CI/CD architect. Generate a robust, production-ready \
    pipeline snippet for '$1' (e.g., 'building a Go binary', 'deploying a container \
    to ECS', 'running integration tests with pytest'). Use best practices for the \
    specified platform (e.g., GitHub Actions, GitLab CI, Jenkins). Include steps for \
    linting, testing, building, and potentially deploying. Ensure error handling and \
    clear stage separation."'
```

#### PowerShell

```powershell
# Convert Docker run to other formats
function Convert-DockerRun ($DockerRunCommand, $TargetFormat) {
    echo $DockerRunCommand | llm "Act as a DevOps engineer migrating container `
        workloads. Convert the following 'docker run' command into an equivalent, `
        well-structured configuration for '$TargetFormat' (specify `
        'docker-compose.yml' or 'Kubernetes Deployment YAML'). Ensure ports, `
        volumes, environment variables, and networking are correctly translated. `
        Command: $DockerRunCommand"
}
```

### Optimizing CI/CD Pipelines

Tools for reviewing and optimizing CI/CD workflows to improve speed, reliability, and efficiency.

#### Bash

```bash
# Optimize GitHub Actions workflow
cat .github/workflows/ci.yml | llm "Review this GitHub Actions workflow step. \
    Suggest ways to optimize its speed or efficiency." | glow -p
```

## Software Development

This section provides tools for developers to enhance their coding workflow, from understanding and refactoring code to generating tests and documentation.

### Understanding Code

Tools to help developers understand complex code snippets, algorithms, and implementation details.

#### Bash

```bash
# Explain code snippets
sed -n '50,70p' src/main.go | llm "Explain what this Go code snippet does."

# Explain Git diffs
git diff HEAD~1 HEAD -- src/utils.py | llm "Summarize the changes made in this \
    git diff for src/utils.py."

# Advanced alias for detailed code explanation
alias dev-explain='cat "$1" | llm "Act as a patient Senior Developer mentoring a \
    junior colleague. Explain the provided code snippet (language: '$2') in \
    simple terms. Describe its purpose, logic flow, key variables, and potential \
    complexities or side effects. Use analogies if helpful. Focus on clarity and \
    understanding."'
```

### Code Generation and Examples

Tools for generating boilerplate code, implementation examples, and code patterns.

#### Bash

```bash
# Generate unit test boilerplate
llm "Generate Python unittest boilerplate for a function named \
    'calculate_discount(price, percentage)' in a file \
    'calculator.py'." > tests/test_calculator.py

# Find code examples for library usage
llm "Show a simple example of using the 'requests' library in Python to make a \
    GET request and print the JSON response."

# Advanced alias for generating comprehensive unit tests
alias dev-gentest='cat "$1" | llm "Act as a meticulous senior developer strong in \
    Test-Driven Development (TDD). Given the following provided code snippet (language: \
    '$2'), generate comprehensive unit tests using a standard framework (e.g., \
    Python `unittest`/`pytest`, Go `testing`, JS `jest`/`mocha`). Cover happy \
    paths, edge cases, error conditions, and provide clear, descriptive test names. \
    Output only the test code."'
```

#### PowerShell

```powershell
# Generate code documentation
function Document-Code ($SourcePath, $TargetElement, $Language) {
    Get-Content $SourcePath | llm "Act as a Senior Developer writing high-quality `
        documentation. Based on the code in ($SourcePath), generate a clear, concise, `
        and standard documentation comment (e.g., Python docstring, JSDoc, C# XML `
        comment) for the function/class/method named '$TargetElement' in language `
        '$Language'. Explain its purpose, parameters (including types), return `
        value, and any exceptions raised. Output only the documentation block."
}
```

### Code Refactoring and Improvement

Tools for refactoring, optimizing, and improving existing code.

#### Bash

```bash
# Refactor code with specific goals
alias dev-refactor='cat "$1" | llm "Act as a Principal Software Engineer focused on \
    code quality and performance. Analyze the provided code snippet (language: '$2'). \
    Refactor it to improve '$3' (e.g., 'readability', 'performance', 'idiomatic \
    style', 'async/await usage', 'error handling'). Explain the changes made and \
    why they are improvements. Output the refactored code block."'
```

#### PowerShell

```powershell
# Suggest code fixes based on error logs
function Suggest-CodeFix ($ErrorLogPath, $CodeFilePath) {
    $errorLog = Get-Content $ErrorLogPath
    # Attempt to find the error line or a relevant part of it in the code file to get context
    $pattern = ($errorLog -split '\r?\n' | Select-Object -First 1) # Use first line of error as pattern
    try {
        $codeContext = Get-Content $CodeFilePath | Select-String -Pattern $pattern -Context 10,10 -ErrorAction Stop
    } catch {
        # If pattern not found, send the whole file (or a reasonable chunk)
        Write-Warning "Error pattern not found in code file. Sending first 100 lines as context."
        $codeContext = Get-Content $CodeFilePath -TotalCount 100
    }
    echo "Error Log:" $errorLog "`nCode Context:" $codeContext | llm "Act as an `
        expert debugger. Based on the following error message and surrounding code `
        context from ($CodeFilePath), suggest a specific code fix to resolve the `
        error. Explain the reasoning behind the fix. Error: $errorLog --- Code `
        Context: $codeContext"
}

# Translate code between languages
function Translate-Code ($SourcePath, $SourceLang, $TargetLang) {
    Get-Content $SourcePath | llm "Act as a polyglot programmer. Translate the `
        following code snippet from ($SourcePath), written in '$SourceLang', into `
        idiomatic '$TargetLang'. Preserve the original logic and functionality. Add `
        comments where the translation might be non-obvious. Original Language: `
        $SourceLang, Target Language: $TargetLang. Code: "
}
```

## System Administration

This section demonstrates how system administrators can use LLMs to explain system behaviors, generate complex commands, format output, and troubleshoot various system issues.

### Analyzing System Logs and Configurations

Tools to help understand system logs, configuration files, and system behaviors.

#### Bash

```bash
# Explain systemd unit files
cat /etc/systemd/system/my-service.service | llm "Explain this systemd unit file. \
    What does it manage and how is it configured?"

# Advanced alias for system log analysis
alias sys-explainlog='cat "$1" | llm "Act as a veteran Linux System Administrator. \
    Analyze the provided system log entries (e.g., syslog, journalctl). Explain any \
    errors, warnings, or unusual events in plain English. Identify potential root \
    causes and suggest relevant troubleshooting commands or configuration checks."'
```

#### PowerShell

```powershell
# Analyze Windows Event Logs
function Troubleshoot-EventLog ($LogData) {
    echo $LogData | llm "Act as a Senior Windows System Engineer. Analyze this `
        Windows Event Log data. Identify critical errors or warnings. Explain their `
        potential impact on system stability or security. Provide specific Event IDs `
        to investigate further and suggest PowerShell commands or GUI steps for `
        troubleshooting."
}

# Analyze performance counter data
function Explain-PerfCounter ($PerfData) {
    echo $PerfData | llm "Act as a Performance Tuning Specialist. Analyze this `
        performance counter data (e.g., from Get-Counter or Perfmon). Identify `
        potential bottlenecks related to CPU, Memory, Disk I/O, or Network. Explain `
        the meaning of the key counters and suggest areas for further investigation `
        or optimization."
}
```

### Generating System Commands and Scripts

Tools for creating complex commands, cron jobs, and automation scripts.

#### Bash

```bash
# Generate cron job syntax
llm "Generate a cron schedule expression to run a script '/opt/backup.sh' \
    every Sunday at 3:30 AM."

# Alternative to man/apropos
llm "Explain the purpose and common options for the 'tar' command in Linux."
llm "Output just the command to extract /tmp/archive.tar.gz.gpg to /tmp/backup"
llm "Output just the command to do a 'dd' copy of /dev/sda to /dev/sdb while showing progress"

# Advanced alias for generating complex commands
alias sys-cmdgen='llm "Act as a command-line guru. Generate the precise and optimal \
    command-line syntax for the following task: '$1'. Ensure correct quoting, \
    options, and piping if necessary. Prioritize clarity and efficiency. Task: $1"'
```

#### PowerShell

```powershell
# Generate PowerShell scripts for automation
function Generate-PSScript ($TaskDescription) {
    llm "Act as an expert PowerShell scripter. Generate a well-structured `
        PowerShell script to accomplish the following task: '$TaskDescription'. `
        Include comments, error handling (try/catch), parameter validation (if `
        applicable), and follow PowerShell best practices. Output only the script code."
}
```

### Troubleshooting System Issues

Tools for diagnosing and resolving network connectivity problems, disk space issues, and other system problems.

#### Bash

```bash
# Troubleshoot network connectivity
{ ping -c 4 google.com; traceroute google.com; } | \
    llm "Based on this ping and traceroute output, are there any obvious network \
    connectivity issues? Please summarize in Markdown with sections of background, \
    problem, and recommendations" | tee ./summary.md | glow -p
```

### Formatting System Reports

Tools for creating well-formatted reports from system command output.

#### Bash

```bash
# Format disk usage as a report
df -h | llm "Format this 'df -h' output as a proper Markdown document and a table, \
    highlighting filesystems over 85% usage. Include headings and then a paragraph \
    explaining the section for: background, data, and summary of notable or actionable \
    items. Include a timestamp of when this data was processed, which is `date`" \
    | tee ./disk-space-$(date +"%F_%H-%M").md | glow

# Advanced alias for report formatting
alias sys-report='llm "Act as a System Administrator creating a status report. Take \
    the following provided raw command output and format it into a clean, readable Markdown \
    report. Use tables, code blocks, and headings appropriately. Add a brief summary \
    section highlighting key information or potential issues. Raw data: "' # Pipe command output here
```

## Cloud Engineering (AWS, Azure, GCP)

This section covers how cloud engineers can leverage LLMs to work more effectively with cloud platforms by explaining resources, generating CLI commands, troubleshooting issues, and analyzing costs.

### Understanding Cloud Resources

Tools to help interpret and summarize information about cloud resources and configurations.

#### Bash

```bash
# Explain AWS EC2 instance details
aws ec2 describe-instances --instance-ids i-012345abcdef | llm "Summarize the key \
    details about this EC2 instance from the JSON output."

# Explain GCP IAM roles
gcloud iam roles describe roles/compute.instanceAdmin.v1 --format=json \
    | llm "Explain the purpose and key permissions of this GCP IAM role based \
    on its JSON description."

# Summarize Azure VM list
az vm list --output json | llm "Summarize the names, locations, and OS types \
    of the Azure VMs listed in this JSON output."

# Advanced alias for cloud resource summarization
alias cloud-summarize='cat "$1" | llm "Act as a Cloud Architect reviewing resource \
    configurations. Analyze the provided JSON output from a cloud CLI describe/get \
    command (specify AWS/Azure/GCP resource type if known). Summarize the key \
    configuration settings, status, identifying information (ID, name, region), and \
    any potential misconfigurations or points of interest. Format as concise \
    Markdown bullet points."'
```

#### PowerShell

```powershell
# Explain cloud IAM policies
function Explain-CloudIAM ($PolicyJsonPath, $CloudProvider) {
    Get-Content $PolicyJsonPath | llm "Act as a Cloud Security Specialist focusing `
        on Identity and Access Management. Analyze this IAM Policy/Role JSON from `
        ($PolicyJsonPath) for '$CloudProvider' (AWS/Azure/GCP). Explain the `
        permissions granted or denied in plain English. Highlight overly permissive `
        statements, potential privilege escalation paths, or violations of least `
        privilege. Summarize the effective access level."
}
```

### Generating Cloud CLI Commands

Tools for creating precise and efficient cloud provider CLI commands for various tasks.

#### Bash

```bash
# Generate Azure CLI command
llm "Generate the Azure CLI command to create a resource group named 'my-rg' in the \
    'eastus' region."

# Advanced alias for generating cloud CLI commands
alias cloud-cmdgen='llm "Act as a certified Cloud Engineer (specify AWS, Azure, or \
    GCP). Generate the precise CLI command (`aws`, `az`, `gcloud`) needed to perform \
    the following task: '$1'. Include necessary parameters, filters, and output \
    formatting (e.g., --query, --output json/text) for clarity and usability. Task: $1"'
```

### Analyzing Cloud Costs

Tools to help monitor, analyze, and optimize cloud costs.

#### Bash

```bash
# Generate cost anomaly detection script
llm "Generate a simple shell script logic using the AWS CLI to check yesterday's estimated \
    charges and alert if it's 50% higher than the day before. Output only the script, \
    written to best practices, and production ready, with input validation, and error \
    handling." > ./check_cost_anomaly.sh

# Advanced alias for cost-related commands
alias cloud-costcheck='llm "Act as a Cloud FinOps Analyst. Generate the AWS CLI/Azure \
    CLI/gcloud command to '$1' (e.g., 'get estimated charges for the last 7 days', \
    'list cost allocation tags', 'find the top 5 most expensive services this month'). \
    Provide the command to retrieve the data needed for cost analysis. Task: $1"'
```

### Generating Infrastructure as Code

Tools for creating Infrastructure as Code snippets for different cloud providers and tools.

#### PowerShell

```powershell
# Generate IaC snippets
function Generate-IacSnippet ($ResourceDescription, $IacTool, $CloudProvider) {
    llm "Act as a Senior Cloud Automation Engineer. Generate an Infrastructure as `
        Code snippet using '$IacTool' (Terraform/CloudFormation/ARM/Pulumi) for `
        '$CloudProvider' (AWS/Azure/GCP) to define the following resource: `
        '$ResourceDescription'. Follow best practices for the chosen tool, including `
        parameterization and outputs where appropriate. Resource: $ResourceDescription"
}
```

### Troubleshooting Cloud Connectivity

Tools for diagnosing and resolving connectivity issues in cloud environments.

#### PowerShell

```powershell
# Troubleshoot cloud network connectivity
function Troubleshoot-CloudNetwork ($DiagOutput, $CloudProvider) {
    echo $DiagOutput | llm "Act as a Cloud Network Engineer diagnosing a connectivity `
        problem for '$CloudProvider' (AWS/Azure/GCP). Analyze the provided diagnostic `
        output ($DiagOutput - e.g., ping, traceroute, VPC Flow Logs summary, `
        NSG/Firewall rules). Identify the likely point of failure (e.g., DNS `
        resolution, security group block, routing issue, service outage) and suggest `
        specific troubleshooting steps or configuration changes within the `
        '$CloudProvider' environment."
}
```
