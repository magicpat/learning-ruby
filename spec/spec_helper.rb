require 'rubygems'
require 'bundler/setup'

Bundler.require(:test, :default)

ENV['RACK_ENV'] = 'test'

#Use isolated database for tests
ENV['DB_NAME'] = 'rspec' 
