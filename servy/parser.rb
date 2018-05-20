module ServyParser
  def self.parse(request)
    method, path, resp_body =
        request\
    .split("\n")\
    .first\
    .split(" ")

    {method: method, path: path, resp_body: "", status: nil}
  end
end