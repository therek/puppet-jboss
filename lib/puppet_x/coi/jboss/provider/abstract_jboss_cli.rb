# -*- coding: utf-8 -*-
require_relative '../configuration'
require 'tempfile'

# Base class for all JBoss providers
class Puppet_X::Coi::Jboss::Provider::AbstractJbossCli < Puppet::Provider

  DEFAULT_SHELL_EXECUTOR = Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor.new

  # Default constructor that will also initialize 3 external object, system_runner, compilator and command executor
  def initialize(resource=nil)
    super(resource)
    @compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new
    @cli_executor = nil
    ensure_cli_executor
  end

  @@bin = "bin/jboss-cli.sh"
  @@contents = nil

  # Method that returns jboss-cli command path
  # @return {String} jboss-cli command path
  def jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    path
  end

  # CONFIGURATION VALUES

  # Method that returns jboss home value
  # @return {String} home value
  def jbosshome
    Puppet_X::Coi::Jboss::Configuration::config_value :home
  end

  def jbosslog
    Puppet_X::Coi::Jboss::Configuration::config_value :console_log
  end

  def config_runasdomain
    Puppet_X::Coi::Jboss::Configuration::config_value :runasdomain
  end

  def config_controller
    Puppet_X::Coi::Jboss::Configuration::config_value :controller
  end

  def config_profile
    Puppet_X::Coi::Jboss::Configuration::config_value :profile
  end


  # TODO: Uncomment for defered provider confinment after droping support for Puppet < 3.0
  # commands :jbosscli => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli.jbossclibin

  def runasdomain?
    @resource[:runasdomain]
  end

  # Method that delegates execution of command
  # @param {String} typename is a name of resource
  # @param {String} cmd jboss command that will be executed
  def bringUp(typename, cmd)
    executeWithFail(typename, cmd, 'to create')
  end

  # Method that delegates execution of command
  # @param {String} typename is a name of resource
  # @param {String} cmd jboss command that will be executed
  def bringDown(typename, cmd)
     executeWithFail(typename, cmd, 'to remove')
  end

  # Method that configures every variable that is needed to execute the provided command
  # @param {String} jbosscmd jboss command that will be executed
  def execute(jbosscmd)
    retry_count = @resource[:retry]
    retry_timeout = @resource[:retry_timeout]
    ctrlcfg = controllerConfig @resource
    @cli_executor.run_command(jbosscmd, runasdomain?, ctrlcfg, retry_count, retry_timeout)
  end

  def executeWithoutRetry(jbosscmd)
    ctrlcfg = controllerConfig @resource
    @cli_executor.run_command(jbosscmd, runasdomain?, ctrlcfg, 0, 0)
  end

  def executeAndGet(jbosscmd)
    ctrlcfg = controllerConfig @resource
    executeAndGetResult(jbosscmd, runasdomain?, ctrlcfg, 0, 0)
  end

  def executeWithFail(typename, cmd, way)
    executed = execute(cmd)
    if not executed[:result]
      ex = "\n#{typename} failed #{way}:\n[CLI command]: #{executed[:cmd]}\n[Error message]: #{executed[:lines]}"
      if not $add_log.nil? and $add_log > 0
        ex = "#{ex}\n#{printlog $add_log}"
      end
      raise ex
    end
    executed
  end

  def compilecmd cmd
    @compilator.compile(@resource[:runasdomain], @resource[:profile], cmd)
  end

  def executeAndGetResult(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @cli_executor.executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  # Method that will prepare and delegate execution of command
  def run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @cli_executor.run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  def controllerConfig resource
      conf = {
        :controller  => resource[:controller],
        :ctrluser    => resource[:ctrluser],
        :ctrlpasswd  => resource[:ctrlpasswd],
      }
      conf
  end

  def jboss_product
    @cli_executor.jboss_product
  end

  def jbossas?
    @cli_executor.jbossas?
  end

  def timeout_cli
    @cli_executor.timeout_cli
  end

  def setattribute(path, name, value)
    escaped = value.nil? ? nil : escape(value)
    setattribute_raw(path, name, escaped)
  end

  def setattribute_raw(path, name, value)
    Puppet.debug "#{name.inspect} setting to #{value.inspect} for path: #{path}"
    if value.nil?
      cmd = "#{path}:undefine-attribute(name=\"#{name.to_s}\")"
    else
      cmd = "#{path}:write-attribute(name=\"#{name.to_s}\", value=#{value})"
    end

    cmd = "/profile=#{@resource[:profile]}#{cmd}" if runasdomain?

    res = executeAndGet(cmd)
    Puppet.debug("Setting attribute response: #{res.inspect}")
    if not res[:result]
      raise "Cannot set #{name} for #{path}: #{res[:data]}"
    end
    @property_hash[name] = value
  end

  def trace method
    Puppet.debug '%s[%s] > IN > %s' % [self.class, @resource[:name], method]
  end

  def traceout method, retval
    Puppet.debug '%s[%s] > OUT > %s: %s' % [self.class, @resource[:name], method, retval.inspect]
  end

  def escape value
    if value.respond_to? :to_str
      str = value.gsub(/([^\\])\"/, '\1\\"')
    else
      str = value
    end
    str.inspect
  end

  def shell_executor=(shell_executor)
    @cli_executor.shell_executor = shell_executor
  end

  def shell_executor
    @cli_executor.shell_executor
  end

  def execution_state_wrapper=(execution_state_wrapper)
    @cli_executor.execution_state_wrapper = execution_state_wrapper
  end

  protected

  def ensure_cli_executor
    if @cli_executor.nil?
      execution_state_wrapper = Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper.new(DEFAULT_SHELL_EXECUTOR)
      @cli_executor = Puppet_X::Coi::Jboss::Internal::CliExecutor.new(execution_state_wrapper)
    end
    @cli_executor
  end
end
