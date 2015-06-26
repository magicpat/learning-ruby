require 'rubygems'

require 'bundler/setup'

Bundler.require(:default)

require_relative 'util.rb'

class Trace
    include MongoMapper::Document
    include TraceUtil

    #Workaround for 'stack level too deep' error if coords.length > 800
    embedded_callbacks_off
    many :coordinates
end

class Coordinate
    include MongoMapper::EmbeddedDocument

    embedded_in :trace
    key :latitude, Float
    key :longitude, Float
    key :distance, Integer
    key :elevation, Integer
end

configure do
    db_url = ENV['DB_URL'] || 'localhost'
    db_port = ENV['DB_PORT'] || 27017
    db_name = ENV['DB_NAME'] || 'prod' 

    MongoMapper.connection = Mongo::Connection.new(db_url, db_port)
    MongoMapper.database = db_name 
end

#By default, sinatra does not allow external access
set :bind, '0.0.0.0'

before do
    content_type :json
end

not_found do
    'Not found'
end

helpers do
    def oid(val)
        #Only return an objectId for valid key strings
        if !BSON::ObjectId.legal?(val)
            return val 
        end

        BSON::ObjectId.from_string(val)     
    end

    #returns true, if distances were modified
    def eventually_add_distances(trace)
        coordinates = trace.coordinates

        #Only add distances if the first coordinate has no distance set
        #Assuming that if the first value has no distance, no coordinate
        #will have it
        if coordinates && !coordinates.empty? && coordinates[0].distance != 0 
            trace.add_distances()
            return true
        end

        return false
    end

    def eventually_add_elevations(trace)
        coordinates = trace.coordinates

        #Only augment elevations, if the first coordinate does not have any elevation attribute
        if coordinates && !coordinates.empty? && coordinates[0].elevation.nil?
            trace.add_elevations()
            return true
        end

        return false
    end
end

get '/' do
    'Traces Api 1.0'
end

get '/traces' do
    traces = Trace.all.each

    #Automatically save the entry if distances / elevations
    #were added... Get request may take longer
    #if there were many traces without distances,
    #but will boost performance in the long run
    traces.each do |t|
        e1 = eventually_add_distances(t)
        e2 = eventually_add_elevations(t)

        t.save() if (e1 || e2)
    end

    traces.to_json
end


get '/traces/:id' do
    trace = Trace.first(:_id => oid(params[:id])) 

    if !trace
        return [ 404, 'Not found' ] 
    end

    e1 = eventually_add_distances(trace)
    e2 = eventually_add_elevations(trace)

    trace.save() if (e1 || e2)

    trace.to_json
end

post '/traces' do
    request.body.rewind
    coordinates = JSON.parse request.body.read

    trace = Trace.new(:coordinates => coordinates)
    trace.add_distances
    trace.add_elevations
    trace.save

    return [ 201, 'Created' ]
end

put '/traces/:id' do
    request.body.rewind
    coordinates = JSON.parse request.body.read
    
    trace = Trace.first(:_id => oid(params[:id])) || Trace.new()

    trace._id = params[:id]
    trace.coordinates = coordinates
    trace.add_distances
    trace.add_elevations
    trace.save

    return [ 200, 'OK' ]
end

delete '/traces/:id' do
    trace = Trace.first(:_id => oid(params[:id])) 

    if !trace
        return [ 404 ] 
    end

    trace.delete

    return [ 200, 'OK' ]
end
