# == Class govuk_elasticsearch::plugins
#
# Install plugins on an Elasticsearch node
#
class govuk_elasticsearch::plugins {

  elasticsearch::plugin { 'mobz/elasticsearch-head':
    module_dir => 'head',
    instances  => $::fqdn,
  }

  elasticsearch::plugin { 'elasticsearch-migration':
    module_dir => 'migration',
    url        => 'https://github.com/elastic/elasticsearch-migration/releases/download/v1.19/elasticsearch-migration-1.19.zip',
    instances  => $::fqdn,
  }

  if $govuk_elasticsearch::version =~ /^1\./ {
    case $govuk_elasticsearch::version {
      /^1.4/:  { $cloud_aws_version = '2.4.2' }
      /^1.5/:  { $cloud_aws_version = '2.5.1' }
      /^1.7/:  { $cloud_aws_version = '2.7.1' }
      default: { fail('Not able to select a version for cloud-aws, see https://github.com/elastic/elasticsearch-cloud-aws') }
    }

    elasticsearch::plugin { "elasticsearch/elasticsearch-cloud-aws/${cloud_aws_version}":
      module_dir => 'cloud-aws',
      instances  => $::fqdn,
    }
  }
}
