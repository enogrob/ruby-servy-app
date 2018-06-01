
require_relative '../servy/handler'
require_relative '../servy/plugins'
require_relative '../servy/parser'
require_relative '../servy/conv'

RSpec.describe 'Servy App' do
  let!(:handler) { ServyHandler }

  context 'ServyParser' do
    let!(:subject) { ServyParser }

    it 'Responds to proper methods' do
      expect(subject).to respond_to(:parse)
      expect(subject).to respond_to(:parse_params)
    end

    it 'Responds to parse properly' do
      request = <<~"REQUEST"
      GET /wildthings HTTP/1.1
      Host: example.com
      User-Agent: ExampleBrowser/1.0
      Accept: */*

      REQUEST
      conv = subject.parse(request)
      expect(conv).to match(ServyConv::Conv.new( "GET", "/wildthings", nil, "", nil))

      request = <<~"REQUEST"
      GET /wildthings HTTP/1.1
      Host: example.com
      User-Agent: ExampleBrowser/1.0
      Accept: */*

      name=Baloo&type=Brown
      REQUEST
      conv = subject.parse(request)
      params = {"name" => "Baloo", "type" => "Brown"}
      expect(conv).to match(ServyConv::Conv.new( "GET", "/wildthings", params, "", nil))
    end

    it 'Responds to params_string properly' do
      params_string = "name=Baloo&type=Brown\n"

      conv = subject.parse_params(params_string)
      params = {"name" => "Baloo", "type" => "Brown"}
      expect(conv).to match(params)
    end
  end

  context 'ServyPlugins' do
    let!(:subject) { ServyPlugins }

    it 'Responds to proper methods' do
      expect(subject).to respond_to(:logger)
      expect(subject).to respond_to(:rewrite_path)
      expect(subject).to respond_to(:log)
      expect(subject).to respond_to(:track)
    end

    it 'Responds to rewrite_path properly' do
      conv = { method: "GET", path: "/bears?id=1", resp_body: "", status: nil }
      conv = subject.rewrite_path(conv)
      expect(conv).to match({ method: "GET", path: "/bears/1", resp_body: "", status: nil })
      conv = { method: "GET", path: "/wildlife", resp_body: "", status: nil }
      conv = subject.rewrite_path(conv)
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "", status: nil })
    end

    it 'Responds to log properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
      expect {subject.log(conv)}.to output(
                                        <<~MESSAGE
        {:method=>\"GET\", :path=>\"/wildthings\", :resp_body=>\"Bears, Lions, Tigers\"}
                                    MESSAGE
                                    ).to_stdout
    end

    it 'Responds to track properly' do
      conv = { method: "GET", path: "/wild", resp_body: "", status: 404 }
      subject.logger.formatter = proc {|severity, datetime, progname, msg| "#{msg}\n"}
      expect{subject.track(conv)}.to output("/wild is on the loose!\n").to_stdout_from_any_process
    end
  end

  context 'ServyHandler' do
  let!(:subject) { handler }

    it 'Responds to proper methods' do
        expect(subject).to respond_to(:pages_path)
        expect(subject).to respond_to(:handle)
        expect(subject).to respond_to(:route)
        expect(subject).to respond_to(:emojify)
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
        Content-Length: 32

        🎉🎉🎉🎉🎉
        Bears, Lions, Tigers
        🎉🎉🎉🎉🎉
        MESSAGE
      ).to_stdout
    end

    it 'Responds to route properly' do
      conv = { method: "GET", path: "/wildthings", resp_body: "", status: nil}
      conv = subject.route(conv)
      expect(conv).to match({ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers", status: 200 })

      conv = { method: "GET", path: "/bears", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to match({ method: "GET", path: "/bears", resp_body: "Teddy, Smokey, Paddington", status: 200 })

      conv = { method: "GET", path: "/about", resp_body: "", status: nil }
      conv = subject.route(conv)
      file = File.open("pages/about.html", "r")
      content = file.read
      file.close
      expect(conv).to match({ method: "GET", path: "/about", resp_body: content, status: 200 })

      conv = { method: "GET", path: "/pages/contact", resp_body: "", status: nil }
      conv = subject.route(conv)
      file = File.open("pages/contact.html", "r")
      content = file.read
      file.close
      expect(conv).to match({ method: "GET", path: "/pages/contact", resp_body: content, status: 200 })

      conv = { method: "GET", path: "/bears/1", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to match({ method: "GET", path: "/bears/1", resp_body: "Bear 1", status: 200 })

      conv = { method: "DELETE", path: "/bears/1", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to match({ method: "DELETE", path: "/bears/1", resp_body: "Deleting a bear is forbidden!", status: 403 })

      conv = { method: "GET", path: "/teddy", resp_body: "", status: nil }
      conv = subject.route(conv)
      expect(conv).to match({ method: "GET", path: "/teddy", resp_body: "No /teddy here!", status: 404 })
    end

    it 'Responds to emojify properly' do
      conv = { method: "GET", path: "/wildlife", resp_body: "Bears, Lions, Tigers", status: 200 }
      expect(subject.emojify(conv)).to match({ method: "GET", path: "/wildlife", resp_body: "🎉🎉🎉🎉🎉\nBears, Lions, Tigers\n🎉🎉🎉🎉🎉", status: 200 })
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

  context 'ServyConv' do
    let!(:subject) { ServyConv }

    it 'Responds to proper methods' do
      expect(subject).to respond_to(:full_status)
      expect(subject).to respond_to(:status_reason)
    end
  end
end
