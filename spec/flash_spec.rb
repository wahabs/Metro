require 'webrick'
require 'controller_base'
require 'router'
require 'byebug'

describe "the symphony of things" do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }

  before(:all) do
    class Ctrlr < ControllerBase
      def route_render
        render_content("testing", "text/html")
      end

      def route_does_params
        render_content("got ##{ params["id"] }", "text/text")
      end

      def update_session
        session[:token] = "testing"
        flash[:message] = "Here's a flash"
        render_content("hi", "text/html")
      end

    end
  end
  after(:all) { Object.send(:remove_const, "Ctrlr") }

  describe "routes and params" do
    it "route instantiates controller and calls invoke action" do
      route = Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_render)
      req.stub(:path) { "/statuses/1" }
      req.stub(:request_method) { :get }
      route.run(req, res)
      res.body.should == "testing"
    end

    it "route adds to params" do
      route = Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_does_params)
      req.stub(:path) { "/statuses/1" }
      req.stub(:request_method) { :get }
      route.run(req, res)
      res.body.should == "got #1"
    end
  end

  describe "controller sessions" do
    let(:ctrlr) { Ctrlr.new(req, res) }

    it "exposes a session via the session method" do
      ctrlr.session.should be_instance_of(Session)
    end

    it "saves the session and flash after rendering content" do
      ctrlr.update_session
      res.cookies.count.should == 2 # flash and session cookies
      session = JSON.parse((res.cookies.find { |cookie| cookie.name == '_rails_lite_app' }).value)
      session["token"].should == "testing"
      ctrlr.flash["message"].should == "Here's a flash"
    end

    it "should preserve flash but not flash.now on the next request" do
      ctrlr.flash["message"] = "Flash!"
      ctrlr.flash.now["temp_message"] = "Flash now!"
      ctrlr.flash["temp_message"].should == "Flash now!"
      ctrlr.route_render
      flash = JSON.parse((res.cookies.find { |cookie| cookie.name == '_rails_lite_app_flash' }).value)
      flash["message"].should == "Flash!"
      flash["temp_message"].should be_nil
    end

  end
end
