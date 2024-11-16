require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require_relative '../app'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Set up common stubs before each test
  before do
    # Stub APCO service request
    stub_request(:get, %r{http://apco_service:4000/api/v1/call_types/.*})
      .to_return(
        status: 200,
        body: {
          code: '101',
          description: 'Medical Emergency',
          notes: 'Requires immediate response'
        }.to_json
      )

    # Stub call logger request
    stub_request(:post, 'http://call_logger:3333/calls')
      .to_return(status: 200, body: 'Call logged successfully')
  end

  describe 'GET /health' do
    it 'returns a JSON response with status ok' do
      get '/health'
      expect(last_response).to be_ok
      expect(last_response.content_type).to include('application/json')
      expect(JSON.parse(last_response.body)).to eq('status' => 'ok')
    end
  end

  describe 'POST /call_details' do
    let(:valid_post_data) do
      {
        caller: 'John Doe',
        duration: 120,
        call_type: 'MEDICAL'
      }
    end

    context 'with valid data' do
      it 'returns 200 with no data' do
        post '/call_details', valid_post_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
        expect(last_response.body).to be_empty
      end
    end

    context 'with invalid data' do
      it 'returns 400 when JSON is malformed' do
        post '/call_details', 'invalid json', { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to have_key('error')
      end
    end

    context 'when CallFlow raises an error' do
      before do
        stub_request(:get, %r{http://apco_service:4000/api/v1/call_types/.*})
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns 500 with error message' do
        post '/call_details', valid_post_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to have_key('error')
      end
    end

    context 'with different content types' do
      it 'returns 415 when content-type is not application/json' do
        post '/call_details', valid_post_data.to_json, { 'CONTENT_TYPE' => 'text/plain' }
        expect(last_response.status).to eq(415)
        expect(JSON.parse(last_response.body)).to have_key('error')
      end
    end
  end
end
