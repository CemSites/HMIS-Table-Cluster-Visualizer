require 'sequel'

class LinkBuilder
  def self.perform
    builder = LinkBuilder.new
    builder.record_types
    builder.find_links_for('grave')
  end

  def initialize
    @batch_size = 10_000
  end

  def record_types
    @record_type_memo ||= Record.dataset
      .select(:filename)
      .distinct(:filename)
      .all
      .map &:filename
  end

  def find_links_for(ngram)
    record_types.each do |type|
      counter = 0
      record_ids = []
      Record.dataset.where(filename: type).order(:id).paged_each do |record|
        #puts record
        record_ids << record.id
        counter+=1
        if(counter >= 500)
          puts Record.dataset.where(id: record_ids).grep(:filename, "%#{ngram}%").sql
        end
      end
      if(counter > 0)
        puts Record.dataset.where(id: record_ids).grep(:filename, "%#{ngram}%").sql
      end
    end
  end
end
