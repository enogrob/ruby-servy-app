module ServyParser
  require_relative 'conv'

  def self.parse(request)
    top, params_string = request.split("\n\n")
    request_line, header_lines = top.split("\n")
    method, path = request_line.split(" ")
    params = parse_params(params_string)

    ServyConv::Conv.new(method, path, params, "", nil)
  end

  def self.parse_params(params_string)
    Hash[URI::decode_www_form(params_string.chop)] if !params_string.nil?
  end
end