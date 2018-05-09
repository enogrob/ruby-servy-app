module ServyHandler
  def self.handle(request)
    _ = parse(request)
    _ = route(_)
    _ = log(_)
    _ = format_response(_)
    _
  end

  def self.log(conv)
    puts conv.inspect
    conv
  end

  def self.parse(request)
    method, path, resp_body =
    request\
    .split("\n")\
    .first\
    .split(" ")

    {method: method, path: path, resp_body: "", status: nil}
  end

  def self.route(conv)
    if conv[:method] == "GET" && conv[:path] == "/wildthings"
      conv[:resp_body] = "Bears, Lions, Tigers"
      conv[:status] = 200
    elsif conv[:method] == "GET" && conv[:path] == "/bears"
      conv[:resp_body] = "Teddy, Smokey, Paddington"
      conv[:status] = 200
    elsif conv[:method] == "GET" && conv[:path] =~ /\/bears\/(\d)/
      conv[:resp_body] = "Bear #{$1}"
      conv[:status] = 200
    elsif conv[:method] == "DELETE" && conv[:path] =~ /\/bears\/(\d)/
      conv[:resp_body] = "Deleting a bear is forbidden!"
      conv[:status] = 403
    else
      conv[:resp_body] = "No #{conv[:path]} here!"
      conv[:status] = 404
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
