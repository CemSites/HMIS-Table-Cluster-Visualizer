require 'logger'
require 'sequel'

class FileLoader
  def self.perform(folder = 'data')
    FileLoader.new(folder).load_files
  end

  def initialize(folder, model = Record)
    @log = Logger.new("#{Time.now.to_i}_import_log.txt")
    @log.level = Logger::INFO
    @folder = folder
    @model = model
    @limit = 50000
    @DB = Sequel.connect('postgres://localhost/straymonds_data')
  end

  def files_to_process
    strip_directories(Dir.glob("#{@folder}/**/*"))
  end

  def strip_directories(paths)
    paths.select do |path|
      File.file?(path)
    end
  end

  def insert_record(filename, data_collection)
    @model.dataset.import [:filename, :data], data_collection, commit_every: @limit
  rescue => e
    @log.warn("#{filename} generated error #{e.message} falling back to one at a time")
    insert_one_at_a_time(filename, data_collection)
  end

  def insert_one_at_a_time(filename, data_collection)
    data_collection.each do |data|
      begin
        @model.dataset.insert [:filename, :data], data
      rescue => e
        @log.warn("#{filename} generated error #{e.message} with data #{data.last} moving on")
      end
    end
  end

  def load_files
    files_to_process.each do |file|
      @log.info("Starting #{file}")
      counter = 0
      lines = []
      File.open(file).each do |line|
        @log.debug("Inserting Line\n #{line}\n")
        counter+=1
        lines << [file, line]
        if(counter >= @limit)
          @log.info("Flushing Batch of #{counter} from #{file}")
          insert_record file, lines
          lines = []
          counter = 0
        end
      end
      if(!lines.empty?)
        insert_record file, lines
      end
      @log.info("Finished #{file}")
    end
  end
end
