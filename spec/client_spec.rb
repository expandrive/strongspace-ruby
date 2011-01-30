require File.expand_path("./base", File.dirname(__FILE__))
require "cgi"
require "strongspace"

describe Strongspace::Client do
  before do
    @client = Strongspace::Client.new(nil, nil)
  end

  it "should return the current version" do
    Strongspace::Client.version.should == Strongspace::VERSION
  end

  it "should return a gem version string" do
    Strongspace::Client.gem_version_string.should == "strongspace-gem/#{Strongspace::VERSION}"
  end

  it "should return an API key hash for auth" do
    api_token = { "api_key" => "abc", "username" => "foo/token" }
    stub_request(:get, "https://foo:bar@www.strongspace.com/api/v1/api_token").to_return(:body => api_token.to_json)
    Strongspace::Client.auth("foo", "bar").should == api_token
  end

  it "should fail auth gracefully with a bad password" do
    api_token = { "api_key" => "abc", "username" => "foo/token" }
    stub_request(:get, "https://foo:bar@www.strongspace.com/api/v1/api_token").to_return(:body => api_token.to_json)
    lambda {Strongspace::Client.auth("foo", "ba3r")}.should raise_error(WebMock::NetConnectNotAllowedError)
  end

  it "should return nil for username and password" do
    @client.username.should == nil
    @client.password.should == nil
  end

  it "should return an array of spaces" do
    stub_api_request(:get, "/spaces").to_return(:body => <<-EOJSON)
    {"spaces" : [{"space":{"name":"a space", "snapshots":0, "type":"normal"}}, {"space":{"name":"diskimages", "snapshots":0, "type":"normal"}}]}
    EOJSON
    @client.spaces.should == [{"space"=>{"name"=>"a space", "snapshots"=>0, "type"=>"normal"}}, {"space"=>{"name"=>"diskimages", "snapshots"=>0, "type"=>"normal"}}]
  end

end