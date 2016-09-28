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
    @log.info "Starting #{ngram}"
    links = Record.dataset
      .grep(:data, "%#{ngram}%")
      .map{ |r| [r[:id], ngram] }
    @log.info "Committing record links for query #{ngram}"
    inserted = Link.dataset.import [:source_link_id, :match], links, commit_every: 10_000, return: :primary_key
    @log.info "Finished with #{ngram}"
    return inserted
  end
end
