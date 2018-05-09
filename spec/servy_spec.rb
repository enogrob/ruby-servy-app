
require_relative '../servy/handler'

RSpec.describe 'Servy App' do
  let!(:handler) { ServyHandler }

  context 'ServyHandler' do
  let!(:subject) { handler }

    it 'Responds to proper methods' do
        expect(subject).to respond_to(:handle)
        expect(subject).to respond_to(:log)
        expect(subject).to respond_to(:parse)
        expect(subject).to respond_to(:route)
        expect(subject).to respond_to(:format_response)
        expect(subject).to respond_to(:status_reason)
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

    it 'Responds to log properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
      expect {subject.log(conv)}.to output(
        <<~MESSAGE
        {:method=>\"GET\", :path=>\"/wildthings\", :resp_body=>\"Bears, Lions, Tigers\"}
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
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "", status: nil})
    end

    it 'Responds to route properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "", status: nil}
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers", status: 200 })

      conv = { method: "GET", path: "/bears", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/bears", resp_body: "Teddy, Smokey, Paddington", status: 200 })

      conv = { method: "GET", path: "/bears/1", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/bears/1", resp_body: "Bear 1", status: 200 })

      conv = { method: "DELETE", path: "/bears/1", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "DELETE", path: "/bears/1", resp_body: "Deleting a bear is forbidden!", status: 403 })

      conv = { method: "GET", path: "/teddy", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to be_instance_of(Hash)
      expect(conv).to match({ method: "GET", path: "/teddy", resp_body: "No /teddy here!", status: 404 })
    end

    it 'Responds to format_response properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers", status: 200}
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
