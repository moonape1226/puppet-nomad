require 'spec_helper_acceptance'

describe 'nomad class' do

  context 'default parameters' do
    apply_manifest_opts = {
      :catch_failures => true,
      :debug          => true,
    }
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': }
        ->
        class { 'nomad':
          version     => '0.5.0',
          config_hash => {
            "bind_addr" => "0.0.0.0",
            "data_dir"  => "/opt/nomad",
            "advertise" => {
              "http" => "127.0.0.1:4646",
              "rpc"  => "127.0.0.1:4647",
              "serf" => "127.0.0.1:4648",
            },
            "server" => {
              "enabled"          => true,
              "bootstrap_expect" => 1
            }
          }
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp, apply_manifest_opts).exit_code).to_not eq(1)
      expect(apply_manifest(pp, apply_manifest_opts).exit_code).to eq(0)
    end

    describe file('/opt/nomad') do
      it { should be_directory }
    end

    describe service('nomad') do
      it { should be_enabled }
    end

    describe command('nomad version') do
      its(:stdout) { should match /Nomad v0\.5\.0/ }
    end

  end
end
