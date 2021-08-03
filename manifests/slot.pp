# @summary Describes a set of data used by Rhasspy.
#
# A slot is a list of data that Rhasspy can use for intents.
#
# @example
#   rhasspy::slot { 'namevar': }
define rhasspy::slot (
  String                    $source,
  Optional[String]          $folder = undef,
  Enum['present', 'absent'] $ensure = 'present',
  String                    $config_location = $rhasspy::config::config_location,
  String                    $user = $rhasspy::user,
  String                    $group = $rhasspy::group,
) {

  if $folder {
    ensure_resource('file', "${config_location}/slots/${folder}", {
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0644',
    })
  }

  file { "${config_location}/slots/${folder}/${title}":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    source  => $source,
    mode    => '0644',
    require => File["${config_location}/slots"],
    before  => Exec['retrain-rhasspy'],
  }

}
