provider "aws" {
  region = "us-east-1"
}

module "dns" {
  source = "../../modules/resources/dns"

  vpc_id = ""
  env    = ""
}
