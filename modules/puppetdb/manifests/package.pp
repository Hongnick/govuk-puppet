class puppetdb::package($package_ensure) {

  include puppet::repository

  package { 'puppetdb':
    ensure  => $package_ensure,
    require => Class['puppet::package'],
  }

}
