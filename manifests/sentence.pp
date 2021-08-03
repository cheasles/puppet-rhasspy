# @summary Describes a sentence used by Rhasspy to recognise intent.
#
# @example
#   rhasspy::sentence { 'namevar': }
define rhasspy::sentence(
  Array[String] $lines,
  String        $config_location = $rhasspy::config::config_location,
) {

  concat::fragment { "sentence-${title}":
    target  => "${config_location}/sentences.ini",
    content => "[${title}]\n",
  }

  $lines.each | Integer $index, String $line | {
    concat::fragment { "sentence-${title}-${index}":
      target  => "${config_location}/sentences.ini",
      content => "${line}\n",
    }
  }

}
