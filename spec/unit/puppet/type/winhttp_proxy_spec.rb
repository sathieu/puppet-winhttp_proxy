describe Puppet::Type.type(:winhttp_proxy) do
  let :winhttp_proxy do
    Puppet::Type.type(:winhttp_proxy).new(:name => 'proxy', :http_proxy_server => 'proxy.example.org')
  end

  it 'should accept https_proxy_server' do
    winhttp_proxy[:https_proxy_server] = 'proxy.example.com'
    expect(winhttp_proxy[:https_proxy_server]).to eq('proxy.example.com')
  end
end

