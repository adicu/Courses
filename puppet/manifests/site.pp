node 'development.adicu.com' {
  exec { "apt-update":
      command => "/usr/bin/apt-get update"
  }

  Exec["apt-update"] -> Package <| |>

  include mongodb

  exec { 'load_development_data':
    command => '/usr/bin/mongorestore -d courses \
        /vagrant/puppet/development_dump/coursesd.bson && \
        /usr/bin/mongorestore -d courses \
        /vagrant/puppet/development_dump/sectionsd.bson',
    require => Class['mongodb']
  }

  user { 'courses':
    ensure => present,
    gid => 'users',
    home => '/home/courses/',
    shell => '/bin/bash',
    managehome => true
  }

  class { 'nodejs':
    version => 'v0.10.17'
  }

  package { 'grunt-cli':
    provider => 'npm'
  }

  include supervisord

  supervisord::program { 'courses_server':
    command         => "/bin/bash /vagrant/scripts/start_backend.sh",
    directory       => "/vagrant",
    user            => "courses",
    stdout_logfile  => "/var/log/supervisor/courses_server.log",
    redirect_stderr => true
  }

  supervisord::program { 'courses_static':
    command         => "/usr/bin/grunt watch",
    directory       => "/vagrant",
    user            => "courses",
    stdout_logfile  => "/var/log/supervisor/courses_server.log",
    redirect_stderr => true
  }

  exec { "restart_supervisor":
    command => "/usr/bin/sudo /etc/init.d/supervisor stop;
        /bin/sleep 1 && /usr/bin/sudo /etc/init.d/supervisor start",
    require => Supervisord::Program['courses_server']
  }

  class { 'nginx': }

  nginx::resource::vhost { 'courses.adicu.com':
    ensure => present,
    www_root => '/vagrant/public'
  }

  nginx::resource::location { 'courses.adicu.com-backend':
    ensure => present,
    location => '/api',
    proxy  => 'http://localhost:3000',
    vhost => 'courses.adicu.com',
    location_cfg_append => {
      rewrite => '/api(.*) $1 break'
    }
  }

  Firewall <| |>
}
