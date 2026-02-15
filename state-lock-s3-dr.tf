# resource "aws_s3_bucket" "terraform_state_dr" {
#   provider      = aws.dr
#   bucket        = "terraform-statelock-backend-bucket-dr"
#   force_destroy = true
#   lifecycle {
#     prevent_destroy = false
#   }

# }
# resource "aws_s3_bucket_versioning" "dr_versioning" {
#   provider = aws.dr
#   bucket   = aws_s3_bucket.terraform_state_dr.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_iam_role" "replication_role" {
#   name = "terraform-state-replication-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "s3.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
# resource "aws_iam_role_policy" "replication_policy" {
#   role = aws_iam_role.replication_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObjectVersionForReplication",
#           "s3:GetObjectVersionAcl",
#           "s3:GetObjectVersionTagging"
#         ]
#         Resource = "${aws_s3_bucket.terraform_state.arn}/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ReplicateObject",
#           "s3:ReplicateDelete"
#         ]
#         Resource = "${aws_s3_bucket.terraform_state_dr.arn}/*"
#       }
#     ]
#   })
# }

# resource "aws_s3_bucket_replication_configuration" "replication" {
#   provider = aws.london
#   bucket   = aws_s3_bucket.terraform_state.id
#   role     = aws_iam_role.replication_role.arn

#   rule {
#     id     = "terraform-state-replication"
#     status = "Enabled"

#     destination {
#       bucket        = aws_s3_bucket.terraform_state_dr.arn
#       storage_class = "STANDARD"
#     }
#   }

#   depends_on = [
#     aws_s3_bucket_versioning.versioning,
#     aws_s3_bucket_versioning.dr_versioning
#   ]
# }


# resource "aws_dynamodb_table" "terraform_locks_dr" {
#   provider     = aws.dr
#   name         = "terraform-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
