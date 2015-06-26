require_relative 'spec_helper.rb'
require_relative '../util.rb'

class TestTrace
    include TraceUtil 
    attr_accessor :coordinates
end

class TestCoordinate
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :distance
    attr_accessor :elevation

    def initialize(params = {})
        @latitude = params.fetch(:latitude)
        @longitude = params.fetch(:longitude)
    end
end

RSpec.configure do |c|
    c.include GeoUtil, :module => :geoutil
end

describe 'GeoUtil', :module => :geoutil do
    describe 'calculate_distance_km' do
        it "should return km distance as integer for 2 coordinates" do
            lon1 = 32.933
            lat1 = -117.234

            lon2 = 34.922
            lat2 = -119.432

            distance = calculate_distance_km(lon1, lat1, lon2, lat2)
            expect(distance).to eq(300)
        end
    end

    describe 'query_elevation' do
        it "should query elevation from webservice" do
            lon = 32.933
            lat = -117.234

            elevation = query_elevation(lon, lat)
            expect(elevation).to eq(4139)
        end
    end

    describe 'query_elevations' do
        it "should query bulk evelations" do
            coordinates = [
                { :latitude => 33.0, :longitude => -110 },
                { :latitude => 35.0, :longitude => -120 },
                { :latitude => 37.0, :longitude => -130 }
            ]

            elevations = query_elevations(coordinates)
        end
    end
end

describe 'TraceUtil', :focus => true do
    let(:trace) do
        trace = TestTrace.new()

        trace.coordinates = [
            TestCoordinate.new(:longitude => 32.0, :latitude => -117.0),
            TestCoordinate.new(:longitude => 34.0, :latitude => -119.0),
            TestCoordinate.new(:longitude => 35.0, :latitude => -120.0),
            TestCoordinate.new(:longitude => 36.0, :latitude => -122.0)
        ];
        
        return trace
    end

    describe '#add_distances' do
        it "should add distances to trace's coordinates " do
            trace.add_distances()

            [ 0, 290, 434, 646 ].each_with_index do |val, index|
                expect(trace.coordinates[index].distance).to eq(val)
            end
        end
    end

    describe '#add_elevations' do
        it "should add elevations to trace's coordinates" do
            trace.add_elevations()

            trace.coordinates.each {|c| expect(c.elevation).to be_a(Integer)}
        end
    end
end
