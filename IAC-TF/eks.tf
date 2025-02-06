


# Step 3: Create an EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "private-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}

# Step 4: Create IAM role for EKS
resource "aws_iam_role" "eks_role" {
  name               = "eks_role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Step 5: Attach IAM policies to the EKS role
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Step 6: Create a Load Balancer Controller IAM role
resource "aws_iam_role" "lb_controller_role" {
  name               = "lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role_policy.json
}

data "aws_iam_policy_document" "lb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# # Step 7: Create a custom IAM Policy for Load Balancer Controller
# resource "aws_iam_policy" "lb_controller_policy" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   description = "IAM policy for AWS Load Balancer Controller"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:*",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeVpcs",
#           "cloudwatch:PutMetricData",
#           "tag:TagResources"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Step 8: Attach the custom Load Balancer policy to the role
# resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
#   role       = aws_iam_role.lb_controller_role.name
#   policy_arn = aws_iam_policy.lb_controller_policy.arn
# }

# Step 9: Create an EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  scaling_config {
    desired_size = 1   # Desired number of nodes
    max_size     = 2   # Maximum number of nodes
    min_size     = 1   # Minimum number of nodes
  }

  instance_types = ["t3.medium"]  # Change to your preferred instance type
}

# Step 10: Create IAM role for EKS nodes
resource "aws_iam_role" "eks_node_role" {
  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Step 11: Attach policies to the EKS node role
resource "aws_iam_role_policy_attachment" "node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Step 12: Configure Helm provider for Kubernetes
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cluster.name
}

# # Step 13: Install the AWS Load Balancer Controller using Helm
# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.5.0"  # Specify the version you want

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.eks_cluster.name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = aws_iam_role.lb_controller_role.name
#   }
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.eks_cluster.endpoint
# }

# output "cluster_name" {
#   value = aws_eks_cluster.eks_cluster.name
# }
