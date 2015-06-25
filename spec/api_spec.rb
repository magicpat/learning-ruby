require_relative 'spec_helper.rb'

describe 'Traces API' do

    describe "GET /" do
        it 'should return api name' do
            get '/'
            expect(last_response).to be_ok
            expect(last_response.status).to eq(200)
            expect(last_response.body).to eq('Traces Api 1.0')
        end
    end

    describe 'GET /traces' do
        it 'should return all traces' do
            insert_test_data 

            get '/traces'
            data = JSON.parse(last_response.body)

            expect(data.length).to eq(Trace.all.length) 
        end

        it 'should return a specific trace with /traces/:id' do
            insert_test_data

            exp_trace = Trace.all.first

            get "/traces/#{exp_trace[:_id]}"
            expect(last_response.status).to eq(200)

            data = JSON.parse(last_response.body, :symbolize_names => true)

            #Check if the coordinates are okay and have the proper attributes
            expect(data[:coordinates].length).to eq(exp_trace.coordinates.length)
            data[:coordinates].each do |coordinate|
                expect(coordinate[:latitude]).to be_a(Float)
                expect(coordinate[:longitude]).to be_a(Float)
            end

            #Check if the retrieved trace has the correct id
            expect(data[:id]).to eq(exp_trace[:_id].to_s)
        end
    end

    describe 'POST /traces' do
        let(:body) do 
            [
                {:latitude => 30.0, :longitude => -117.5},
                {:latitude => 31.0, :longitude => -118.5},
                {:latitude => 32.0, :longitude => -119.5}
            ]
        end

        it 'should create trace' do
            post '/traces', body.to_json, { "HTTP_ACCEPT" => "application/json" }
            expect(last_response.body).to eq("Created")

            traces = Trace.all
            expect(traces.length).to eq(1)

            expect(traces[0].coordinates.length).to eq(body.length)
        end
    end

    describe 'PUT /traces' do
        let(:body) do
            [
                {:latitude => 30.0, :longitude => -117.5},
                {:latitude => 31.0, :longitude => -118.5},
                {:latitude => 32.0, :longitude => -119.5}
            ]
        end

        it 'should update existing trace with sent coordinates' do
            #Prefill with one record to update
            trace = Trace.new(:coordinates => [])
            trace._id = '1'
            trace.save

            put '/traces/1', body.to_json, { "HTTP_ACCEPT" => "application/json" }

            expect(last_response.body).to eq("OK")
            expect(last_response.status).to eq(200)

            trace = Trace.first(:_id => '1')
            expect(trace.coordinates.length).to eq(3)
        end

        it 'should update non-existing trace with coordinates' do
            put '/traces/2', body.to_json, { "HTTP_ACCEPT" => "application/json" }

            expect(last_response.body).to eq("OK")
            expect(last_response.status).to eq(200)

            trace = Trace.first(:_id => '2')
            expect(trace.coordinates.length).to eq(3) 
        end
    end

    describe 'DELETE /traces/:id', :focus => true do
        it 'should delete existing trace' do
            trace = Trace.new()
            trace.save

            delete "/traces/#{trace._id}"
            expect(last_response.body).to eq('OK')
            expect(last_response.status).to eq(200)
        end

        it 'should return error code on nonexisting trace' do
            delete '/trace/22'
            expect(last_response.status).to eq(404)
            expect(last_response.body).to eq('Not found')
        end
    end

end
