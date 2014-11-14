Puppet::Type.newtype(:winhttp_proxy) do
  @doc = %q{Manage Windows system proxy (i.e. WinHTTP Proxy) settings.
  }

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc %q{Resource name. Should be "proxy".}
    isnamevar
    newvalues('proxy')
  end

  newproperty(:proxy_server) do
    desc %{Proxy server for use for http and/or https protocol.

    Examples:
    * myproxy
    * myproxy:80
    * http=proxy.example.com;https=proxy.example.org}
    validate do |values|
      values.split(';').each do |value|
        unless value =~ /^[=a-z._-]+(:\d+)?$/
          raise ArgumentError, "proxy_server item %s is invalid. Examples: 'myproxy', 'myproxy:80', 'http=proxy.example.com'" % value
        end
      end
    end
  end

  newproperty(:bypass_list, :array_matching => :all) do
    desc %q{An array of sites that should be visited bypassing the proxy
      (use "<local>" to bypass all short name hosts).

    Examples:
    * ['*.foo.com']
    * ['<local>', 'example.org']}
    validate do |value|
      unless value =~ /^[*a-z._-]+$/ or value == "<local>"
        raise ArgumentError, "bypass_list item %s is invalid. Examples: '*.foo.com', 'bar', '<local>'" % value
      end
    end
  end
end
