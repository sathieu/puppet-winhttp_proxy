require 'spec_helper'
describe 'winhttp_proxy' do

  context 'with defaults for all parameters' do
    it { should contain_class('winhttp_proxy') }
  end
end
