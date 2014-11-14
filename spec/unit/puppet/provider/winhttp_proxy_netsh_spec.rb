require 'spec_helper'

describe Puppet::Type.type(:winhttp_proxy).provider(:netsh) do
  before do
    described_class.stubs(:command).with(:netsh).returns 'netsh'
  end
  # =========================================================================
  # No proxy:
  #   reset proxy
  # =========================================================================
  context 'no proxy' do
    let :instances do
      output = <<-EOS



# -----------------------------------------
# WinHTTP Proxy Configuration
# -----------------------------------------
pushd winhttp

reset proxy

popd

# End of WinHTTP Proxy Configuration


      EOS
      if Puppet::PUPPETVERSION.to_f < 3.4
        Puppet::Util::SUIDManager.expects(:run_and_capture).with(['netsh', 'winhttp', 'dump']).at_least_once.returns([output, 0])
      else
        Puppet::Util::Execution.expects(:execute).with(['netsh', 'winhttp', 'dump']).at_least_once.returns(
          Puppet::Util::Execution::ProcessOutput.new(output, 0)
        )
      end
      instances = described_class.instances
    end

    it 'should have no instance' do
      expect(instances.count).to eq(0)
    end
  end

  # =========================================================================
  # No proxy -> simple proxy:
  #   reset proxy -> set proxy proxy-server="localproxy:3128"
  # =========================================================================
  context 'no proxy -> simple proxy' do
    let :resource do
      Puppet::Type.type(:winhttp_proxy).new(
        :name         => 'proxy',
        :provider     => :netsh,
        :proxy_server => 'localproxy:3128')
    end

    let :instance do
      instance = described_class.new(resource)
      instance.create
      instance
    end

    it 'should create an instance' do
      if Puppet::PUPPETVERSION.to_f < 3.4
        Puppet::Util::SUIDManager.expects(:run_and_capture).with(['netsh', 'winhttp', 'set', 'proxy', 'proxy-server="localproxy:3128"', 'bypass-list=""']).once.returns(['', 0])
      else
        Puppet::Util::Execution.expects(:execute).with(['netsh', 'winhttp', 'set', 'proxy', 'proxy-server="localproxy:3128"', 'bypass-list=""']).once.returns(
          Puppet::Util::Execution::ProcessOutput.new("", 0)
        )
      end
      instance.flush
    end
  end

  # =========================================================================
  # Simple proxy:
  #   set proxy proxy-server="myproxy:3128"
  # =========================================================================
  context 'simple proxy' do
    let :instances do

      output = <<-EOS


# -----------------------------------------
# WinHTTP Proxy Configuration
# -----------------------------------------
pushd winhttp

set proxy proxy-server="myproxy:3128"

popd

# End of WinHTTP Proxy Configuration


      EOS

      if Puppet::PUPPETVERSION.to_f < 3.4
        Puppet::Util::SUIDManager.expects(:run_and_capture).with(['netsh', 'winhttp', 'dump']).at_least_once.returns([output, 0])
      else
        Puppet::Util::Execution.expects(:execute).with(['netsh', 'winhttp', 'dump']).at_least_once.returns(
          Puppet::Util::Execution::ProcessOutput.new(output, 0)
        )
      end
      instances = described_class.instances
    end

    it 'should have no instance' do
      expect(instances.count).to eq(1)
    end

    it 'instance should be present' do
      expect(instances.first['ensure']).to eq(:present)
    end

    it 'instance should have correct proxy-server' do
      expect(instances.first['proxy_server']).to eq('myproxy:3128')
    end

    it 'instance should have correct bypass-list' do
      expect(instances.first['bypass_list']).to eq([])
    end

  end

  # =========================================================================
  # Simple proxy with bypass list:
  #   set proxy proxy-server="myproxy.example.org" bypass-list="<local>;*.example.org"
  # =========================================================================
  context 'simple proxy with bypass list' do
    let :instances do

      output = <<-EOS


# -----------------------------------------
# WinHTTP Proxy Configuration
# -----------------------------------------
pushd winhttp

set proxy proxy-server="myproxy.example.org" bypass-list="<local>;*.example.org"


popd

# End of WinHTTP Proxy Configuration

      EOS

      if Puppet::PUPPETVERSION.to_f < 3.4
        Puppet::Util::SUIDManager.expects(:run_and_capture).with(['netsh', 'winhttp', 'dump']).at_least_once.returns([output, 0])
      else
        Puppet::Util::Execution.expects(:execute).with(['netsh', 'winhttp', 'dump']).at_least_once.returns(
          Puppet::Util::Execution::ProcessOutput.new(output, 0)
        )
      end
      instances = described_class.instances
    end

    it 'should have no instance' do
      expect(instances.count).to eq(1)
    end

    it 'instance should be present' do
      expect(instances.first['ensure']).to eq(:present)
    end

    it 'instance should have correct proxy-server' do
      expect(instances.first['proxy_server']).to eq('myproxy.example.org')
    end

    it 'instance should have correct bypass-list' do
      expect(instances.first['bypass_list']).to eq([
        '<local>',
        '*.example.org'
      ])
    end

  end

  # =========================================================================
  # Different HTTP and HTTPS proxies with bypass list:
  #   set proxy proxy-server="http=proxy.example.com;https=proxy.example.org" bypass-list="*.example.org;*.example.com"
  # =========================================================================
  context 'simple proxy with bypass list' do
    let :instances do

      output = <<-EOS


# -----------------------------------------
# WinHTTP Proxy Configuration
# -----------------------------------------
pushd winhttp

set proxy proxy-server="http=proxy.example.com;https=proxy.example.org" bypass-list="*.example.org;*.example.com"

popd

# End of WinHTTP Proxy Configuration

      EOS

      if Puppet::PUPPETVERSION.to_f < 3.4
        Puppet::Util::SUIDManager.expects(:run_and_capture).with(['netsh', 'winhttp', 'dump']).at_least_once.returns([output, 0])
      else
        Puppet::Util::Execution.expects(:execute).with(['netsh', 'winhttp', 'dump']).at_least_once.returns(
          Puppet::Util::Execution::ProcessOutput.new(output, 0)
        )
      end
      instances = described_class.instances
    end

    it 'should have no instance' do
      expect(instances.count).to eq(1)
    end

    it 'instance should be present' do
      expect(instances.first['ensure']).to eq(:present)
    end

    it 'instance should have correct proxy-server' do
      expect(instances.first['proxy_server']).to eq('http=proxy.example.com;https=proxy.example.org')
    end

    it 'instance should have correct bypass-list' do
      expect(instances.first['bypass_list']).to eq([
        '*.example.org',
        '*.example.com'
      ])
    end

  end

end
