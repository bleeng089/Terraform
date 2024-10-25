#Globally defines which provider terraform uses + each verision of that provider. Good Practice to define this explicitly
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws" #hashicorp defines the registry where aws is stored. Only verified providers are stored in the hashicorp registry
      version = "5.72.1"
    }
  }
}
