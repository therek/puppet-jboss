require 'tempfile'

class Puppet::Provider::Jbosscli < Puppet::Provider

  @@bin = "bin/jboss-cli.sh"

  def jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    return path
  end

  def jbosshome
    home=`grep 'JBOSS_HOME=' /etc/jboss-as/jboss-as.conf 2>/dev/null | cut -d '=' -f 2`
    home.strip!
    return home
  end

  #commands :jbosscli => jbossclibin

  def execute(passed_args)
    file = Tempfile.new('jbosscli')
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') {|f| f.write(passed_args + "\n") }

    ENV['JBOSS_HOME'] = self.jbosshome
    cmd = "#{self.jbossclibin} --connect --file=#{path}"
    if(resource[:runasdomain] == true )
      cmd = "#{cmd} --controller=#{resource[:controller]}"
    end

    Puppet.debug("JBOSS_HOME: " + self.jbosshome)
    Puppet.debug("Wykonywana komenda: " + cmd)
    Puppet.debug("Komenda do JBoss-cli: " + passed_args)
    lines = `#{cmd}`
    result = $?
    Puppet.debug("Output from jbosscli: " + lines)
    Puppet.debug("Result from jbosscli: " + result.inspect)
    # deletes the temp file
    File.unlink(path)
    return {
      :result => result.exitstatus == 0,
      :lines => lines
    }
  end

  def execute_datasource(passed_args)
    ret = execute(passed_args)
    if ret[:result] == false
        return false
    end

    #wskazanie typu dla undefined
    undefined = nil
    evalines = eval(ret[:lines])
    return {
      :result  => evalines["outcome"] == "success",
      :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
    }
  end
end
