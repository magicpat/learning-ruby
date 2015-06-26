require_relative 'spec_helper_sinatra.rb'

module Check
    #trace needs to either be a json literal with symbolized names
    #or
    #a MongoMapper Trace object
    def check_distances(trace)
        coordinates = trace[:coordinates] || trace.coordinates

        coordinates.each do |c|
            distance = c[:distance] || c.distance
            expect(distance).to be_a(Integer)
        end
    end

    #trace needs to either be a json literal with symbolized names
    #or
    #a MongoMapper Trace object
    def check_coordinates(trace)
        coordinates = trace[:coordinates] || trace.coordinates

        coordinates.each do |c|
            lat = c[:latitude] || c.latitude
            long = c[:longitude] || c.longitude

            expect(lat).to be_a(Float)
            expect(long).to be_a(Float)
        end
    end

    #trace needs to either be a json literal with symbolized names
    #or
    #a MongoMapper Trace object
    def check_elevations(trace)
        coordinates = trace[:coordinates] || trace.coordinates

        coordinates.each do |c|
            elevation = c[:elevation] || c.elevation

            expect(elevation).to be_a(Integer)
        end
    end

end

RSpec.configure do |c|
    c.include Check
end

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
        it 'should return all traces with distances and elevations' do
            insert_test_data 

            get '/traces'
            traces = JSON.parse(last_response.body, :symbolize_names => true)

            db_traces = Trace.all

            expect(traces.length).to eq(db_traces.length) 

            #Check if all coordinates have a distance
            traces.each do |t|
                check_distances(t)
                check_elevations(t)
            end

            #Check if all distances were persisted
            db_traces.each do |t|
                check_distances(t)
                check_elevations(t)
            end
        end

        it 'should return a specific trace with /traces/:id' do
            insert_test_data

            exp_trace = Trace.all.first

            get "/traces/#{exp_trace[:_id]}"
            expect(last_response.status).to eq(200)

            trace = JSON.parse(last_response.body, :symbolize_names => true)

            #Check if the coordinates are okay and have the proper attributes
            expect(trace[:coordinates].length).to eq(exp_trace.coordinates.length)
            check_coordinates(trace)
            check_distances(trace)
            check_elevations(trace)

            #Check if the retrieved trace has the correct id
            expect(trace[:id]).to eq(exp_trace[:_id].to_s)

            #Check if distance was persisted by reloading the entity
            db_trace = Trace.find(trace[:id])
            check_distances(db_trace)
            check_elevations(db_trace)
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

        it 'should create trace with calculated distances' do
            post '/traces', body.to_json, { "HTTP_ACCEPT" => "application/json" }
            expect(last_response.body).to eq("Created")

            traces = Trace.all
            expect(traces.length).to eq(1)

            trace = traces[0]
            expect(trace.coordinates.length).to eq(body.length)

            check_distances(trace)
        end
    end

    describe 'PUT /traces', :focus => true do
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

            check_distances(trace)
            check_elevations(trace)
        end

        it 'should update non-existing trace with coordinates' do
            put '/traces/2', body.to_json, { "HTTP_ACCEPT" => "application/json" }

            expect(last_response.body).to eq("OK")
            expect(last_response.status).to eq(200)

            trace = Trace.first(:_id => '2')
            expect(trace.coordinates.length).to eq(3) 

            check_distances(trace)
            check_elevations(trace)
        end
    end

    describe 'DELETE /traces/:id' do
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
