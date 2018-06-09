module ServyConv
  Conv = Struct.new(:method, :path, :params, :headers, :resp_body, :status) do
  end

  def self.full_status(conv)
    "#{conv[:status]} #{status_reason(conv[:status])}"
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