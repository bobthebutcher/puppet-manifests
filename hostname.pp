$dhclient_exit = @(EOF)
# Managed by puppet - Do not edit manually.
SETHOSTNAME="no"

if [ $SETHOSTNAME = "yes" ] && [ ! -z $new_host_name ]
then
    hostname $new_host_name
    sed --in-place -e "/127\.0\.1\.1/s/^.*$/127.0.1.1  $new_host_name/" /etc/hosts
fi
EOF

$hosts_file = @(EOF)
# Managed by puppet - Do not edit manually.
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters

192.168.121.149 sw01
192.168.121.221 puppet
EOF

file { '/etc/dhcp/dhclient-exit-hooks.d/dhcp-sethostname':
  ensure => 'present',
  before => File['/etc/hostname'],
  content => $dhclient_exit,
  notify => Service['networking']
}

file { '/etc/hostname':
  ensure => 'present',
  content => 'sw01',
  notify => Service['networking'],
}

file { '/etc/hosts':
  ensure => 'present',
  content => $hosts_file,
  notify => Service['networking'],
}

service {'networking':
  ensure => 'running',
  enable => true,
}
