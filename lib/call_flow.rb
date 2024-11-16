require 'net/http'
require 'json'

class CallFlow
  attr_reader :attributes, :call_type

  def initialize(attributes)
    @attributes = attributes
    @call_type = URI.encode_www_form_component(attributes['call_type'])
  end

  def post_format
    { 'call' => @attributes }
  end

  def handle_call
    apco_info = fetch_apco_info
    @attributes[:apco_code] = apco_info['code']
    @attributes[:apco_description] = apco_info['description']
    @attributes[:apco_notes] = apco_info['notes']
    puts "Full Call Information: #{attributes.inspect}"
    log_call
  end

  private

  def log_call
    # Use the service name and internal port for call_logger
    url = URI('http://call_logger:3333/calls') # assuming 'web' is the service name for call_logger
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = post_format.to_json

    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      puts "Call logged successfully: #{response.body}"
    else
      puts "Failed to log call: #{response.code} - #{response.message}"
    end
  rescue StandardError => e
    puts "Error logging call: #{e.message}"
  end

  def fetch_apco_info
    # Use the service name and internal port for apco_incident_types
    url = URI("http://apco_service:4000/api/v1/call_types/#{@call_type}") # assuming 'web' is the service name for apco_incident_types

    # Make the HTTP request
    response = Net::HTTP.get_response(url)

    # Handle the response
    raise "Error fetching APCO info: #{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Error parsing APCO response: #{e.message}"
  end
end
