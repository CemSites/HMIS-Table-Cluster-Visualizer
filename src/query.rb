require 'sequel'
require 'logger'
require 'yaml'

config = YAML::load_file(File.join(__dir__, '../config.yml'))['config']
DB = Sequel.connect(config['database_string'])
Sequel::Model.strict_param_setting = false

#models
require_relative './models/record.rb'
require_relative './models/link.rb'
require_relative './models/query.rb'
#lib
require_relative './lib/link_builder.rb'


class QueryRunner
  def initialize(queries = [])
    @log = Logger.new("#{Time.now.to_i}_query_log.txt")
    @log.level = Logger::DEBUG
    @queries = queries
  end

  def perform
    builder = LinkBuilder.new
    @queries.each do |ngram|
      previous_query = Query.dataset.where(query_name: ngram).first
      if(previous_query)
        @log.info "Query Already Performed #{previous_query.id}"
        return
      end
      link_ids = builder.find_links_for ngram
      @log.debug "list link ids #{link_ids.inspect}"
      Query.dataset.insert [:query_name, :result_ids], [ngram, link_ids.join(',')]
    end
  end
end

QueryRunner.new(ARGV).perform
