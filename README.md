# AWS ECS Fargate DevOps Deployment

A complete DevOps project demonstrating the containerized deployment of a FastAPI application on AWS ECS Fargate using Terraform, GitHub Actions, Docker, Amazon ECR, Application Load Balancer, CloudWatch, and Amazon SNS.

## Project Overview

This project implements an end-to-end DevOps deployment workflow for a containerized FastAPI application on AWS ECS Fargate.

The application is containerized using Docker and stored in Amazon ECR. Terraform is used to provision and manage the AWS infrastructure, including the VPC, subnets, security groups, ECS cluster, Fargate service, Application Load Balancer, IAM roles, CloudWatch, and SNS.

GitHub Actions provides the CI/CD pipeline. Whenever code is pushed to the main branch, the pipeline automatically runs tests, builds the Docker image, pushes the image to Amazon ECR, updates the ECS task definition, and deploys the new version to ECS Fargate.

The ECS service runs two Fargate tasks behind an Application Load Balancer. The application exposes a health-check endpoint that is used by the load balancer to verify task health.

Amazon CloudWatch is used for container logging and ECS CPU monitoring. A CloudWatch alarm monitors CPU utilization and sends notifications through Amazon SNS when the configured threshold is exceeded.

The complete CloudWatch → SNS → Email alerting workflow was tested successfully, including verification of the alarm entering the ALARM state and automatically returning to OK based on the actual ECS CPU metrics.

### Main Workflow

GitHub → GitHub Actions → Docker → Amazon ECR → ECS Fargate → Application Load Balancer → FastAPI Application

### Monitoring Workflow

ECS Fargate → CloudWatch Metrics → CloudWatch Alarm → Amazon SNS → Email

## Architecture

```text
                         GitHub Repository
                                |
                                v
                       +-------------------+
                       |   GitHub Actions  |
                       |-------------------|
                       | Run Tests         |
                       | Docker Build      |
                       | ECR Push          |
                       | ECS Deployment    |
                       +---------+---------+
                                 |
                                 v
                       +-------------------+
                       |    Amazon ECR     |
                       |  Docker Images    |
                       +---------+---------+
                                 |
                                 v
                    +--------------------------+
                    |      ECS Fargate         |
                    |--------------------------|
                    |                          |
                    |  +--------+ +--------+   |
                    |  | Task 1 | | Task 2 |   |
                    |  | FastAPI | | FastAPI |  |
                    |  +--------+ +--------+   |
                    |                          |
                    +------------+-------------+
                                 |
                                 v
                       +-------------------+
                       | Application Load  |
                       |     Balancer      |
                       +---------+---------+
                                 |
                                 v
                       +-------------------+
                       | FastAPI           |
                       | Application       |
                       +-------------------+


                         Monitoring
                              |
             +----------------+----------------+
             |                                 |
             v                                 v
      CloudWatch Logs                  CloudWatch Metrics
                                               |
                                               v
                                      CloudWatch Alarm
                                               |
                                               v
                                          Amazon SNS
                                               |
                                               v
                                         Email Alert
```

## Technologies Used

### AWS

- Amazon ECS Fargate
- Amazon ECR
- Application Load Balancer
- Amazon VPC
- IAM
- Amazon CloudWatch
- Amazon SNS

### DevOps

- Terraform
- GitHub Actions
- GitHub OIDC
- Docker
- CI/CD
- Infrastructure as Code

### Application

- Python
- FastAPI
- Uvicorn
- Pytest

## Project Structure

```text
ecs-fargate-devops/
│
├── app/
│   ├── __init__.py
│   └── main.py
│
├── tests/
│   └── test_app.py
│
├── terraform/
│   ├── main.tf
│   ├── network.tf
│   ├── security_groups.tf
│   ├── iam.tf
│   ├── ecs.tf
│   ├── task_definition.tf
│   ├── alb.tf
│   ├── service.tf
│   ├── monitoring.tf
│   └── .terraform.lock.hcl
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── Dockerfile
├── .dockerignore
├── requirements.txt
├── pytest.ini
├── .gitignore
└── README.md
```

## Application

The project uses a lightweight FastAPI application.

### Root Endpoint

`GET /`

Returns the application deployment status.

Example response:

```json
{
  "message": "ECS Fargate deployment successful",
  "service": "ecs-fargate-devops"
}
```

### Health Check

`GET /health`

Returns:

```json
{
  "status": "healthy"
}
```

The `/health` endpoint is also used by the Application Load Balancer target group for ECS task health checks.

### API Documentation

FastAPI provides interactive API documentation at:

`/docs`

## Infrastructure as Code

Terraform is used to provision and manage the AWS infrastructure.

The Terraform configuration provisions:

- VPC
- Internet Gateway
- Two public subnets
- Public route table
- Application Load Balancer security group
- ECS task security group
- Amazon ECR repository
- ECS cluster
- ECS Fargate task definition
- ECS Fargate service
- Application Load Balancer
- Target group
- ALB listener
- CloudWatch log group
- IAM execution role
- GitHub Actions IAM role
- CloudWatch CPU alarm
- SNS topic
- SNS email subscription

The infrastructure is maintained as version-controlled Terraform code, allowing the environment to be reproduced and managed consistently.

## CI/CD Pipeline

GitHub Actions automates the application deployment process.

### Pipeline Flow

```text
Git Push
   |
   v
GitHub Actions
   |
   +--> Checkout Source
   |
   +--> Setup Python
   |
   +--> Install Dependencies
   |
   +--> Run Automated Tests
   |
   +--> Authenticate to AWS using GitHub OIDC
   |
   +--> Login to Amazon ECR
   |
   +--> Build Docker Image
   |
   +--> Push Image to ECR
   |
   +--> Download ECS Task Definition
   |
   +--> Update Container Image
   |
   +--> Deploy to ECS Fargate
   |
   +--> Wait for Service Stability
```

The workflow is triggered whenever code is pushed to the `main` branch.

The pipeline automatically:

1. Checks out the source code.
2. Sets up Python 3.11.
3. Installs application dependencies.
4. Runs Pytest.
5. Authenticates to AWS using GitHub OIDC.
6. Logs into Amazon ECR.
7. Builds the Docker image.
8. Tags the image using the Git commit SHA.
9. Pushes the image to Amazon ECR.
10. Updates the ECS task definition.
11. Deploys the updated task definition to ECS Fargate.
12. Waits for the ECS service to become stable.

## GitHub OIDC Authentication

GitHub Actions authenticates with AWS using OpenID Connect (OIDC).

Long-lived AWS access keys are not stored in the GitHub repository.

The workflow assumes a dedicated IAM role created specifically for GitHub Actions deployment.

This provides a more secure authentication mechanism for the CI/CD pipeline.

## Docker

The FastAPI application is containerized using Docker.

The Docker image:

- Uses Python 3.11
- Installs application dependencies
- Copies the FastAPI application
- Exposes port 8000
- Runs Uvicorn

The application is started using:

```text
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The resulting Docker image is pushed to Amazon ECR and deployed to ECS Fargate.

## Amazon ECR

Amazon Elastic Container Registry is used as the private Docker image registry.

The GitHub Actions pipeline follows this workflow:

```text
Docker Build
     |
     v
Amazon ECR
     |
     v
ECS Fargate
```

Images are tagged using the Git commit SHA.

Example:

```text
ecs-fargate-demo:<git-commit-sha>
```

Using commit-based image tags provides a specific and traceable image version for each deployment.

## ECS Fargate Deployment

The application is deployed as an ECS Fargate service with:

- Fargate launch type
- 2 desired tasks
- 256 CPU units
- 512 MB memory
- `awsvpc` networking
- Application Load Balancer integration
- Container port 8000

Running two tasks provides multiple application instances behind the load balancer.

## Application Load Balancer

An Application Load Balancer provides external access to the ECS service.

The traffic flow is:

```text
Internet
   |
   v
Application Load Balancer
   |
   +----> ECS Task 1
   |
   +----> ECS Task 2
```

The ALB forwards HTTP traffic on port 80 to the ECS tasks on port 8000.

## Security Groups

Two security groups are used.

### ALB Security Group

Allows:

- HTTP
- Port 80
- Source: `0.0.0.0/0`

### ECS Security Group

Allows:

- TCP
- Port 8000
- Source: Application Load Balancer security group

This allows application traffic from the Application Load Balancer while preventing unrestricted inbound access to the ECS tasks on port 8000.

## Load Balancer Health Checks

The ALB target group uses the application's health endpoint:

- Path: `/health`
- Protocol: HTTP
- Port: 8000
- Expected status: 200

The load balancer uses this endpoint to determine whether ECS tasks are healthy before forwarding traffic to them.

## Monitoring

Amazon CloudWatch is used for ECS logging and monitoring.

### CloudWatch Logs

ECS container logs are sent to the CloudWatch log group:

```text
/ecs/ecs-fargate-demo
```

This allows container output and application logs to be inspected centrally.

### CPU Monitoring

A CloudWatch alarm monitors ECS service CPU utilization.

Configuration:

- Metric: `CPUUtilization`
- Namespace: `AWS/ECS`
- Threshold: 70%
- Period: 60 seconds
- Evaluation periods: 2
- Statistic: Average

The alarm monitors the ECS cluster and service.

## Alerting with Amazon SNS

The CloudWatch alarm publishes to an Amazon SNS topic when the configured CPU threshold is exceeded.

The alerting flow is:

```text
ECS Fargate
     |
     v
CloudWatch CPU Metric
     |
     v
CloudWatch Alarm
     |
     v
Amazon SNS
     |
     v
Email Notification
```

The SNS topic is configured with an email subscription.

## Alerting Verification

The CloudWatch alerting workflow was tested end-to-end.

The alarm was manually changed to the `ALARM` state using the AWS CLI to test the notification path.

The configured SNS email notification was successfully received.

After the test, CloudWatch evaluated the actual ECS CPU metrics and automatically returned the alarm to the `OK` state.

The actual ECS CPU utilization remained significantly below the configured 70% threshold.

This verified the complete CloudWatch → SNS → Email notification path.

## Automated Testing

The application includes automated tests using Pytest.

The test suite verifies:

- Root endpoint availability
- Health endpoint availability
- HTTP response status codes
- Expected JSON response values

Tests are executed locally and automatically as part of the GitHub Actions CI/CD pipeline.

Run the tests locally with:

```bash
python -m pytest -v
```

## Deployment Verification

The deployed application was verified through the Application Load Balancer.

Health check:

```bash
curl http://<ALB-DNS>/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

The deployment was also verified through:

- ECS service status
- Running Fargate tasks
- ECS task definition revision
- Amazon ECR image
- ALB target health
- CloudWatch logs
- CloudWatch alarm state
- SNS email notification

## DevOps Concepts Demonstrated

This project demonstrates practical experience with:

- Infrastructure as Code
- CI/CD
- Docker containerization
- AWS ECS Fargate
- Amazon ECR
- Application Load Balancing
- AWS networking
- IAM
- GitHub OIDC
- Automated testing
- Immutable container image tagging
- CloudWatch monitoring
- Centralized container logging
- SNS alerting
- Health checks
- Deployment verification
- Infrastructure automation

## Key DevOps Workflow

```text
Developer
    |
    v
GitHub
    |
    v
GitHub Actions
    |
    +--> Automated Tests
    |
    +--> Docker Build
    |
    +--> Amazon ECR
    |
    v
ECS Fargate
    |
    v
Application Load Balancer
    |
    v
FastAPI Application
    |
    +--> CloudWatch Logs
    |
    +--> CloudWatch Metrics
              |
              v
       CloudWatch Alarm
              |
              v
             SNS
              |
              v
        Email Notification
```

## Future Improvements

Potential future enhancements include:

- HTTPS using AWS Certificate Manager
- SSL/TLS termination at the Application Load Balancer
- Route 53 custom domain
- CloudWatch dashboards
- Additional application and infrastructure metrics
- ECS deployment rollback strategies
- Blue/green deployments
- AWS WAF
- Additional alerting conditions

## Repository

GitHub Repository:

https://github.com/Zree77/ecs-fargate-devops

## Author

**Sreehari S**

B.Tech Computer Science and Engineering

GitHub: https://github.com/Zree77
