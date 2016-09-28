require 'sequel'
require 'logger'
require 'yaml'
require_relative './lib/link_builder.rb'

config = YAML::load_file(File.join(__dir__, '../config.yml'))['config']
DB = Sequel.connect(config['database_string'])
Sequel::Model.strict_param_setting = false

require_relative './models/record.rb'
require_relative './models/link.rb'
require_relative './models/query.rb'

class QueryRunner
  def initialize(queries = [])
    @log = Logger.new("#{Time.now.to_i}_query_log.txt")
    @log.level = Logger::INFO
    @queries = queries
  end

  def perform
    builder = LinkBuilder.new
    @queries.each do |ngram|
      previous_query = Query.dataset.where(query_name: ngram).first
      if(previous_query){
        @log.info "Query Already Performed #{previous_query.id}"
        return
      }
      link_ids = builder.find_links_for ngram
      Query.dataset.insert [:query_name, :result_ids], [ngram, link_ids.join(',')]
    end
  end
end

QueryRunner.new(ARGV).perform
