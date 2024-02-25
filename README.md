# Terraform AWS ECS Cluster Deployment\

This Terraform project automates the deployment of an AWS ECS (Elastic Container Service) cluster along with related resources such as an Application Load Balancer (ALB) and a Virtual Private Cloud (VPC). It's designed to streamline the setup process for containerized applications on AWS.

## Usage

Initialize Terraform: Run terraform init to initialize Terraform and download any necessary providers.
```
terraform init
```

Plan Deployment: Use terraform plan to create an execution plan. This step is optional but recommended to see what Terraform will do before actually making any changes.
```
terraform plan
```

Apply Configuration: Apply the Terraform configuration to create the ECS cluster and related resources. If the plan looks good, execute terraform apply.
```
terraform apply
```

Destroy Resources (Optional): If you want to remove all resources created by Terraform, you can run terraform destroy.
```
terraform destroy
```

# Configuration

In *main.tf* update your configs with necessary port and name

```
  container_name_front = "frontend"
  container_port_front = 3000
  container_name_api = "api"
  container_port_api = 3001
  container_name_streamlit_1 = "streamlit_1"
  container_port_streamlit_1 = 3001
  container_name_streamlit_2 = "streamlit_2"
  container_port_streamlit_2 = 3001
```

Update the limits and image for that you need to use 
```
        (local.container_name_front) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/central-service:latest"
```

## Container Communication Documentation

### Container Communication Configuration
Without proper configuration, containers will not be able to communicate with each other effectively. To enable communication between containers, specific setups and configurations are required.

### Service Connection Configuration
Uncommenting the service connection configuration is crucial for enabling communication between containers. This configuration allows containers to discover and communicate with each other using service discovery mechanisms.

```hcl
service_connect_configuration = {
  namespace = aws_service_discovery_http_namespace.this.arn
  service = {
    client_alias = {
      port     = local.container_port_front
      dns_name = local.container_name_front
    }
    port_name      = local.container_name_front
    discovery_name = local.container_name_front
  }
}
```

### Namespace Configuration
The namespace configuration defines the scope and context within which services are discovered and communicated with. This configuration is essential for proper service discovery and communication within the container ecosystem.

```hcl
resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}
```

### Types of Connection
There are two primary types of connections used for container communication: public IP-based and load balancer-based connections.

1. **Public IP-based Connection:**
   In this setup, containers communicate directly with each other using their public IP addresses.

2. **Load Balancer-based Connection:**
   Load balancers serve as intermediaries between containers, distributing traffic efficiently. This setup requires proper configuration of load balancers to ensure optimal performance and reliability. However, it may incur additional costs due to the resources required for load balancer setup and maintenance.
