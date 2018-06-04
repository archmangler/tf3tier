# AWS VPC module for Terraform

A lightweight VPC module for Terraform. For a far more featureful (but complex) module, get the Terraform Community VPC module.

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com:archmangler/aws-vpc.git?ref=f5a02ef"

  environment = "vpc_name"
  key_name = "osadmin"

  vpc_cidr = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24"]
  private_subnets = ["10.0.100.0/24"]
}
```

See `interface.tf` for additional configurable variables.
NOTE: interfaces.tf is so names because this is the module’s API, 
the "interface" to the module.

## License

MIT

