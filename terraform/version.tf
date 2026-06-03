terraform {
    required_version = "> 1.6"

    required_version {
        aws = {
            source = "hashicrop/aws"
            version = "~> 5.0"
        }
    }
}