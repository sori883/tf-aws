#--------------------------------------------------
# オンプレ
#--------------------------------------------------
resource "aws_ec2_managed_prefix_list" "prefixlist_onpremises" {
  name           = format("%s-%s-%s", var.common_name, "prefixlist-onpremises", var.post_prefix)
  address_family = "IPv4"
  max_entries    = 2

  entry {
    cidr        = "10.20.10.0/24"
    description = "primary"
  }

  entry {
    cidr        = "10.20.20.0/24"
    description = "secondary"
  }
}

