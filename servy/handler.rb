module ServyHandler
  def self.handle(request)
    _ = parse(request)
    _ = rewrite_path(_)
    _ = log(_)
    _ = route(_)
    _ = emojify(_)
    _ = track(_)
    _ = format_response(_)
    _
  end

  def self.parse(request)
    method, path, resp_body =
    request\
    .split("\n")\
    .first\
    .split(" ")

    {method: method, path: path, resp_body: "", status: nil}
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

  def self.route(conv)
    case
    when conv[:method] == "GET" && conv[:path] == "/wildthings"
      conv[:resp_body] = "Bears, Lions, Tigers"
      conv[:status] = 200
    when conv[:method] == "GET" && conv[:path] == "/bears"
      conv[:resp_body] = "Teddy, Smokey, Paddington"
      conv[:status] = 200
    when conv[:method] == "GET" && conv[:path] == "/about"
      begin
        file = File.expand_path("pages").concat("/about.html")
        puts file
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
      conv[:resp_body] = "Bear #{$1}"
      conv[:status] = 200
    when conv[:method] == "DELETE" && conv[:path] =~ /\/bears\/(\d)/
      conv[:resp_body] = "Deleting a bear is forbidden!"
      conv[:status] = 403
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

  def self.track(conv)
    if conv[:status] == 404
      puts "Warning: #{conv[:path]} is on the loose!"
    end
    conv
  end

  def self.format_response(conv)
    <<~"END"
      HTTP/1.1 #{conv[:status]} #{status_reason(conv[:status])}
      Content-Type: text/html
      Content-Length: #{conv[:resp_body].length}

      #{conv[:resp_body]}
    END
  end

  private

  def self.status_reason(code)
    {
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end
