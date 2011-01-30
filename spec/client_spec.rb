require File.expand_path("./base", File.dirname(__FILE__))
require "cgi"
require "strongspace/client"

describe Strongspace::Client do
  before do
    @client = Strongspace::Client.new(nil, nil)
  end

  it "Client.auth -> get user details" do
    api_token = { "api_key" => "abc" }
    stub_request(:get, "https://foo:bar@www.strongspace.com/api/v1/api_token").to_return(:body => api_token.to_json)
    Strongspace::Client.auth("foo", "bar").should == api_token
  end

  it "list -> get a list of this user's apps" do
    stub_api_request(:get, "/spaces").to_return(:body => <<-EOJSON)
    {"spaces":[{"space":{"name":"a space", "snapshots":0, "type":"normal"}}, {"space":{"name":"diskimages", "snapshots":0, "type":"normal"}}]}
    EOJSON
    @client.spaces.should == {"spaces"=>[{"space"=>{"name"=>"a space", "snapshots"=>0, "type"=>"normal"}}, {"space"=>{"name"=>"diskimages", "snapshots"=>0, "type"=>"normal"}}]}
  end

end