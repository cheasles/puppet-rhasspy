# @summary Enables the Rhasspy service.
#
# Uses SystemD to install and enable the Rhasspy service.
class rhasspy::service(
  Enum['present', 'absent'] $ensure = $rhasspy::ensure,
  Enum['running', 'absent'] $ensure_service = $rhasspy::ensure_service,
  String                    $user = $rhasspy::user,
  String                    $group = $rhasspy::group,
  String                    $profile = $rhasspy::profile,
  String                    $repository_path = $rhasspy::repository_path,
) {

  systemd::service::simple { 'rhasspy':
    ensure        => $ensure,
    description   => 'Rhasspy Service',
    service_user  => $user,
    service_group => $group,
    after         => 'network.target',
    exec_start    => "bash -o pipefail -c '{ ${repository_path}/source/rhasspy.sh -p ${profile} 2>&1 | cat >&2 3>&-; } 3>&1'",
  }
  -> service { 'rhasspy':
    ensure  => $ensure_service,
    require => Exec['make and install rhasspy'],
  }

}
