require 'rspec'
require 'rack/test'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

WebMock.disable_net_connect!

