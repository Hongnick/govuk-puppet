# == Class: govuk_jenkins::job::smokey
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
# === Parameters
#
# [*auth_username*]
#   HTTP basic auth username
#
# [*auth_password*]
#   HTTP basic auth password
#
# [*signon_email*]
#   Username to sign in to Signon
#
# [*signon_password*]
#   Password to sign in to Signon
#
# [*smokey_bearer_token*]
#   Bearer token to pass as part of an Authorization HTTP header
#
# [*smokey_rate_limit_token*]
#   Token to pass as an HTTP header to bypass rate limiting
#
# [*spoof_target_domain*]
#   If you wish to run tests against an environment that is different to the
#   main app_domain parameter.
#
# [*smokey_task*]
#   The rake task to run for the tests
#
class govuk_jenkins::job::smokey (
  $auth_username = undef,
  $auth_password = undef,
  $signon_email = undef,
  $signon_password = undef,
  $smokey_bearer_token = undef,
  $smokey_rate_limit_token = undef,
  $smokey_task = 'test:production',
  $spoof_target_domain = undef,
  $app_domain = hiera('app_domain'),
) {
  $slack_team_domain = 'govuk'
  $slack_room = '2ndline'
  $slack_build_server_url = "https://deploy.${app_domain}/"

  $app = 'smokey'

  file { ["/etc/govuk/${app}", "/etc/govuk/${app}/env.d"]:
    ensure => 'directory',
  }

  govuk::app::envvar { 'GOVUK_APP_DOMAIN':
    app            => $app,
    value          => $app_domain,
    notify_service => false,
    require        => File["/etc/govuk/${app}/env.d"],
  }

  file { '/etc/jenkins_jobs/jobs/smokey.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/smokey.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
