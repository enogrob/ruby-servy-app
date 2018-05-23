module ServyParser
  require_relative 'conv'

  def self.parse(request)
    method, path, resp_body =
        request\
    .split("\n")\
    .first\
    .split(" ")

    ServyConv::Conv.new(method, path, "", nil)
  end
end