module ServyHandler
  def self.handle(request)
    conv = parse(request)
    conv = route(conv)
    conv = format_response(conv)
    conv
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
    # TODO: Create a new map that also has the response body:
    conv = { method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
  end

  def self.format_response(conv)
    # TODO: Use values in the map to create an HTTP response string:
    <<-"END".gsub(/^ {4}/, '')
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    END
  end

end
