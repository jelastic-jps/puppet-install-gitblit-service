# Class: fr_git_server
#
# This module manages a Git server Puppet-conf for FastROI.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class frprofile::fr_git_server {
  firewall { '100 allow http and https access':
    port   => [80, 443, 8009, 8080, 8081, 9418, 29418],
    proto  => tcp,
    action => accept,
  }

  # Most important first: create the git user. Hard-coded as 'git'.
  $git_user = 'git'
  $git_home = "/home/${git_user}"
  $git_repositories = "${git_home}/repositories"
  $gitblit = 'gitblit-1.6.2'
  $gb_rel_file = "${gitblit}.tar.gz"
  $simple_name = "fr_gitblit"
  $git_admins = "juharuo artopii jeretei"
  $users_htpasswd = "users.htpasswd"
  $users_data_path = "${git_home}/${gitblit}/data"
  $users_htpasswd_path = "${users_data_path}/${users_htpasswd}"
  $gitblit_unit = '/usr/lib/systemd/system/gitblit.service'
  user { "${git_user}":
    ensure     => present,
    comment    => 'git user',
    managehome => true,
    home       => "${git_home}",
  } -> file { 'Create Git repositories':
    name   => "${git_repositories}",
    ensure => 'directory',
    owner  => "${git_user}",
    group  => "${git_user}",
    mode   => '0750',
  } -> exec { 'Download GitBlit':
    cwd     => $git_home,
    path    => '/usr/bin:/bin',
    user    => "${git_user}",
    command => "wget http://dl.bintray.com/gitblit/releases/${gb_rel_file} -P ${git_home}",
    creates => "${git_home}/${gb_rel_file}",
  } -> file { 'Make GitBlit target directory':
    name   => "${git_home}/${gitblit}",
    ensure => 'directory',
    owner  => "${git_user}",
    group  => "${git_user}",
    mode   => '0750',
  } -> exec { 'Extract downloaded GitBlit release into the target directory.':
    cwd     => $git_home,
    path    => '/usr/bin:/bin',
    user    => "${git_user}",
    command => "tar xf ${gb_rel_file} -C ${gitblit}",
  } -> file { 'Rewrite the GitBlit properties-file':
    name    => "${git_home}/${gitblit}/data/gitblit.properties",
    content => template("${module_name}/${simple_name}/gitblit.properties.erb"),
    replace => true,
    owner   => "${git_user}"
  } -> file { 'Copy users.conf':
    name   => "${git_home}/${gitblit}/data/users.conf",
    owner  => "${git_user}",
    group  => "${git_user}",
    mode   => '0640',
    source => "puppet:///modules/${module_name}/${simple_name}/users.conf"
  } -> file { 'Copy htpasswd file':
    name   => "${users_htpasswd_path}",
    owner  => "${git_user}",
    group  => "${git_user}",
    mode   => '0640',
    source => "puppet:///modules/${module_name}/${simple_name}/${users_htpasswd}"
  } -> file { 'Create the systemd unit file':
    name  => $gitblit_unit,
    owner => 'root',
    group => 'root',
    mode  => '0640',
    content => template("${module_name}/${simple_name}/gitblit.service.erb"),
  } ->   exec { "Enable the GitBlit service":
    path    => '/usr/bin:/bin',
    command => "systemctl enable ${gitblit_unit}",
    creates => '/etc/systemd/system/multi-user.target.wants/gitblit.service'
  }

  class { 'apache':
    default_vhost       => false,
    default_ssl_vhost   => false,
    default_mods        => false,
    default_confd_files => false,
    keepalive           => 'On',
    keepalive_timeout   => 30,
    server_signature    => 'Off',
    server_tokens       => 'Prod'
  }

  class { 'apache::mod::status':
    allow_from      => ['127.0.0.1', '::1'],
    extended_status => 'On',
    status_path     => '/server-status',
  }

  class { 'apache::mod::proxy':
    allow_from => ['10.185', '192.168', '127.0.0.1', '::1'],
  }

  class { 'apache::mod::proxy_http':
  }

  class { 'apache::mod::proxy_ajp':
  }

  apache::vhost { 'git001.int.fastroi.fi_non-ssl':
    servername => 'git001.int.fastroi.fi',
    port       => 80,
    docroot    => $::apache::params::docroot,
    proxy_preserve_host => true,
    proxy_pass => [{
        'path' => '/gitblit',
        'url'  => 'http://localhost:8009/gitblit',
      }, {
        'path' => '/artifactory',
        'url'  => 'http://localhost:8089/artifactory'
      }],
  }
  
  class { 'artifactory':
  }
  
  if !defined(Package['maven']) {
    package { 'maven' :
      ensure => present,
      name => 'maven',
    }
  }
  
  file { 'Copy jenkins user cert for SSH auth':
    name   => "${users_data_path}/ssh/jenkins.keys",
    owner  => "${git_user}",
    group  => "${git_user}",
    mode   => '0600',
    source => "puppet:///modules/${module_name}/jenkins/slave_key"
  }
  
  #frprofile::fr_git_server::git_backup { "Set up git repository backups": 
  #  repository_path => $git_repositories
  #}
}

class { 'frprofile::fr_git_server': }
