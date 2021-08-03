# @summary The main Rhasspy manifest
#
# Includes the required manifests to install and configure Rhasspy.
#
# @example
#   include rhasspy
class rhasspy(
  String                              $user = 'rhasspy',
  String                              $group = 'rhasspy',
  Boolean                             $manage_user = true,
  Enum['present', 'absent']           $ensure = 'present',
  Enum['running', 'absent']           $ensure_service = 'running',
  String                              $profile = 'en',
  Enum['present', 'absent', 'latest'] $repository_ensure = 'present',
  String                              $repository_path = "/var/lib/${user}",
  String                              $repository_url = 'https://github.com/rhasspy/rhasspy.git',
  String                              $repository_revision = 'master',
  Array[String]                       $apt_dependencies = ['python3', 'python3-dev', 'python3-setuptools', 'python3-pip', 'python3-venv', 'git', 'build-essential', 'libatlas-base-dev', 'swig', 'portaudio19-dev', 'supervisor', 'sox', 'alsa-utils', 'libgfortran4', 'libopenblas-dev', 'espeak', 'flite', 'perl', 'curl', 'patchelf', 'ca-certificates', 'jq'],
  Boolean                             $manage_mosquitto = false,
  String                              $config_location = "/var/lib/${user}/.config/rhasspy/profiles/${profile}",
  Hash                                $config_options = {},
  Hash                                $sentences = {},
  Hash                                $slots = {},
  Hash                                $slot_programs = {},
  Optional[String]                    $rhasspy_http_url = undef,
) {
  include rhasspy::install
  include rhasspy::config
  include rhasspy::service
}
