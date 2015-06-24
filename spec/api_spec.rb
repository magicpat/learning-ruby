require_relative 'spec_helper.rb'

describe 'Traces API' do

    it 'retrieves api root' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('Traces Api 1.0')
    end

    it 'retrieves all traces' do
        insert_test_data 

        get '/traces'
        data = JSON.parse(last_response.body)

        expect(data.length).to eq(Trace.all.length) 
    end

    it 'retrieves single trace' do
        insert_test_data

        exp_trace = Trace.all.first

        get "/traces/#{exp_trace[:_id]}"
        expect(last_response.status).to eq(200)

        data = JSON.parse(last_response.body)
        puts data

        expect(data[:id]).to eq(exp_trace[:_id].to_s)
        puts data[:id]
        puts exp_trace[:_id]
    end
end
