# @summary Configures Rhasspy
#
# This manifest creates the required folders for Rhasspy, and writes all
# configuration files.
class rhasspy::config(
  String           $profile = $rhasspy::profile,
  String           $user = $rhasspy::user,
  String           $group = $rhasspy::group,
  String           $config_location = $rhasspy::config_location,
  Hash             $config_options = $rhasspy::config_options,
  Hash             $sentences = $rhasspy::sentences,
  Hash             $slots = $rhasspy::slots,
  Hash             $slot_programs = $rhasspy::slot_programs,
  Optional[String] $rhasspy_http_url = $rhasspy::rhasspy_http_url,
) {

  ###
  # Create the required folders.
  ###

  file { $config_location:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0600',
  }

  file { "${config_location}/slots":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0600',
    require => File[$config_location],
  }

  file { "${config_location}/slot_programs":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0600',
    require => File[$config_location],
  }

  ###
  # Write the actual config.
  ###

  file { "${config_location}/profile.json":
    ensure  => 'present',
    owner   => $user,
    group   => $group,
    content => hash2json($config_options),
    notify  => Service['rhasspy'],
    require => File[$config_location],
  }

  concat { "${config_location}/sentences.ini":
    ensure => present,
    owner  => $user,
    group  => $group,
  }

  if $rhasspy_http_url {
    exec { 'retrain-rhasspy':
      command     => "/usr/bin/curl -X POST ${rhasspy_http_url}/api/train",
      user        => $user,
      group       => $group,
      refreshonly => true,
      subscribe   => Concat["${config_location}/sentences.ini"],
      require     => Service['rhasspy'],
    }
  }

  create_resources ( rhasspy::sentence, $sentences )
  create_resources ( rhasspy::slot, $slots )
  create_resources ( rhasspy::slot_program, $slot_programs )

}
