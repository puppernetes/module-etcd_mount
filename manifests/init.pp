class etcd_mount
{
  include ::systemd

  file { '/usr/lib/systemd/system/attach-ebs-volume.service':
    ensure => file,
    source => 'puppet:///modules/etcd_mount/attach-ebs-volume.service',
    before => Service['attach-ebs-volume.service'],
  } ~>
  Exec['systemctl-daemon-reload']

  file { '/usr/lib/systemd/system/format-ebs-volume.service':
    ensure => file,
    source => 'puppet:///modules/etcd_mount/format-ebs-volume.service',
    before => Service['format-ebs-volume.service'],
  } ~>
  Exec['systemctl-daemon-reload']

  file { '/usr/lib/systemd/system/var-lib-etcd.mount':
    ensure => file,
    source => 'puppet:///modules/etcd_mount/var-lib-etcd.mount',
    before => Service['var-lib-etcd.mount'],
  } ~>
  Exec['systemctl-daemon-reload']

  file { '/usr/local/sbin/attach_volume.sh':
    ensure => file,
    source => 'puppet:///modules/etcd_mount/attach_volume.sh',
    mode   => '0750',
    before => Service['attach-ebs-volume.service'],
  }

  file { '/usr/local/sbin/format_volume.sh':
    ensure  => file,
    source  => 'puppet:///modules/etcd_mount/format_volume.sh',
    mode    => '0750',
    before  => Service['format-ebs-volume.service'],
    require => User['etcd'],
  }

  service { 'attach-ebs-volume.service':
    ensure => running,
    enable => true,
    before => Service['format-ebs-volume.service'],
  }

  service { 'format-ebs-volume.service':
    ensure => running,
    enable => true,
    before => Service['var-lib-etcd.mount'],
  }

  service { 'var-lib-etcd.mount':
    ensure   => running,
    provider => 'systemd',
  }

  file { '/etc/systemd/system/multi-user.target.wants/var-lib-etcd.mount':
    ensure => link,
    target => '/usr/lib/systemd/system/var-lib-etcd.mount',
  }
}
