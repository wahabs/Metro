require 'webrick'
require 'controller_base'
require 'active_support'
require 'router'
require 'byebug'

describe ControllerBase do

  before(:all) do
    class CatsController < ControllerBase
      def index
        @cats = ["GIZMO"]
      end
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  describe "link_to and button_to" do
    # before(:each) do
    #   cats_controller.render(:index)
    # end

    it "generates a functional link" do
      link = cats_controller.link_to "New cat!", "/cats/new"
      link.should == "<a href=\"/cats/new\">New cat!</a>"
    end

    it "generates a functional button" do
      
    end

  end

  # describe "#render" do
  #   before(:each) do
  #     cats_controller.render(:index)
  #   end
  #
  #   it "renders the html of the index view" do
  #     cats_controller.res.body.should include("ALL THE CATS")
  #     cats_controller.res.body.should include("<h1>")
  #     cats_controller.res.content_type.should == "text/html"
  #   end
  #
  #   describe "#already_built_response?" do
  #     let(:cats_controller2) { CatsController.new(req, res) }
  #
  #     it "is false before rendering" do
  #       cats_controller2.already_built_response?.should be false
  #     end
  #
  #     it "is true after rendering content" do
  #       cats_controller2.render(:index)
  #       cats_controller2.already_built_response?.should be true
  #     end
  #
  #     it "raises an error when attempting to render twice" do
  #       cats_controller2.render(:index)
  #       expect do
  #         cats_controller2.render(:index)
  #       end.to raise_error
  #     end
  #
  #     it "captures instance variables from the controller" do
  #       cats_controller2.index
  #       cats_controller2.render(:index)
  #       expect(cats_controller2.res.body).to include("GIZMO")
  #     end
  #   end
  # end
end
