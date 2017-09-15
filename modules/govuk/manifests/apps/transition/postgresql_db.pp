# == Class: govuk::apps::transition::postgresql_db
#
# === Parameters
#
# [*password*]
#   The DB instance password.
#
# [*backend_ip_range*]
#   Backend IP addresses to allow access to the database.
#
class govuk::apps::transition::postgresql_db (
  $password = '',
  $backend_ip_range = '10.3.0.0/16',
  $rds = false,
  $db_hostname = undef,
) {
  govuk_postgresql::db { 'transition_production':
    db_hostname             => $db_hostname,
    user                    => 'transition',
    password                => $password,
    allow_auth_from_backend => true,
    backend_ip_range        => $backend_ip_range,
    rds                     => $rds,
  }
}
