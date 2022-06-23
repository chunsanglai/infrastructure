# OpenSearch domain
resource "aws_elasticsearch_domain" "opensearch" {
  domain_name           = var.domain
  elasticsearch_version = var.opensearch_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }
  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.user_name
      master_user_password = var.password
    }
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  tags = var.tags-factory
}

# OpenSearch domain policy
resource "aws_elasticsearch_domain_policy" "opensearch" {
  domain_name     = aws_elasticsearch_domain.opensearch.domain_name
  access_policies = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "${aws_elasticsearch_domain.opensearch.arn}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.firehose_role.arn}"
      },
      "Action": [
        "es:ESHttpPost",
        "es:ESHttpPut"
      ],
      "Resource": [
        "${aws_elasticsearch_domain.opensearch.arn}",
        "${aws_elasticsearch_domain.opensearch.arn}/*"
      ]
    },
    {    
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.firehose_role.arn}"
      },
      "Action": "es:ESHttpGet",
      "Resource": [
        "${aws_elasticsearch_domain.opensearch.arn}/_all/_settings",
        "${aws_elasticsearch_domain.opensearch.arn}/_cluster/stats",
        "${aws_elasticsearch_domain.opensearch.arn}/index-name*/_mapping/type-name",
        "${aws_elasticsearch_domain.opensearch.arn}/roletest*/_mapping/roletest",
        "${aws_elasticsearch_domain.opensearch.arn}/_nodes",
        "${aws_elasticsearch_domain.opensearch.arn}/_nodes/stats",
        "${aws_elasticsearch_domain.opensearch.arn}/_nodes/*/stats",
        "${aws_elasticsearch_domain.opensearch.arn}/_stats",
        "${aws_elasticsearch_domain.opensearch.arn}/index-name*/_stats",
        "${aws_elasticsearch_domain.opensearch.arn}/roletest*/_stats"
      ]
    }
  ]
}
EOF
}
