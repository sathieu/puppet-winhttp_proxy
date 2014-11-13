require 'spec_helper'

describe Puppet::Type.type(:winhttp_proxy) do
  let :winhttp_proxy do
    Puppet::Type.type(:winhttp_proxy).new(:name => 'proxy', :http_proxy_server => 'proxy.example.org')
  end

  it 'should accept https_proxy_server' do
    winhttp_proxy[:https_proxy_server] = 'proxy.example.com'
    expect(winhttp_proxy[:https_proxy_server]).to eq('proxy.example.com')
  end
  it 'should not accept a name different than proxy' do
    expect {
      Puppet::Type.type(:winhttp_proxy).new(
          :name   => 'something else'
    )}.to raise_error(Puppet::Error, /Invalid value "something else". Valid values are proxy./)
  end
end

