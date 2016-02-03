require 'spec_helper_puppet'

describe 'jboss::interface', :type => :define do
  basic_bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual"
  ]
  legacy_bind_variables_list = [ "any-ipv4-address", "any-ipv6-address" ]

  let(:generic_params) {{ :any_address => 'true' }}
  let(:any_addr_property) {{ 'any-address' => 'true' }}

  let(:title)  { 'test-interface' }
  let(:facts)  { generic_facts.merge(runtime_facts) }
  let(:params) { generic_params.merge(runtime_params) }
  let(:basic_bind_variables) { Hash[basic_bind_variables_list.map {|x| [x, :undef]}] }
  let(:legacy_bind_variables) { Hash[legacy_bind_variables_list.map {|x| [x, :undef]}] }

  shared_examples 'completly working define' do
    context 'with defaults' do
      let(:runtime_facts)  {{}}
      let(:runtime_params) {{}}

      it { is_expected.to compile }
      it { is_expected.to contain_class 'jboss::params' }
      it { is_expected.to contain_class 'jboss' }
      it { is_expected.to contain_class 'jboss::internal::augeas' }
      it { is_expected.to contain_class 'jboss::internal::runtime' }
      it { is_expected.to contain_jboss__interface(title) }
      it { is_expected.to contain_jboss__interface('public') }
      basic_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
        it { is_expected.to contain_augeas("interface public rm #{var}") }
        it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}")}
        it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}")}
      end
      it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:any-address")}
      it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address")}
      it { is_expected.to contain_augeas("ensure present interface #{title}") }
      it { is_expected.to contain_augeas("ensure present interface public") }
      it { is_expected.to contain_augeas("interface #{title} set any-address") }
      it { is_expected.to contain_augeas("interface public set any-address") }
    end

    context 'with jboss_running => true and runasdomain => false parameters set' do
      let(:runtime_facts)  {{ :jboss_running => 'true' }}
      let(:runtime_params) {{ :runasdomain => 'false' }}
      let(:pre_condition)  { "class { jboss: product => '#{product}', version => '#{version}'}" }

      context 'with product => wildfly and version => 9.0.2.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'9.0.2.Final'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(any_addr_property)
          )}
      end
      context 'with product => wildfly and version => 8.2.1.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'8.2.1.Final'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
          )}
      end
      context 'with product => jboss-eap and version => 7.0.0.Beta parameters set' do
        let(:product) {'jboss-eap'}
        let(:version) {'7.0.0.Beta'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(any_addr_property)
          )}
      end
      context 'with product => wildfly and version => 15.0.0.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'15.0.0.Final'}

        it { is_expected.to raise_error(Puppet::Error, /Unsupported version wildfly 15.0.0.Final/) }
      end
    end

    context 'with jboss_running => false and runasdomain => false parameters set' do
      let(:runtime_facts)  {{ :jboss_running => 'false' }}
      let(:runtime_params) {{ :runasdomain => 'false' }}
      let(:pre_condition)  { "class { jboss: product => '#{product}', version => '#{version}'}" }

      context 'with product => wildfly and version => 9.0.2.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'9.0.2.Final'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(any_addr_property)
            )}
        end
      end
      context 'with product => wildfly and version => 8.2.1.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'8.2.1.Final'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
        end
        legacy_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_augeas("interface public rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
          it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
        end
      end
      context 'with product => jboss-eap and version => 7.0.0.Beta parameters set' do
        let(:product) {'jboss-eap'}
        let(:version) {'7.0.0.Beta'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(any_addr_property)
            )}
        end
      end
    end
  end

  context 'On RedHat os family' do
    let(:generic_facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end

    it_behaves_like 'completly working define'
  end

  context 'On Debian os family' do
    let(:generic_facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version
      }
    end

    it_behaves_like 'completly working define'
  end
end
