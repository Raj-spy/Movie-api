# 1. VPC Banana
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "raj-vpc"
  }
}

# 2. Public Subnet (Reception Area)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true # Isse servers ko Public IP milega

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}


# 4. Internet Gateway (Main Entry Gate)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 5. Route Table (Signboard for Public Subnet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Iska matlab "Bahar ka sara raasta"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# eks implemented 
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "raj-eks-cluster"
  cluster_version = "1.30"

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
      instance_types = ["t3.medium"]

      capacity_type = "ON_DEMAND"

      min_size     = 1
      max_size     = 2
      desired_size = 1

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
    Environment = "dev"
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version = "~> 5.0"

  create_role = true

  role_name = "eks-ebs-csi-driver"

  provider_url = module.eks.oidc_provider

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:ebs-csi-controller-sa"
  ]
}