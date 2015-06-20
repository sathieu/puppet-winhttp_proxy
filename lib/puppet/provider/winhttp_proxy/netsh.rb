Puppet::Type.type(:winhttp_proxy).provide(:netsh, :parent => Puppet::Provider) do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  # Actually, Windows as different settings under 32-bit or 64-bit
  # How can people pay for this crappy software?!
  # FIXME Handle the WOW64 proxy too
  def self.netsh_command
    if File.exists?("#{ENV['SYSTEMROOT']}\\System32\\netsh.exe")
      "#{ENV['SYSTEMROOT']}\\System32\\netsh.exe"
    else
      'netsh.exe'
    end
  end

  initvars
  mk_resource_methods

  commands :netsh => netsh_command

  def self.instances
    proxy = {
      'ensure' => :absent
    }
    cmd = [ 'cmd.exe', '/c', command(:netsh), 'winhttp', 'dump' ]
    if Puppet::PUPPETVERSION.to_f < 3.4
      raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    else
      raw = Puppet::Util::Execution.execute(cmd)
      status = raw.exitstatus
    end
    instances = []
    context = []
    raw.each_line() do |line|
      next if line =~ /^\s*(#|$)/
      if line =~ /^pushd (.*)$/
        context << $1
        next
      end
      if line =~ /^popd$/
        context.pop
        next
      end
      if context == [ 'winhttp' ] and line =~ /^reset proxy$/
        next
      end
      if context == [ 'winhttp' ] and line =~ /^set proxy proxy-server="([^"]+)"( bypass-list="([^"]+)")?$/
        proxy = {
          :name         => :proxy,
          :ensure       => :present,
          :proxy_server => $1,
          :bypass_list  => [],
        }
        if $3
          proxy[:bypass_list] = $3.split(';')
        end
        instances << new(proxy)
        next
      end
      Puppet.warning('Unable to parse line %s' % line)
    end
    instances
  end

  def self.prefetch(resources)
    instances.each do |instance|
      if proxy = resources[instance.name]
        proxy.provider = instance
      end
    end
  end

  # Exists
  def exists?
    !(@property_hash[:ensure] == :absent or @property_hash.empty?)
  end

  # Keep resource properties, flush will actually apply
  def create
    @property_hash = {
      :ensure       => :present,
      :proxy_server => @resource[:proxy_server],
      :bypass_list  => @resource[:bypass_list]
    }
  end

  # Unlike create we actually immediately delete the item.
  def destroy
    netsh('winhttp', 'reset', 'proxy')
    @property_hash.clear
  end

  def flush
    cmd = [ 'cmd.exe', '/c', command(:netsh), 'winhttp', 'set', 'proxy', 'proxy-server="%s"' % @property_hash[:proxy_server], 'bypass-list="%s"' % @property_hash[:bypass_list].join(";") ]
    if Puppet::PUPPETVERSION.to_f < 3.4
      raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    else
      raw = Puppet::Util::Execution.execute(cmd)
      status = raw.exitstatus
    end
  end
end
