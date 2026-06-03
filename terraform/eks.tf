# eks implemented 
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  

  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

   vpc_id = aws_vpc.main.id

  eks_managed_node_groups = {

    on_demand = {
      instance_types = [var.node_instance_type]

      capacity_type = "ON_DEMAND"

      min_size     = 1
      max_size     = 2
      desired_size = var.on_demand_desired_size

      labels = {
        workload = "critical"
      }

      tags = {
        NodeGroup = "on_demand"
      }
    }

    spot = {
      instance_types = ["t3.medium"]

      capacity_type = "SPOT"

      min_size     = 1
      max_size     = 3
      desired_size = 1

      labels = {
        workload = "non-critical"
      }

      tags = {
        NodeGroup = "spot"
      }
    }
  }


  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    aws-ebs-csi-driver = {
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
   }
}

  tags = {
    Environment = var.environment
  }
}