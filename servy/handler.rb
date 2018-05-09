module ServyHandler
  def self.handle(request)
    _ = parse(request)
    _ = route(_)
    _ = format_response(_)
    _
  end

  def self.parse(request)
    method, path, resp_body =
    request\
    .split("\n")\
    .first\
    .split(" ")

    {method: method, path: path, resp_body: ""}
  end

  def self.route(conv)
    conv[:resp_body] = "Bears, Lions, Tigers"
    conv
  end

  def self.format_response(conv)
    <<~"END"
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{conv[:resp_body].length}

    #{conv[:resp_body]}
    END
  end

end
