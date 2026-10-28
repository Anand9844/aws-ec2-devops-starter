# AWS EC2 DevOps Starter: Containerized Web App + CI + Health Check

A beginner-friendly portfolio project for an entry-level AWS DevOps role. It uses a small Flask application, Docker, Docker Compose, GitHub Actions CI, and an optional Amazon EC2 deployment. It also gives you a clear next step for learning CloudWatch.

## Architecture

Developer → GitHub repository → GitHub Actions (tests + Docker build) → Ubuntu EC2 instance (Docker Compose) → HTTP health endpoint.

Optional extension: CloudWatch Agent / CloudWatch metrics and logs.

## Project features

- Simple responsive Flask dashboard.
- `/health` JSON endpoint for health checks.
- Docker image built with a non-root application user.
- Docker Compose deployment with restart policy and container health check.
- GitHub Actions workflow runs tests and builds the Docker image on pushes and pull requests to `main`.
- Deployment script intended to run on your own EC2 instance.
- No AWS credentials are stored in the repository.

## Before starting: avoid unexpected AWS charges

AWS account offers and Free Tier eligibility vary by account creation date and plan. Check the current AWS Free Tier page and the pricing pages for the services and region you choose before launching anything. Set a billing budget/alert if available. An EC2 instance, public IPv4 address, EBS storage, data transfer, snapshots, and CloudWatch usage can incur charges. Stop and terminate resources when you finish; stopping an instance may not stop storage or public IPv4 charges. Do not assume the project will always be free.

Official pages:
- AWS Free Tier: https://aws.amazon.com/free/
- EC2 pricing: https://aws.amazon.com/ec2/pricing/
- CloudWatch pricing: https://aws.amazon.com/cloudwatch/pricing/
- AWS billing and cost management: https://aws.amazon.com/aws-cost-management/

## Part 1 — Run locally on your laptop

Requirements: Git, Docker Desktop (with Docker Compose), and optionally Python 3.12+ for running tests outside Docker.

1. Extract this ZIP.
2. Open the extracted `aws-ec2-devops-starter` folder in VS Code.
3. Open the VS Code terminal in that folder.
4. Build and run:

```bash
docker compose up --build -d
```

5. Open these URLs in your browser:
   - Dashboard: http://localhost
   - Health check: http://localhost/health

Expected health response resembles:

```json
{"app":"aws-devops-starter","status":"healthy","timestamp":"..."}
```

6. Check the container and logs:

```bash
docker compose ps
docker compose logs -f
```

7. Stop the local project:

```bash
docker compose down
```

If Docker cannot download images, check internet access, Docker Desktop status, and whether a VPN/proxy or network policy is interfering. Do not change security settings blindly.

## Part 2 — Push the project to GitHub

1. Create a new empty GitHub repository named `aws-ec2-devops-starter`. Do not add a README or license there because this folder already contains a README.
2. In VS Code terminal, from the project folder, run:

```bash
git init
git add .
git commit -m "Initial AWS DevOps starter project"
git branch -M main
git remote add origin https://github.com/YOUR-GITHUB-USERNAME/aws-ec2-devops-starter.git
git push -u origin main
```

Replace `YOUR-GITHUB-USERNAME` with your actual GitHub username. GitHub may ask you to authenticate through your browser or credential manager. Do not use your account password as a Git password and never commit tokens, private keys, `.env` files or AWS credentials.

3. Open the repository on GitHub → **Actions**. The workflow should run automatically. Confirm that the test and Docker build steps pass.

## Part 3 — Deploy to Amazon EC2 (optional practical step)

This project uses a straightforward manual deployment to make the first AWS lab easier to understand. GitHub Actions currently tests the code and builds the image; it does not automatically deploy to AWS.

### A. Launch an EC2 instance carefully

1. Sign in to the AWS Console.
2. Choose a region near you.
3. Open EC2 → Launch instance.
4. Choose a currently eligible low-cost/free-tier instance type and a supported Ubuntu LTS image. Check current eligibility and pricing before launch.
5. Create or select a key pair and download the private key securely. Never upload it to GitHub.
6. In the security group, allow:
   - SSH TCP 22 only from **My IP** while you administer the instance.
   - HTTP TCP 80 from `0.0.0.0/0` only if you want the demo website publicly reachable.
   - Do not open port 5000 publicly; Compose maps host port 80 to container port 5000.
7. Review the estimated charges and launch.

### B. Connect to Ubuntu EC2

On Windows, use PowerShell with the downloaded `.pem` file. Store the key in a secure folder, not in the repository.

```powershell
ssh -i "C:\path\to\your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

If Windows OpenSSH reports a permissions error, restrict the private key file permissions in Windows before retrying. Never share the private key.

### C. Install Docker Engine on the Ubuntu instance

Use Docker's current official Ubuntu installation instructions:
https://docs.docker.com/engine/install/ubuntu/

After installation, verify:

```bash
docker --version
docker compose version
```

Depending on the installation, you may need to use `sudo docker ...` or configure Docker group access. Adding a user to the Docker group grants powerful privileges; understand that risk and log out/in if you choose to do it.

### D. Clone and deploy

On the EC2 instance, substitute your repository URL:

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/YOUR-GITHUB-USERNAME/aws-ec2-devops-starter.git
cd aws-ec2-devops-starter
bash scripts/deploy_ec2.sh
```

Test on the server:

```bash
curl -i http://localhost/health
docker compose ps
docker compose logs --tail=100
```

Then open `http://YOUR_EC2_PUBLIC_IP` in your browser. If it does not open, check instance status, security group inbound rule for port 80, Docker container status, and logs. Do not share your public IP or key with strangers.

### E. Update the app after a code change

On your laptop, commit and push the change. On EC2, update the deployment:

```bash
cd aws-ec2-devops-starter
git pull
bash scripts/deploy_ec2.sh
```

This is a manual deployment workflow, not a fully automated production pipeline. You can improve it later with AWS Systems Manager, a controlled CI/CD deployment, or another secure deployment mechanism.

## Part 4 — Optional CloudWatch learning

For an entry-level AWS interview, learn how to:
1. Find EC2's basic CPU utilization metric in CloudWatch.
2. Understand CloudWatch alarms and alarm states.
3. Learn how CloudWatch Agent can publish operating-system memory, disk and log data; these are not all available as default EC2 metrics.
4. Review CloudWatch pricing and configure only what you need for the lab.

Official documentation: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html

## Troubleshooting

- Website does not load: confirm the instance is running, inbound TCP 80 is allowed, and `docker compose ps` shows the web container running.
- Health check fails: run `docker compose logs --tail=100` and `curl -i http://localhost/health` on EC2.
- GitHub Actions fails: open the workflow run, read the first failed step, and reproduce the test locally.
- Docker permission issue: use `sudo docker ...` where appropriate and review Docker's security documentation.
- Cannot SSH: verify the instance's public address, key pair, username `ubuntu`, and SSH inbound source IP.

## What to say in an interview — after you have actually run it

"I built a small Flask web application and containerized it using Docker. I created a Docker Compose configuration with a health check and restart policy. I pushed the code to GitHub and configured GitHub Actions to run tests and build the Docker image on code pushes and pull requests. I then deployed the container to an Ubuntu EC2 instance, configured the security group to allow only the required traffic, and verified the application through an HTTP health endpoint. As a next step, I explored CloudWatch for AWS monitoring."

Only claim the steps you have completed. If you only ran it locally, describe it as a local Docker and GitHub Actions project, not as an AWS deployment.

## Suggested resume bullet (add only after completing the work)

**AWS EC2 Web Application Deployment and Monitoring**
- Containerized a Flask application using Docker and Docker Compose, with an HTTP health endpoint and restart policy.
- Configured a GitHub Actions CI workflow to run application tests and validate Docker image builds.
- Deployed the containerized application to an Ubuntu EC2 instance and configured least-necessary security group access.
- Practised EC2 monitoring with CloudWatch and investigated application health and container logs.

Technologies: AWS EC2, CloudWatch fundamentals, IAM/security groups fundamentals, Ubuntu Linux, Docker, Docker Compose, Git, GitHub Actions, Python Flask, YAML.

## Repository structure

```text
aws-ec2-devops-starter/
├── .github/workflows/ci.yml
├── tests/test_app.py
├── scripts/deploy_ec2.sh
├── app.py
├── requirements.txt
├── requirements-dev.txt
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── .gitignore
└── README.md
```
