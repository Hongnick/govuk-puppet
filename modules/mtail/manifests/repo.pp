# == Class: mtail::repo
#
# Use our own Mtail repo
#
# === Parameters
#
# [*apt_mirror_hostname*]
#   Hostname to use for the APT mirror.
#
class mtail::repo(
  $apt_mirror_hostname = undef,
) {
  apt::source { 'mtail':
    location     => "http://${apt_mirror_hostname}/mtail",
    release      => $::lsbdistcodename,
    architecture => $::architecture,
    key          => '3803E444EB0235822AA36A66EC5FE1A937E3ACBB',
  }
}
