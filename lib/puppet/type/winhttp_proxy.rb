Puppet::Type.newtype(:winhttp_proxy) do
  @doc = %q{Manage Windows system proxy (i.e. WinHTTP Proxy) settings.
  }

  ensurable

  newparam(:name) do
    desc %q{Resource name. Should be "proxy".}
    isnamevar
    newvalues(:proxy)
  end

  newproperty(:http_proxy_server) do
    desc "Proxy server for use for http protocol."
    validate do |value|
      unless value =~ /^[a-z.]+$/
        raise ArgumentError, "%s is not a valid proxy server" % value
      end
    end
  end

  newproperty(:https_proxy_server) do
    desc "Proxy server for use for https protocol."
    validate do |value|
      unless value =~ /^[a-z.]+$/
        raise ArgumentError, "%s is not a valid proxy server" % value
      end
    end
  end

  newproperty(:bypass_list, :array_matching => :all) do
    desc %q{An array of sites that should be visited bypassing the proxy
      (use "<local>" to bypass all short name hosts).}
    validate do |values|
      unless values.is_a? Array
        raise ArgumentError, "bypass_list should be an array"
      end
      values.each do |value|
        unless value =~ /^[a-z.*]+$/ or value == "<local>"
          raise ArgumentError, "bypass_list item %s is invalid. Examples: '*.foo.com', 'bar', '<local>'" % value
        end
      end
    end
  end
end
