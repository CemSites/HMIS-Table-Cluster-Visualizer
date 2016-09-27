require 'logger'
require 'sequel'

class FileLoader
  def self.perform(folder = 'data')
    FileLoader.new(folder).load_files
  end

  def initialize(folder, model = Record)
    @log = Logger.new(STDOUT)
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
    @model.dataset.import [:filename, :data], data_collection
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
      @log.info("Finished #{file}")
    end
  end
end
