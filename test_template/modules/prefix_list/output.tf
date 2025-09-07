#--------------------------------------------------
# オンプレ
#--------------------------------------------------
output "prefixlist_onpremises" {
  description = "PrefixList Onpremises"
  value       = aws_ec2_managed_prefix_list.prefixlist_onpremises
}

