require 'json'
require 'sinatra'
require "sinatra/activerecord"
require_relative './models/denton_houses'
require_relative './models/well_inspection'
require_relative './models/data_saver'
require_relative './models/import_denton_housing'

configure :production do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end

configure :development do
  set :database_file, "../config/database.yml"
end

###############################################
# Import all data
# - Add additional import methods to this route
###############################################

get '/import_data' do
  WellInspection.import
  ImportDentonHouse.import_housing
end

#################
# Denton Houses #
#################

get '/denton-housing' do
  DentonHouse.get_housing.to_json

  #puts JSON.pretty_generate(DentonHouse.get_housing)
end

get '/total-housing-units' do
  DentonHouse.total_housing_units(params["year"]).to_json
end

get '/vacant_housing_units' do
  DentonHouse.vacant_housing_units(params["year"]).to_json
end

###################
# Well Inspection #
###################

get '/' do
  # WellInspection.delete_all
  time = Time.now
  inspections = WellInspection.order(objectid: :asc)
  "Number of entries: #{inspections.count}<br>#{inspections.map { |i| i.objectid }}!"
end
