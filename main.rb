require 'rubygems'

require 'bundler/setup'

Bundler.require(:default)

class Trace
    include MongoMapper::Document

    #Workaround for 'stack level too deep' error if coords.length > 800
    embedded_callbacks_off
    many :coordinates
end

class Coordinate
    include MongoMapper::EmbeddedDocument

    embedded_in :trace
    key :latitude, Float
    key :longitude, Float
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
end

get '/' do
    'Traces Api 1.0'
end

get '/traces' do
    Trace.all.to_json
end

get '/traces/:id' do
    trace = Trace.first(:_id => oid(params[:id])) 

    if !trace
        return [ 404, 'Not found' ] 
    end

    trace.to_json
end

post '/traces' do
    request.body.rewind
    coordinates = JSON.parse request.body.read

    trace = Trace.new(:coordinates => coordinates)
    trace.save

    return [ 201, 'Created' ]
end

put '/traces/:id' do
    request.body.rewind
    coordinates = JSON.parse request.body.read
    
    trace = Trace.first(:_id => oid(params[:id])) || Trace.new()

    trace._id = params[:id]
    trace.coordinates = coordinates
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
