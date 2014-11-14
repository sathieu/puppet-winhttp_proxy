require 'spec_helper'

describe Puppet::Type.type(:winhttp_proxy) do
  let :winhttp_proxy do
    Puppet::Type.type(:winhttp_proxy).new(:name => 'proxy', :proxy_server => 'proxy.example.org')
  end

  # =========================================================================
  # name
  it 'should not accept a name different than proxy' do
    expect {
      Puppet::Type.type(:winhttp_proxy).new(
          :name   => 'something else'
    )}.to raise_error(Puppet::Error, /Invalid value "something else". Valid values are proxy./)
  end

  # =========================================================================
  # proxy_server
  it 'should accept simple proxy_server' do
    proxy = 'proxy.example.com'
    winhttp_proxy[:proxy_server] = proxy
    expect(winhttp_proxy[:proxy_server]).to eq(proxy)
  end
  it 'should accept complex proxy_server' do
    proxy = 'http=proxy-cluster.example.org:3128;https=proxy_ms.example.com'
    winhttp_proxy[:proxy_server] = proxy
    expect(winhttp_proxy[:proxy_server]).to eq(proxy)
  end
  it 'should not accept an invalid wildcard proxy_server' do
    expect {
      Puppet::Type.type(:winhttp_proxy).new(
          :name         => 'proxy',
          :proxy_server => '*.example.org'
    )}.to raise_error(Puppet::Error, /proxy_server item \*.example.org is invalid. Examples: 'myproxy', 'myproxy:80', 'http=proxy.example.com'/)
  end

  # =========================================================================
  # bypass_list
  it 'should accept empty bypass_list' do
    bp = []
    winhttp_proxy[:bypass_list] = bp
    expect(winhttp_proxy[:bypass_list]).to eq(bp)
  end
  it 'should accept correct bypass_list' do
    bp = ['<local>', 'example.org']
    winhttp_proxy[:bypass_list] = bp
    expect(winhttp_proxy[:bypass_list]).to eq(bp)
  end
end

