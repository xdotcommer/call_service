require_relative 'spec_helper'
require_relative '../lib/call_flow'

RSpec.describe CallFlow do
  let(:call_attributes) do
    {
      'call_type' => 'MEDICAL',
      'caller_name' => 'John Doe',
      'location' => '123 Main St'
    }
  end

  let(:apco_response) do
    {
      'code' => '101',
      'description' => 'Medical Emergency',
      'notes' => 'Requires immediate response'
    }
  end

  let(:expected_logger_body) do
    {
      'call' => {
        'call_type' => 'MEDICAL',
        'caller_name' => 'John Doe',
        'location' => '123 Main St',
        'apco_code' => '101',
        'apco_description' => 'Medical Emergency',
        'apco_notes' => 'Requires immediate response'
      }
    }
  end

  let(:call_flow) { described_class.new(call_attributes) }

  before do
    WebMock.reset!
  end

  describe '#handle_call' do
    context 'when all requests succeed' do
      before do
        # Stub APCO service request
        stub_request(:get, 'http://apco_service:4000/api/v1/call_types/MEDICAL')
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: apco_response.to_json
          )

        # Stub call logger request with exact body match
        stub_request(:post, 'http://call_logger:3333/calls')
          .with(
            body: expected_logger_body,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: 'Call logged successfully'
          )
      end

      it 'fetches APCO info and logs the call' do
        expect { call_flow.handle_call }
          .to output(/Full Call Information:.*apco_code.*101/).to_stdout

        expect(WebMock).to have_requested(:get, 'http://apco_service:4000/api/v1/call_types/MEDICAL')
        expect(WebMock).to have_requested(:post, 'http://call_logger:3333/calls')
          .with(body: expected_logger_body)
      end
    end

    context 'when APCO service request fails' do
      before do
        stub_request(:get, 'http://apco_service:4000/api/v1/call_types/MEDICAL')
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an error' do
        expect { call_flow.handle_call }
          .to raise_error(/Error fetching APCO info: 500/)
      end
    end

    context 'when call logger request fails' do
      before do
        # Successful APCO request
        stub_request(:get, 'http://apco_service:4000/api/v1/call_types/MEDICAL')
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: apco_response.to_json
          )

        # Failed call logger request
        stub_request(:post, 'http://call_logger:3333/calls')
          .with(
            body: expected_logger_body,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'outputs error message but does not raise' do
        expect { call_flow.handle_call }
          .to output(/Failed to log call: 500/).to_stdout
      end
    end

    context 'when APCO service returns invalid JSON' do
      before do
        stub_request(:get, 'http://apco_service:4000/api/v1/call_types/MEDICAL')
          .to_return(status: 200, body: 'Invalid JSON')
      end

      it 'raises a parser error' do
        expect { call_flow.handle_call }
          .to raise_error(/Error parsing APCO response/)
      end
    end
  end
end
