require "spec_helper"

describe 'jboss_type_version' do

  context 'given invalid number of parameters' do
    it do
      should run.
        with_params().and_raise_error(
          Puppet::ParseError,
          'jboss_type_version(): Given invalid number of parameters(0 instead of 1)'
        )
    end
  end

  context 'given as-7.1.1.Final it should return as' do
    let(:input) { 'as-7.1.1.Final' }
    it do
      should run.
        with_params(input).and_return('as')
    end
  end

  context 'given invalid input' do
    let(:input) { 'asd' }
    it do
      should run.
        with_params(input).and_return(nil)
    end
  end
end
