module ServyHandler
  require_relative 'plugins'
  require_relative 'parser'
  require_relative 'conv'
  require_relative 'bear_controller'

=begin
  handles HTTP requests.
=end

  def self.pages_path
    @pages_path ||= File.expand_path("pages")
  end

=begin
  Trasnforms the request into a response
=end
  def self.handle(request)
    _ = ServyParser.parse(request)
    _ = ServyPlugins.rewrite_path(_)
    _ = ServyPlugins.log(_)
    _ = route(_)
    _ = emojify(_)
    _ = ServyPlugins.track(_)
    _ = format_response(_)
    _
  end

  def self.route(conv)
    case
    when conv[:method] == "GET" && conv[:path] == "/wildthings"
      conv[:resp_body] = "Bears, Lions, Tigers"
      conv[:status] = 200
    when conv[:method] == "GET" && conv[:path] == "/bears"
      BearController::index(conv)
    when conv[:method] == "POST" && conv[:path] == "/bears"
      BearController::create(conv)
    when conv[:method] == "GET" && conv[:path] == "/about"
      begin
        file = pages_path + "/about.html"
        f = File.open(file)
      rescue Errno::ENOENT => e
        conv[:resp_body] = "File not found!"
        conv[:status] = 404
      rescue Exception => e
        conv[:resp_body] = "#{e.message}"
        conv[:status] = 500
      else
        content = f.read
        conv[:resp_body] = content
        conv[:status] = 200
        f.close
      end
    when conv[:method] == "GET" && conv[:path] =~ /\/pages\/(\w+)/
      begin
        file = pages_path + "/#{$1}.html"
        f = File.open(file)
      rescue Errno::ENOENT => e
        conv[:resp_body] = "File not found!"
        conv[:status] = 404
      rescue Exception => e
        conv[:resp_body] = "#{e.message}"
        conv[:status] = 500
      else
        content = f.read
        conv[:resp_body] = content
        conv[:status] = 200
        f.close
      end
    when conv[:method] == "GET" && conv[:path] =~ /\/bears\/(\d)/
      BearController::show(conv, $1)
    when conv[:method] == "DELETE" && conv[:path] =~ /\/bears\/(\d)/
      BearController::delete(conv, $1)
    else
      conv[:resp_body] = "No #{conv[:path]} here!"
      conv[:status] = 404
    end
    conv
  end

  def self.emojify(conv)
    if conv[:status] == 200
      emojies = "🎉" * 5
      body = emojies + "\n" + conv[:resp_body] + "\n" + emojies
      conv[:resp_body]=body
    end
    conv
  end

  def self.format_response(conv)
    <<~"END"
      HTTP/1.1 #{ServyConv::full_status(conv)} 
      Content-Type: text/html
      Content-Length: #{conv[:resp_body].length}

      #{conv[:resp_body]}
    END
  end

  private


end
