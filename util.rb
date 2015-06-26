module GeoUtil
    def calculate_distance_km(lon1, lat1, lon2, lat2)
        distance = GeoDistance::Haversine.geo_distance(lon1, 
                                                       lat1,
                                                       lon2,
                                                       lat2)
        return (distance.to_meters / 1000).to_i
    end
end

module TraceUtil
    include GeoUtil

    def add_distances
        coordinates = self.coordinates

        return if !coordinates.kind_of?(Array) || coordinates.empty?

        #First distance will always be 0, even if there is only 1 entry
        coordinates[0].distance = 0

        #If there are max. 2 elements, nothing left to do
        return if coordinates.length < 2

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
    end
end
