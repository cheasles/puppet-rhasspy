# @summary Defines a program callable by Rhasspy.
#
# Defines a callable program/script that Rhasspy can use to populate intents.
#
# @example
#   rhasspy::slot_program { 'namevar': }
define rhasspy::slot_program (
  String                    $source,
  Optional[String]          $folder = undef,
  Enum['present', 'absent'] $ensure = 'present',
  String                    $config_location = $rhasspy::config::config_location,
  String                    $user = $rhasspy::user,
  String                    $group = $rhasspy::group,
) {

  if $folder {
    ensure_resource('file', "${config_location}/slot_programs/${folder}", {
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0644',
    })
  }

  file { "${config_location}/slot_programs/${folder}/${title}":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => '0744',
    source  => $source,
    require => File["${config_location}/slot_programs"],
    before  => Exec['retrain-rhasspy'],
  }

}
