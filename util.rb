require 'net/https'

module GeoUtil
    def calculate_distance_km(lon1, lat1, lon2, lat2)
        distance = GeoDistance::Haversine.geo_distance(lon1, 
                                                       lat1,
                                                       lon2,
                                                       lat2)
        return (distance.to_meters / 1000).to_i
    end

    def query_elevation(longitude, latitude)
        uri = URI.parse("https://codingcontest.runtastic.com/api/elevations/#{latitude}/#{longitude}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl =  true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(req)

        return response.body.to_i
    end

    #coordinates = array of hashes #(longitude, latitude)
    #returns array of json objects (longitude, latitude) with symbolized names
    def query_elevations(coordinates)
        uri = URI.parse('https://codingcontest.runtastic.com/api/elevations/bulk')

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
        req.body = coordinates.map {|o| Hash[o.each_pair.to_a] }.to_json

        response = http.request(req)

        return JSON.parse(response.body, :symbolize_names => true)
    end
end

module TraceUtil
    include GeoUtil

    def add_distances
        coordinates = self.coordinates

        return false if !coordinates.kind_of?(Array) || coordinates.empty?

        #First distance will always be 0, even if there is only 1 entry
        coordinates[0].distance = 0

        #If there are max. 2 elements, nothing left to do
        return true if coordinates.length < 2

        #Iterate to the rest values and add cumulative distances
        (1..coordinates.length - 1).each do |n|
            c1 = coordinates[n-1]
            c2 = coordinates[n]

            #Now the distance of the previous coordinate is relevant for cumulation
            c2.distance = calculate_distance_km(c1.longitude, 
                                                c1.latitude,
                                                c2.longitude,
                                                c2.latitude) + c1.distance
        end

        return true
    end

    def add_elevations
        coordinates = self.coordinates

        return false if !coordinates.kind_of?(Array) || coordinates.empty?

        #Extract all coords with lat and long for querying the elevation api
        plain_coords = coordinates.map { |c| {:latitude => c.latitude, :longitude => c.longitude }  }
        elevations = query_elevations(plain_coords)

        #Remap the queried elevations to the relevant coordinate
        coordinates.each_with_index {|c, index| c.elevation = elevations[index] }
         
        return true
    end
end
