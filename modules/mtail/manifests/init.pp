# == Class: mtail
#
# This class installs and sets-up Mtail
#
# === Parameters
#
# [*manage_repo_class*]
#   Whether to use a separate repository to install Statsd
#   Default: false (use 'govuk_ppa' repository)
#
# [*logs*]
#   List of files to monitor
#
# [*enabled*]
#   Enable Mtail service. (default true)
#
# [*port*]
#   HTTP port to listen on. (default "3903")
#
# [*collectd_socketpath*]
#   Path to collectd unixsock to write metrics to.
#
# [*graphite_host_port*]
#   Host:port to graphite carbon server to write metrics to.
#
# [*statsd_hostport*]
#   Host:port to statsd server to write metrics to.
#
# [*metric_push_interval*]
#   Interval between metric pushes, in seconds (default 60)
#
# [*extra_args*]
#   Mtail program extra arguments (default -log_dir /var/log/mtail)
#
class mtail(
  $logs,
  $manage_repo_class = false,
  $enabled = true,
  $port = 3093,
  $collectd_socketpath = undef,
  $graphite_host_port = undef,
  $statsd_hostport = undef,
  $metric_push_interval = 60,
  $extra_args = '-log_dir /var/log/mtail',
) {

  validate_bool($manage_repo_class)

  if $manage_repo_class {
    include mtail::repo
  } else {
    include govuk_ppa
  }

  package { 'mtail':
    ensure  => 'latest',
  }

  file { '/etc/default/mtail':
    content => template('mtail/default_mtail'),
    require => Package['mtail'],
    notify  => Service['mtail'],
  }

  file { '/etc/mtail':
    ensure  => directory,
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/mtail/progs',
    require => Package['mtail'],
    notify  => Service['mtail'],
  }

  file { '/etc/init.d/mtail':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/mtail/init',
    require => Package['mtail'],
  }

  service { 'mtail':
    ensure  => running,
    require => [Package['mtail'], File['/etc/init.d/mtail']],
  }

  @@icinga::check { "check_mtail_up_${::hostname}":
    check_command       => 'check_nrpe!check_proc_running!mtail',
    service_description => 'mtail not running',
    host_name           => $::fqdn,
  }
}
