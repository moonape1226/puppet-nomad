require 'spec_helper'

describe 'nomad' do

  RSpec.configure do |c|
    c.default_facts = {
      :architecture           => 'x86_64',
      :operatingsystem        => 'Ubuntu',
      :osfamily               => 'Debian',
      :operatingsystemrelease => '10.04',
      :kernel                 => 'Linux',
      :ipaddress_lo           => '127.0.0.1',
      :nomad_version          => 'unknown',
    }
  end

  # Installation Stuff
  context 'On an unsupported architecture' do
    let(:facts) {{ :architecture => '__ARCHITECTURE__' }}
    let(:params) {{
      :install_method => 'package'
    }}
    it { expect { should compile }.to raise_error(/Unsupported kernel architecture:/) }
  end

  context 'When passing a non-bool as manage_group' do
    let(:params) {{
      :manage_group => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When passing a non-bool as manage_service' do
    let(:params) {{
      :manage_service => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When passing a non-bool as manage_user' do
    let(:params) {{
      :manage_user => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When passing a non-integer as pretty_config_indent' do
    let(:params) {{
      :pretty_config_indent => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/Expected first argument to be an Integer/) }
  end

  context 'When passing a non-bool as pretty_config' do
    let(:params) {{
      :pretty_config => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When not specifying purge_config_dir' do
    it { should contain_file('/etc/nomad').with(:purge => true, :recurse => true) }
  end

  context 'When passing a non-bool as purge_config_dir' do
    let(:params) {{
      :purge_config_dir => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When purge_config_dir disabled' do
    let(:params) {{
      :purge_config_dir => false
    }}
    it { should contain_class('nomad::config').with(:purge => false) }
  end

  context 'When not specifying restart_on_change' do
    it { should contain_class('nomad::config').that_notifies(['Class[nomad::run_service]']) }
  end

  context 'When passing a non-bool as restart_on_change' do
    let(:params) {{
      :restart_on_change => '__STRING__'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When restart_on_change disabled' do
    let(:params) {{
      :restart_on_change => false
    }}
    it { should_not contain_class('nomad::config').that_notifies(['Class[nomad::run_service]']) }
  end

  context 'When requesting to install via a package with defaults' do
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('nomad').with(:ensure => :latest) }
  end

  context 'When requesting to install via a custom package and version' do
    let(:params) {{
      :install_method => 'package',
      :package_ensure => '__PACKAGE_ENSURE__',
      :package_name   => '__PACKAGE_NAME__'
    }}
    it { should contain_package('__PACKAGE_NAME__').with(:ensure => '__PACKAGE_ENSURE__') }
  end

  context "When installing via URL by default" do
    it { should contain_archive('/opt/puppet-archive/nomad-0.5.0.zip').with(:source => 'https://releases.hashicorp.com/nomad/0.5.0/nomad_0.5.0_linux_amd64.zip') }
    it { should contain_file('/opt/puppet-archive').with(:ensure => :directory) }
    it { should contain_file('/opt/puppet-archive/nomad-0.5.0').with(:ensure => :directory) }
    it { should contain_file('/usr/local/bin/nomad').that_notifies('Class[nomad::run_service]') }
  end

  context "When installing via URL with a special archive_path" do
    let(:params) {{
      :archive_path   => '/usr/share/puppet-archive',
    }}
    it { should contain_archive('/usr/share/puppet-archive/nomad-0.5.0.zip').with(:source => 'https://releases.hashicorp.com/nomad/0.5.0/nomad_0.5.0_linux_amd64.zip') }
    it { should contain_file('/usr/share/puppet-archive').with(:ensure => :directory) }
    it { should contain_file('/usr/share/puppet-archive/nomad-0.5.0').with(:ensure => :directory) }
    it { should contain_file('/usr/local/bin/nomad').that_notifies('Class[nomad::run_service]') }
  end

  context "When installing by archive via URL and current version is already installed" do
    let(:facts) {{ :nomad_version => '0.5.0' }}
    it { should contain_archive('/opt/puppet-archive/nomad-0.5.0.zip').with(:source => 'https://releases.hashicorp.com/nomad/0.5.0/nomad_0.5.0_linux_amd64.zip') }
    it { should contain_file('/usr/local/bin/nomad') }
    it { should_not contain_notify(['Class[nomad::run_service]']) }
  end

  context "When installing via URL by with a special version" do
    let(:params) {{
      :version   => '42',
    }}
    it { should contain_archive('/opt/puppet-archive/nomad-42.zip').with(:source => 'https://releases.hashicorp.com/nomad/42/nomad_42_linux_amd64.zip') }
    it { should contain_file('/usr/local/bin/nomad').that_notifies('Class[nomad::run_service]') }
  end

  context "When installing via URL by with a custom url" do
    let(:params) {{
      :download_url   => '__DOWNLOAD_URL__',
    }}
    it { should contain_archive('/opt/puppet-archive/nomad-0.5.0.zip').with(:source => '__DOWNLOAD_URL__') }
    it { should contain_file('/usr/local/bin/nomad').that_notifies('Class[nomad::run_service]') }
  end

  context 'When requesting to install via a package with defaults' do
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('nomad').with(:ensure => :latest) }
  end

  context 'When requesting to not to install' do
    let(:params) {{
      :install_method => 'none'
    }}
    it { should_not contain_package('nomad') }
    it { should_not contain_archive('/opt/puppet-archive/nomad-0.5.0.zip') }
  end

  context "By default, a user and group should be installed" do
    it { should contain_user('nomad').with(:ensure => :present) }
    it { should contain_group('nomad').with(:ensure => :present) }
  end

  context "When data_dir is provided" do
    let(:params) {{
      :config_hash => {
        'data_dir' => '/dir1',
      },
    }}
    it { should contain_file('/dir1').with(:ensure => :directory) }
  end

  context "When data_dir not provided" do
    it { should_not contain_file('/dir1').with(:ensure => :directory) }
  end

  context 'The bootstrap_expect in config_hash is an int' do
    let(:params) {{
      :config_hash => {
        'server' => { 'bootstrap_expect' => '5' }
      }
    }}
    it { should contain_file('nomad config.json').with_content(/"bootstrap_expect":5/) }
    it { should_not contain_file('nomad config.json').with_content(/"bootstrap_expect":"5"/) }
  end

  context 'Config_defaults is used to provide additional config' do
    let(:params) {{
      :config_defaults => {
          'data_dir' => '/dir1',
      },
      :config_hash => {
          'server' => { 'bootstrap_expect' => '5' }
      }
    }}
    it { should contain_file('nomad config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('nomad config.json').with_content(/"data_dir":"\/dir1"/) }
  end

  context 'Config_defaults is used to provide additional config and is overridden' do
    let(:params) {{
      :config_defaults => {
          'data_dir' => '/dir1',
          'ports' => {
            'http' => 4646,
            'rpc'  => '4647',
          },
      },
      :config_hash => {
          'server' => { 'bootstrap_expect' => '5' },
          'ports' => {
            'http'  => -1,
            'serf' => 4648,
          },
      }
    }}
    it { should contain_file('nomad config.json').with_content(/"bootstrap_expect":5/) }
    it { should contain_file('nomad config.json').with_content(/"data_dir":"\/dir1"/) }
    it { should contain_file('nomad config.json').with_content(/"http":-1/) }
    it { should contain_file('nomad config.json').with_content(/"rpc":4647/) }
    it { should contain_file('nomad config.json').with_content(/"serf":4648/) }
  end

  context 'When pretty config is true' do
    let(:params) {{
      :pretty_config => true,
      :config_hash => {
          'server' => { 'bootstrap_expect' => '5' },
          'ports' => {
            'http'  => -1,
            'rpc' => 4647,
          },
      }
    }}
    it { should contain_file('nomad config.json').with_content(/"server": \{/) }
    it { should contain_file('nomad config.json').with_content(/"bootstrap_expect": 5/) }
    it { should contain_file('nomad config.json').with_content(/"ports": \{/) }
    it { should contain_file('nomad config.json').with_content(/"http": -1,/) }
    it { should contain_file('nomad config.json').with_content(/"rpc": 4647/) }
  end

  context "When asked not to manage the user" do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('nomad') }
  end

  context "When asked not to manage the group" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('nomad') }
  end

  context "When asked not to manage the service" do
    let(:params) {{ :manage_service => false }}

    it { should_not contain_service('nomad') }
  end

  context "With a custom username" do
    let(:params) {{
      :user => 'custom_nomad_user',
      :group => 'custom_nomad_group',
    }}
    it { should contain_user('custom_nomad_user').with(:ensure => :present) }
    it { should contain_group('custom_nomad_group').with(:ensure => :present) }
    it { should contain_file('/etc/init/nomad.conf').with_content(/env USER=custom_nomad_user/) }
    it { should contain_file('/etc/init/nomad.conf').with_content(/env GROUP=custom_nomad_group/) }
  end

  context "Config with custom file mode" do
    let(:params) {{
      :user  => 'custom_nomad_user',
      :group => 'custom_nomad_group',
      :config_mode  => '0600',
    }}
    it { should contain_file('nomad config.json').with(
      :owner => 'custom_nomad_user',
      :group => 'custom_nomad_group',
      :mode  => '0600'
    )}
  end

  context "When using init" do
    let (:params) {{
      :init_style => 'init'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('nomad').with_init_style('init') }
  end

  context "When using debian" do
    let (:params) {{
      :init_style => 'debian'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('nomad').with_init_style('debian') }
  end

  context "When using upstart" do
    let (:params) {{
      :init_style => 'upstart'
    }}
    let (:facts) {{
      :ipaddress_lo => '127.0.0.1'
    }}
    it { should contain_class('nomad').with_init_style('upstart') }
  end

  context "On a redhat 6 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '6.5'
    }}

    it { should contain_class('nomad').with_init_style('redhat') }
    it { should contain_file('/etc/init.d/nomad').with_content(/daemon --user=nomad/) }
  end

  context "On an Archlinux based OS" do
    let(:facts) {{
      :operatingsystem => 'Archlinux',
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/nomad.service').with_content(/nomad agent/) }
  end

  context "On an Amazon based OS" do
    let(:facts) {{
      :operatingsystem => 'Amazon',
      :operatingsystemrelease => '3.10.34-37.137.amzn1.x86_64'
    }}

    it { should contain_class('nomad').with_init_style('redhat') }
    it { should contain_file('/etc/init.d/nomad').with_content(/daemon --user=nomad/) }
  end

  context "On a redhat 7 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '7.0'
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/nomad.service').with_content(/nomad agent/) }
  end

  context "On a fedora 20 based OS" do
    let(:facts) {{
      :operatingsystem => 'Fedora',
      :operatingsystemrelease => '20'
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/nomad.service').with_content(/nomad agent/) }
  end

  context "On hardy" do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease  => '8.04',
    }}

    it { should contain_class('nomad').with_init_style('debian') }
    it {
      should contain_file('/etc/init.d/nomad') \
        .with_content(/start-stop-daemon .* \$DAEMON/) \
        .with_content(/DAEMON_ARGS="agent/) \
        .with_content(/--user \$USER/)
    }
  end

  context "On a Ubuntu Vivid 15.04 based OS" do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '15.04'
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/nomad.service').with_content(/nomad agent/) }
  end

  context "When asked not to manage the init_style" do
    let(:params) {{ :init_style => 'unmanaged' }}
    it { should contain_class('nomad').with_init_style('unmanaged') }
    it { should_not contain_file("/etc/init.d/nomad") }
    it { should_not contain_file("/lib/systemd/system/nomad.service") }
  end

  context "On squeeze" do
    let(:facts) {{
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '7.1'
    }}

    it { should contain_class('nomad').with_init_style('debian') }
  end

  context "On opensuse" do
    let(:facts) {{
      :operatingsystem => 'OpenSuSE',
      :operatingsystemrelease => '13.1'
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
  end

  context "On SLED" do
    let(:facts) {{
      :operatingsystem => 'SLED',
      :operatingsystemrelease => '11.4'
    }}

    it { should contain_class('nomad').with_init_style('sles') }
  end

  context "On SLES" do
    let(:facts) {{
      :operatingsystem => 'SLES',
      :operatingsystemrelease => '12.0'
    }}

    it { should contain_class('nomad').with_init_style('systemd') }
  end

  # Config Stuff
  context "With extra_options" do
    let(:params) {{
      :extra_options => '-some-extra-argument'
    }}
    it { should contain_file('/etc/init/nomad.conf').with_content(/\$NOMAD -S -- agent .*-some-extra-argument$/) }
  end

end
