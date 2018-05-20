module ServyPlugins
  require 'logger'

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.rewrite_path(conv)
    case
    when conv[:path] =~ /\/bears\?id=(\d)/
      conv[:path] = "/bears/#{$1}"
    when conv[:path] =~ /\/wildlife/
      conv[:path] = "/wildthings"
    end
    conv
  end

  def self.log(conv)
    puts conv.inspect
    conv
  end

=begin
  Logs 404 requests.
=end
  def self.track(conv)
    if conv[:status] == 404
      logger.warn "#{conv[:path]} is on the loose!"
    end
    conv
  end
end

