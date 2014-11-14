Puppet::Type.type(:winhttp_proxy).provide(:netsh) do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  def self.netsh_command
    if File.exists?("#{ENV['SYSTEMROOT']}\\SysWOW64\\netsh.exe")
      "#{ENV['SYSTEMROOT']}\\SysWOW64\\netsh.exe"
    elsif File.exists?("#{ENV['SYSTEMROOT']}\\System32\\netsh.exe")
      "#{ENV['SYSTEMROOT']}\\System32\\netsh.exe"
    else
      'netsh.exe'
    end
  end

  initvars
  commands :netsh => netsh_command

  def self.instances
    proxy = {
      'ensure' => :absent
    }
    cmd = [ command(:netsh), 'winhttp', 'dump' ]
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
        proxy = {
          'ensure' => :absent
        }
        next
      end
      if context == [ 'winhttp' ] and line =~ /^set proxy proxy-server="([^"]+)"( bypass-list="([^"]+)")?$/
        proxy = {
          'ensure'        => :present,
          'proxy_server'  => $1,
          'bypass_list'   => [],
        }
        if $3
          proxy['bypass_list'] = $3.split(';')
        end
        instances << proxy
        next
      end
        proxy = {
          'ensure'        => :present,
          'proxy_server'  => line,
          'bypass_list'   => [],
        }
        instances << proxy
      Puppet.warning('Unable to parse line %s' % line)
    end
    instances
  end

  # Getters
  def proxy_server
    @property_hash[:proxy_server]
  end
  def bypass_list
    @property_hash[:bypass_list]
  end

  # Setters
  def proxy_server=(should)
    @property_hash[:proxy_server] = should
  end
  def bypass_list=(should)
    @property_hash[:bypass_list] = should
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
    cmd = [ command(:netsh), 'winhttp', 'set', 'proxy', 'proxy-server="%s"' % @property_hash[:proxy_server], 'bypass-list="%s"' % @property_hash[:bypass_list] ]
    if Puppet::PUPPETVERSION.to_f < 3.4
      raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    else
      raw = Puppet::Util::Execution.execute(cmd)
      status = raw.exitstatus
    end
  end
end
