# @summary Installs Rhasspy.
#
# Installs Rhasspy using the package manager. Can also create the required
# user/group as well as the profile folders too.
class rhasspy::install(
  Enum['present', 'absent', 'latest'] $repository_ensure = $rhasspy::repository_ensure,
  String                              $repository_path = $rhasspy::repository_path,
  String                              $repository_url = $rhasspy::repository_url,
  String                              $repository_revision = $rhasspy::repository_revision,
  Array[String]                       $apt_dependencies = $rhasspy::apt_dependencies,
  Boolean                             $manage_user = $rhasspy::manage_user,
  String                              $user = $rhasspy::user,
  String                              $group = $rhasspy::group,
  Boolean                             $manage_mosquitto = $rhasspy::manage_mosquitto,
) {

  ensure_packages(
    $apt_dependencies,
    {'ensure' => latest}
  )

  if $manage_mosquitto {
    package { 'mosquitto':
      ensure => latest,
    }
  }

  if $manage_user {
    group { $group:
      ensure => present,
    }
    -> user { $user:
      ensure => present,
      groups => $group,
      system => true,
      home   => "/var/lib/${user}/",
    }

    file { "/var/lib/${user}":
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0600',
    }

    file { "/var/lib/${user}/.config":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File["/var/lib/${user}"],
    }

    file { "/var/lib/${user}/.config/rhasspy":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File["/var/lib/${user}/.config"],
    }

    file { "/var/lib/${user}/.config/rhasspy/profiles":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File["/var/lib/${user}/.config/rhasspy"],
    }
  }

  vcsrepo { "${repository_path}/source":
    ensure   => $repository_ensure,
    provider => git,
    source   => $repository_url,
    revision => $repository_revision,
    user     => $user,
    group    => $group,
  }

  exec { 'configure rhasspy':
    cwd       => "${repository_path}/source",
    command   => "${repository_path}/source/configure --enable-in-place",
    user      => $user,
    group     => $group,
    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin'],
    creates   => "${repository_path}/source/Makefile",
    subscribe => Vcsrepo["${repository_path}/source"],
  }

  exec { 'make and install rhasspy':
    cwd       => "${repository_path}/source",
    command   => 'make && make install',
    user      => $user,
    group     => $group,
    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin'],
    timeout   => 600,
    creates   => "${repository_path}/source/.venv/bin/activate",
    subscribe => Exec['configure rhasspy'],
  }

  file { "${repository_path}/source/rhasspy.sh":
    ensure    => present,
    owner     => $user,
    group     => $group,
    mode      => '0777',
    subscribe => Exec['make and install rhasspy'],
  }

}
