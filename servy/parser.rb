module ServyParser
  require_relative 'conv'

  def self.parse(request)
    top, params_string = request.split("\n\n")
    top_lines = top.split("\n")
    request_line = top_lines.shift
    header_lines = top_lines
    method, path = request_line.split(" ")
    headers = parse_headers(header_lines)
    params = parse_params(params_string)

    ServyConv::Conv.new(method, path, params, headers, "", nil)
  end

  def self.parse_params(params_string)
    Hash[URI::decode_www_form(params_string.chop)] if !params_string.nil?
  end

  def self.parse_headers(header_lines)
    headers = {}
    header_lines.each do |header|
       key, value = header.split(": ")
       headers.merge!(key => value)
    end
    headers
  end
end
