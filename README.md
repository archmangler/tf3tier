
Simple Terraform and user-data scripts demonstrating infrastructure as code principles, vpc networking and 3 tier architecture.

- Deploys a VPC with a public subnet, 2  private subnets , 1 elb, 1 db node (not RDS, but custom mysql), 1 web node, 1 token app server
- Security group policies segregate access between the public and private subnets ensuring only internal subnets can access db subnets.
- User data scripts are used in each instance to install the application and configure it (mysql-server, nginx, php, custom php code)
- a very buggy CRUD app is presented via the ELB endpoint url
- Terraform code is divided along 3 lines: a) VPC is defined as a separate module for re-usability b) main web.tf deployment code is separated from the variables.tf which contains customisable variables dfor the deployment, outputs.tf contains outputs for other scripts and tools c) code for installing and customising each instance (db, web, app) is encapsulated in ec2 user-data scripts under files/.

Usage:

- add your keys to variables.tf
- terraform init
- terraform plan -out web.plan
- terraform apply web.plan
- paste the resulting elb fqdn into a browser
