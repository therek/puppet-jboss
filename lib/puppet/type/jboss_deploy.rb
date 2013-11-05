Puppet::Type.newtype(:jboss_deploy) do
  @doc = "Deploys and undeploys EAR/WAR artifacts on JBoss Application Server"
  ensurable

  newparam(:name) do
    desc "The JNDI resource name."
    isnamevar
    isrequired
  end

  newparam(:source) do
    desc "Path to the EAR/WAR file."
  end

  newparam(:redeploy, :boolean => true) do
    desc "Force redeployment"
    defaultto false
  end

  newproperty(:servergroups, :array_matching => :all) do
    desc "Array of server groups on which deployment should be done"
  end

  newparam(:runasdomain, :boolean => true) do
    desc "Indicate that server is in domain mode"
    defaultto true
  end
  
  newparam(:controller) do
    desc "Domain controller host:port address"
    defaultto "localhost:9999"
    validate do |value|
      if value == nil and @resource[:runasdomain]
        raise ArgumentError, "Domain controller must be provided"
      else
        super
      end
    end
  end

end