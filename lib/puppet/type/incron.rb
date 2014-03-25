Puppet::Type.newtype(:incron) do
  @doc = <<-'EOT'
    Installs and manages incron jobs. 
  EOT
  ensurable

  newproperty(:command) do
    desc "The command to execute in the incron job"
  end

  newproperty(:path) do
    desc "The path to monitor"
  end

  newproperty(:mask) do
    desc "The events to trigger on"

    def should
      if @should
        if @should.is_a? Array
          @should[0]
        else
          devfail "mask is not an array"
        end
      else
        nil
      end
    end
  end

  newproperty(:user) do
    desc "The user to run the command as."
  end

  # Autorequire the owner of the incrontab entry.
  autorequire(:user) do
    self[:user]
  end

  newparam(:name) do
    desc "The symbolic name of the incron job. This name
      is used for human reference only and is generated automatically
      for incron jobs found on the system."
  end

  newproperty(:target) do
    desc "The username that will own the incron entry. Defaults to
    the value of $USER for the shell that invoked Puppet, or root if $USER
    is empty."

    defaultto {
      if provider.is_a?(@resource.class.provider(:incrontab))
        if val = @resource.should(:user)
          return "/var/spool/incron/#{resource[:user]}" 
        else
          raise ArgumentError,
            "You must provide a username with incrontab entries"
        end 
      elsif provider.class.ancestors.include?(Puppet::Provider::ParsedFile)
        provider.class.default_target
      else
        nil 
      end 
    }   
  end
end
