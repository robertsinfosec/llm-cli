# `llm-cli` Usage Inspiration

This directory contains the core `llm.sh` (Bash) and `llm.ps1` (PowerShell) scripts. Below are various examples demonstrating how you can integrate LLM capabilities directly into your command-line workflows across different domains. Adapt these patterns to your specific needs!

*(Assume `llm` is an alias or link to either `llm.sh` or `llm.ps1`)*

- [`llm-cli` Usage Inspiration](#llm-cli-usage-inspiration)
  - [Cybersecurity \& Compliance](#cybersecurity--compliance)
  - [Platform Engineering \& DevOps](#platform-engineering--devops)
  - [Software Development](#software-development)
  - [System Administration](#system-administration)
  - [Cloud CLI Usage (AWS, Azure, GCP)](#cloud-cli-usage-aws-azure-gcp)

## Cybersecurity & Compliance

1.  **Analyze Firewall Rules (End of Pipe):**

    ```bash
    sudo iptables -L -n -v | llm "Analyze these iptables rules for potential \
        security risks or overly permissive entries. Summarize findings in \
        Markdown." | glow -p
    ```
    *This command pipes the output of `iptables` (listing firewall rules) to the LLM for security analysis and then formats the Markdown output with `glow`.*

2.  **Check Nginx Config Security (Middle of Pipe):**

    ```bash
    cat /etc/nginx/nginx.conf | llm "Identify potential security misconfigurations \
        in this Nginx config. Focus on SSL/TLS settings, headers, and access controls. \
        Output findings as a list." | grep 'SSL/TLS'
    ```
    *This command sends an Nginx configuration file to the LLM for security review and then uses `grep` to filter the LLM's output for lines specifically mentioning SSL/TLS.*

3.  **Explain Suspicious Log Entries (End of Pipe):**

    ```bash
    grep 'Failed password' /var/log/auth.log | tail -n 20 | llm "Explain these failed \
        login attempts. Are there patterns suggesting a brute-force attack?"
    ```
    *This command extracts recent failed login attempts from the system authentication log and asks the LLM to analyze them for potential brute-force patterns.*

4.  **Generate Security Policy Snippet (Start of Pipe):**

    ```bash
    llm "Generate a short password policy requiring 12+ chars, upper, lower, 
        number, symbol." > password_policy.txt
    ```
    *This command asks the LLM to generate a password policy text and saves it directly to a file.*

5.  **Review CloudFormation/Terraform for Insecure Defaults (End of Pipe):**

    ```bash
    cat template.yaml | llm "Review this CloudFormation template for insecure \
    configurations, like public S3 buckets or unrestricted security groups."
    ```
    *This command sends a CloudFormation template file to the LLM to identify potential security misconfigurations.*

## Platform Engineering & DevOps

1.  **Explain Kubernetes Resource YAML (End of Pipe):**

    ```bash
    kubectl get deployment my-app -o yaml | llm "Explain this Kubernetes Deployment \
        YAML in simple terms. What does it deploy and how?"
    ```
    *This command retrieves the YAML definition of a Kubernetes Deployment and asks the LLM to explain it.*

2.  **Generate Dockerfile for a Simple App (Start of Pipe):**

    ```bash
    llm "Generate a basic Dockerfile for a Python Flask application listening on \
        port 5000." > Dockerfile
    ```
    *This command asks the LLM to generate a Dockerfile for a specific application type and saves it to a file named `Dockerfile`.*

3.  **Troubleshoot Failing Pod Logs (End of Pipe):**

    ```bash
    kubectl logs my-failing-pod -p --tail=50 | llm "Analyze these logs from a failing \
        Kubernetes pod. What is the likely cause of the crash? Suggest troubleshooting \
        steps. Output as a format Markdown document with: background, problem, and \
        solution." > ./troubleshooting.md
    ```
    *This command fetches logs from a failing Kubernetes pod, sends them to the LLM for analysis and troubleshooting suggestions, and saves the formatted output to a Markdown file.*

4.  **Convert `docker run` to `docker-compose.yml` (End of Pipe):**

    ```bash
    echo 'docker run -d --name redis -p 6379:6379 redis:alpine' | llm "Convert this \
        docker run command into a docker-compose.yml format." > docker-compose.yml
    ```
    *This command provides a `docker run` command to the LLM and asks it to convert it into the equivalent `docker-compose.yml` format, saving the result.*

5.  **Optimize CI/CD Pipeline Step (End of Pipe):**

    ```bash
    cat .github/workflows/ci.yml | llm "Review this GitHub Actions workflow step. \
        Suggest ways to optimize its speed or efficiency." | glow -p
    ```
    *This command sends a GitHub Actions workflow file to the LLM for review and optimization suggestions, displaying the result with `glow`.*

## Software Development

1.  **Explain Code Snippet (End of Pipe):**

    ```bash
    sed -n '50,70p' src/main.go | llm "Explain what this Go code snippet does."
    ```
    *This command extracts specific lines from a Go source file using `sed` and asks the LLM to explain that code snippet.*

2.  **Generate Unit Test Boilerplate (Start of Pipe):**

    ```bash
    llm "Generate Python unittest boilerplate for a function named \
        'calculate_discount(price, percentage)' in a file \
        'calculator.py'." > tests/test_calculator.py
    ```
    *This command asks the LLM to generate Python unit test code for a specified function and saves it to a test file.*

3.  **Refactor Code Block (Middle of Pipe):**

    ```bash
    # (Select code in editor) -> Pipe selection to llm
    cat selected_code.js | llm "Refactor this JavaScript code to use async/await \
        instead of Promises."
    ```
    *This command sends a selected JavaScript code block (presumably piped from an editor or file) to the LLM for refactoring using async/await.*

4.  **Explain Git Diff (End of Pipe):**

    ```bash
    git diff HEAD~1 HEAD -- src/utils.py | llm "Summarize the changes made in this \
        git diff for src/utils.py."
    ```
    *This command gets the changes made in the last commit for a specific file (`git diff`) and asks the LLM to summarize those changes.*

5.  **Find Code Examples for Library Usage (Start of Pipe):**

    ```bash
    llm "Show a simple example of using the 'requests' library in Python to make a \
        GET request and print the JSON response."
    ```
    *This command asks the LLM to provide a code example for using a specific Python library.*

## System Administration

1.  **Explain `systemd` Unit File (End of Pipe):**

    ```bash
    cat /etc/systemd/system/my-service.service | llm "Explain this systemd unit file. \
        What does it manage and how is it configured?"
    ```
    *This command sends the content of a `systemd` service file to the LLM for an explanation of its configuration and purpose.*

2.  **Generate `cron` Job Syntax (Start of Pipe):**

    ```bash
    llm "Generate a cron schedule expression to run a script '/opt/backup.sh' \
        every Sunday at 3:30 AM."
    ```
    *This command asks the LLM to generate the correct `cron` syntax for a specified schedule and command.*

3.  **Troubleshoot Network Connectivity (End of Pipe):**

    ```bash
    { ping -c 4 google.com; traceroute google.com; } | \
        llm "Based on this ping and traceroute output, are there any obvious network \
        connectivity issues? Please summarize in Markdown with sections of background, \
        problem, and recommendations" | tee ./summary.md | glow -p
    ```
    *This command runs `ping` and `traceroute`, pipes their combined output to the LLM for network troubleshooting analysis, saves the Markdown summary to a file, and displays it with `glow`.*

4.  **Format Disk Usage Report (End of Pipe):**

    ```bash
    df -h | llm "Format this 'df -h' output as a proper Markdown document and a table, \
        highlighting filesystems over 85% usage. Include headings and then a paragraph \
        explaining the section for: background, data, and summary of notable or actionable \
        items. Include a timestamp of when this data was processed, which is `date`" \
        | tee ./disk-space-$(date +"%F_%H-%M").md | glow
    ```
    *This command gets disk usage (`df -h`), asks the LLM to format it as a detailed Markdown report with analysis and highlighting, saves it to a timestamped file, and displays it with `glow`.*

5.  **Alternative to `man` / `apropos` (Start of Pipe):**

    ```bash
    # List all tar commands
    llm "Explain the purpose and common options for the 'tar' command in Linux."
    # Ask for specifics
    llm "Output just the command to extract /tmp/archive.tar.gz.gpg to /tmp/backup"
    # Ask for a specific command
    llm "Output just the command to do a 'dd' copy of /dev/sda to /dev/sdb while showing progress"
    # Ask for a command to check disk usage
    llm "Output just the command to check disk usage in a human-readable format"
    ```
    *These commands demonstrate using the LLM to explain commands (like `man`) or generate specific command syntax based on natural language descriptions.*

## Cloud CLI Usage (AWS, Azure, GCP)

1.  **Explain AWS CLI Command Output (End of Pipe):**

    ```bash
    aws ec2 describe-instances --instance-ids i-012345abcdef | llm "Summarize the key \
        details about this EC2 instance from the JSON output."
    ```
    *This command retrieves detailed information about an EC2 instance in JSON format using the AWS CLI and asks the LLM to summarize the key details.*

2.  **Generate Azure CLI Command (Start of Pipe):**

    ```bash
    llm "Generate the Azure CLI command to create a resource group named 'my-rg' in the \
        'eastus' region."
    ```
    *This command asks the LLM to generate the specific Azure CLI command needed to create a resource group with given parameters.*

3.  **Explain GCP IAM Role Details (End of Pipe):**

    ```bash
    gcloud iam roles describe roles/compute.instanceAdmin.v1 --format=json \
        | llm "Explain the purpose and key permissions of this GCP IAM role based \
        on its JSON description."
    ```
    *This command retrieves the detailed JSON description of a GCP IAM role using `gcloud` and asks the LLM to explain its purpose and key permissions.*

4.  **Summarize Azure VM List (End of Pipe):**

    ```bash
    az vm list --output json | llm "Summarize the names, locations, and OS types \
        of the Azure VMs listed in this JSON output."
    ```
    *This command lists Azure VMs in JSON format using `az vm list` and asks the LLM to summarize key details like name, location, and OS type.*

5.  **Generate Cloud Cost Anomaly Alert Idea (Start of Pipe):**

    ```bash
    llm "Generate a simple shell script logic using the AWS CLI to check yesterday's estimated \
        charges and alert if it's 50% higher than the day before. Output only the script, \
        written to best practices, and production ready, with input validation, and error \
        handling." > ./check_cost_anomaly.sh
    ```
    *This command asks the LLM to generate a shell script that uses the AWS CLI to detect potential cost anomalies.*
