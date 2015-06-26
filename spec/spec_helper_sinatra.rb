require_relative 'spec_helper'
require_relative '../main.rb'

module SinatraMixin
    include Rack::Test::Methods
    def app() Sinatra::Application end
end

module DBMixin
    def insert_test_data()
        #Prefill database
        for n in 0..5
            filepath = File.expand_path("../../fixture/#{n}.json", __FILE__)

            data = File.read(filepath)
            coordinates = JSON.parse(data)

            trace = Trace.new(:coordinates => coordinates)
            trace.save
        end
    end
end

RSpec.configure do |config| 
    config.include SinatraMixin 
    config.include DBMixin

    config.before(:suite) do
        DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
        DatabaseCleaner.start
    end

    config.after(:each) do
        DatabaseCleaner.clean
    end
end
