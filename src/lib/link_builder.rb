require 'sequel'

class LinkBuilder
  def self.perform
    builder = LinkBuilder.new
    builder.record_types
    builder.find_links_for('grave')
  end

  def initialize
    @log = Logger.new("#{Time.now.to_i}_link_log.txt")
    @log.level = Logger::INFO
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
    record_count = 0
    record_types.each do |type|
      record_ids = []
      Record.dataset.where(filename: type).order(:id).paged_each(rows_per_fetch: 5000) do |record|
        record_ids << record.id
        record_count+=1
        if(record_ids.count >= 1000)
          links = Record.dataset.where(id: record_ids).grep(:data, "%#{ngram}%").map{ |r| [r[:id], ngram] }
          @log.debug links.inspect
          @log.info record_count
          Link.dataset.import [:source_link_id, :match], links, commit_every: 1000
          record_ids = []
        end
      end
      if(record_ids.count > 0)
        links = Record.dataset.where(id: record_ids).grep(:filename, "%#{ngram}%").map{ |r| [r[:id], ngram] }
        @log.debug links.inspect
        @log.info record_count
        Link.dataset.import [:source_link_id, :match], links
      end
    end
  end
end
