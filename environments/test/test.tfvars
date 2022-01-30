environment = "test"

type_resource = "durable"

alb_ingress_controller = {
  name        = "AWSLoadBalancerControllerIAMPolicytestEnv"
  path        = "/"
  description = "ALB controller Policy in Test Env"
}

ec2_full_access = {
  name        = "AWSFullAccessEC2ForEKStestEnv"
  path        = "/"
  description = "EC2 Full Access policy for EKS in Test Env"
}

iam_limited_access = {
  name        = "AWSLimitedAccessIAMtestEnv"
  path        = "/"
  description = "IAM limited access policy for EKS in Test Env"
}

eks_all_access = {
  name        = "AWSAllAccessEKStestEnv"
  path        = "/"
  description = "EKS full access policy in Test env"
}

// This need to contains only name for test env. For prod env need to be used the prod account
alb_ingress_controller_role_env = ["alb-controller-test-env"]