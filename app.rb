require 'sinatra'
require 'sinatra/json'
require 'logger'
require_relative 'lib/call_flow'

before do
  if request.request_method == "POST"
    unless request.content_type&.include?('application/json')
      halt 415, { error: 'Content Type must be application/json' }.to_json
    end
  end
end

get '/health' do
  json status: 'ok'
end

post '/call_details' do
  request_body = request.body.read
  logger.info "Received body: #{request_body}"

  if request_body.empty?
    halt 400, json(error: 'Empty request body')
  end

  begin
    data = JSON.parse(request_body)
    @call_flow = CallFlow.new(data)
    @call_flow.handle_call
    status 200
    body nil
  rescue JSON::ParserError => e
    logger.error "JSON parsing error: #{e.message}" # Debug log
    halt 400, json(error: 'Invalid JSON format', details: e.message)
  rescue Exception => e
    logger.error "CallFlow error: #{e.message}" # Debug log
    halt 500, json(error: 'CallFlow error', details: e.message)
  end
end

# Sinatra uses this to identify the app when starting with a Rack server like Puma
Sinatra::Application.run if __FILE__ == $0