Puppet::Type.newtype(:jboss_configproperty) do
  @doc = "Generic configuration property for JBoss Application Sever"
  ensurable
  
  autorequire(:jboss_confignode) do
    [ value(:path) ]
  end
  
  newparam(:key) do
    desc "The key of the property to ensure"
    isrequired
  end

  newproperty(:value) do
    desc "The value for attribute"
  end
  
  newparam(:path) do
    desc "The JBoss configuration path to be processed"
    isnamevar
    isrequired
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full-ha"
  end

  newparam(:runasdomain, :boolean => true) do
    desc "Indicate that server is in domain mode"
    newvalues :true, :false
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