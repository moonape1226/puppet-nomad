# == Class nomad::service
#
# This class is meant to be called from nomad
# It ensure the service is running
#
class nomad::run_service {

  $init_selector = $::nomad::init_style ? {
    'launchd' => 'io.nomad.daemon',
    default   => 'nomad',
  }

  $service_provider = $::nomad::init_style ? {
    'unmanaged' => undef,
    default     => $::nomad::init_style,
  }

  if $::nomad::manage_service == true {
    service { 'nomad':
      ensure   => $::nomad::service_ensure,
      name     => $init_selector,
      enable   => $::nomad::service_enable,
      provider => $service_provider,
    }
  }

}
