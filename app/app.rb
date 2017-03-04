require 'json'
require 'sinatra'
require "sinatra/activerecord"
Dir["./app/models/*.rb"].each { |file| require file }

configure :production do
  ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_PUCE_URL'])
end

configure :development do
  set :database_file, "../config/database.yml"
end

after do
 ActiveRecord::Base.clear_active_connections!
end

###############################################
# Import all data
# - Add additional import methods to this route
###############################################

get '/import-data' do
	GasWellInspection.import
	VoterDistrict.import
  Billboard.import
  School.import
  WellInspection.import
  DentonHouse.import
  HomelessnessSurvey.import
  Demographic.import
  Economic.import
  "Data Imported"
end

###################
# Delete all data #
###################

get '/delete-data' do
	GasWellInspection.delete_all
	VoterDistrict.delete_all
  Billboard.delete_all
  School.delete_all
  WellInspection.delete_all
  DentonHouse.delete_all
  HomelessnessSurvey.destroy_all
  Demographic.destroy_all
  Economic.destroy_all
  "She's dead, Jim."
end

##########
# Home / #
##########

get '/' do
  "Endpoints here."
end

#################
# Denton Houses #
#################

get '/denton-housing' do
  DentonHouse.get_housing.to_json
end

get '/total-housing-units' do
  DentonHouse.total_housing_units(params["year"]).to_json
end

get '/vacant-housing-units' do
  DentonHouse.vacant_housing_units(params["year"]).to_json
end

########################
# Homelessness Surveys #
########################

get '/homelessness-survey' do
  HomelessnessSurvey.all.map do |record|
    record.attributes.except('id')
  end.to_json
end

###################
# Well Inspection #
###################

get '/well-inspections' do
  inspections = WellInspection.order(objectid: :asc)
  "Number of entries: #{inspections.count}<br>#{inspections.map { |i| i.objectid }}!"
end

################
# Demographics #
################

get '/demographics' do
  Demographic.all.map do |record|
    record.attributes.except('id')
  end.to_json
end

get '/demographics/:year' do
  Demographic.where(year: params[:year]).each_with_object({}) do |demo, obj|
    obj[demo.title_field] = demo.value
  end.to_json
end

################
# Ecoomics #
################

get '/economics' do
  Economic.all.map do |record|
    record.attributes.except('id')
  end.to_json
end


###################
# Voter Districts #
###################

get '/voter-districts' do
  VoterDistrict.all.map do |record|
    record.attributes.except('id')
  end.to_json
end
