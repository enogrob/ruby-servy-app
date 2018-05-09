
require_relative '../servy/handler'

RSpec.describe 'Servy App' do
  let!(:handler) { ServyHandler }

  context 'ServyHandler' do
  let!(:subject) { handler }

    it 'Responds to proper methods' do
        expect(subject).to respond_to(:handle)
        expect(subject).to respond_to(:parse)
        expect(subject).to respond_to(:route)
        expect(subject).to respond_to(:format_response)
    end

    it 'Responds to handle properly' do
      request = <<~"REQUEST"
      GET /wildthings HTTP/1.1
      Host: example.com
      User-Agent: ExampleBrowser/1.0
      Accept: */*

      REQUEST
      response = subject.handle(request)
      expect {puts response}.to output(
        <<~MESSAGE
        HTTP/1.1 200 OK
        Content-Type: text/html
        Content-Length: 20

        Bears, Lions, Tigers
        MESSAGE
      ).to_stdout
    end

    it 'Responds to parse properly' do
      request = <<~"REQUEST"
      GET /wildthings HTTP/1.1
      Host: example.com
      User-Agent: ExampleBrowser/1.0
      Accept: */*

      REQUEST
      conv = subject.parse(request)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "" })
    end

    it 'Responds to route properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "" }
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" })
    end

    it 'Responds to format_response properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
      expect {puts subject.format_response(conv)}.to output(
        <<~MESSAGE
        HTTP/1.1 200 OK
        Content-Type: text/html
        Content-Length: 20

        Bears, Lions, Tigers
        MESSAGE
      ).to_stdout
    end
  end
end
