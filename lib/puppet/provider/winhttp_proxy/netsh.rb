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
end
