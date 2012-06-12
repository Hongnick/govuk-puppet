class jetty($version='7.6.4.v20120524'){
  include wget
  include openjdk
  include logster
  include graylogtail

  $home = '/opt'

  user { 'jetty':
    ensure     => present,
    home       => '/home/jetty',
    managehome => true,
    shell      => '/bin/bash'
  }

  wget::fetch { 'jetty_download':
    /* Using the HEAnet mirror, as it's orders of magnitude faster */
    source      => "http://ftp.heanet.ie/pub/eclipse//jetty/$version/dist/jetty-distribution-$version.tar.gz",
    destination => "/usr/local/src/jetty-distribution-$version.tar.gz",
    before      => Exec['jetty_untar'],
  }

  exec { 'jetty_untar':
    command => "tar zxf /usr/local/src/jetty-distribution-$version.tar.gz && chown -R jetty:jetty $home/jetty-distribution-$version",
    cwd     => $home,
    creates => "$home/jetty-distribution-$version",
    path    => ['/bin',],
    notify  => Service['jetty'],
    require => User['jetty'],
  }

  file { "$home/jetty":
    ensure  => "$home/jetty-distribution-$version",
    require => Exec['jetty_untar'],
  }

  cron { 'logster-jetty':
    command => '/usr/sbin/logster JettyGangliaLogster /var/log/jetty/`date +\%Y_\%m_\%d.request.log`',
    user    => root,
    minute  => '*/2'
  }

  graylogtail::collect { 'graylogtail-jetty':
    log_file => '/var/log/jetty/`date +\%Y_\%m_\%d.request.log`',
    facility => 'jetty',
  }

  @@nagios_service { "check_jetty_5xx_${::hostname}":
    use                 => 'generic-service',
    check_command       => 'check_ganglia_metric!jetty_http_5xx!0.03!0.1',
    service_description => "check jetty error rate for ${::hostname}",
    host_name           => "${::govuk_class}-${::hostname}",
    target              => '/etc/nagios3/conf.d/nagios_service.cfg',
  }

  file { "$home/jetty/webapps":
    group   => 'deploy',
    owner   => 'jetty',
    mode    => '0664',
    require => Exec['jetty_untar'],
  }

  file { "$home/jetty/contexts/test.xml":
    ensure => absent,
  }
  file { "$home/jetty/contexts/test.d":
    ensure => absent,
  }
  file { "$home/jetty/webapps/test.war":
    ensure => absent,
  }

  file { "$home/jetty/etc/jetty-webapps.xml":
    ensure  => present,
    source  => 'puppet:///modules/jetty/jetty-webapps.xml',
    require => File["$home/jetty"],
    notify  => Service['jetty'],
  }

  file { "$home/jetty/etc/jetty-contexts.xml":
    ensure  => present,
    source  => 'puppet:///modules/jetty/jetty-contexts.xml',
    require => File["$home/jetty"],
    notify  => Service['jetty'],
  }

  file { "$home/jetty/start.ini":
    ensure  => present,
    source  => 'puppet:///modules/jetty/start.ini',
    require => File["$home/jetty"],
    notify  => Service['jetty'],
  }

  file { '/var/log/jetty':
    ensure  => "$home/jetty/logs",
    require => File["$home/jetty"],
  }

  file { '/etc/init.d/jetty':
    ensure => "$home/jetty-distribution-$version/bin/jetty.sh"
  }

  service {'jetty':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => true,
    require    => File['/etc/init.d/jetty'],
  }

}
