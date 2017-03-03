require 'fileutils'
require 'active_support/all'

class FileGenerator
  MIGRATION_DIR = File.join( File.dirname(__FILE__), "./../../db/migrate")
  MODEL_DIR = File.join(File.dirname(__FILE__), './../../app/models')
  DATA_DIR = File.join(File.dirname(__FILE__), './../../data')

  def self.generate_json(data)
    file_name = DATA_DIR + '/temp_data_' + self.current_time + '.json'
    File.open(file_name, 'w+') { |f| f.write JSON.pretty_generate(data) }
  end

  def self.generate_migration(table_name, attributes)
    class_name = table_name.classify
    system("rake db:create_migration NAME=create_#{class_name}")
    
    migration_file = Dir["#{MIGRATION_DIR}/*.rb"].select { |f| f =~ /#{class_name}/i }[0]
    tempfile = File.open("#{MIGRATION_DIR}/file.tmp", "w")
    original = File.new(migration_file)

    original.each do |line|
      tempfile << line
      if line.downcase =~ /def change/
        tempfile << "create_table :#{table_name} do |t|\n"
        attributes.each do |attribute_name, data_type|
          tempfile << "\t\tt.#{data_type} :#{attribute_name}\n"
        end
        tempfile << "end\n"
      end
    end

    original.close
    tempfile.close
    FileUtils.mv "#{MIGRATION_DIR}/file.tmp", migration_file
  end

  def self.generate_model(table_name)
    if system('rake db:migrate')
      model_file = File.open("#{MODEL_DIR}/#{table_name.singularize}.rb", "w")
      model_file << model_file_template(table_name)
      model_file.close
    end
  end

  private

    def self.current_time
      timestamp = Time.now.strftime('%s')
    end

    def self.model_file_template(table_name)
      "class #{ table_name.classify } < ActiveRecord::Base\nend"
    end

end