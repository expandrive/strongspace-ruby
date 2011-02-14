# A Ruby class to call the Strongspace REST API.  You might use this if you want to
# manage your Strongspace apps from within a Ruby program, such as Capistrano.
#
# Example:
#
#   require 'strongspace'
#   strongspace = Strongspace::Client.new('me@example.com', 'mypass')
#
class Strongspace::Client
  def self.version
    Strongspace::VERSION
  end

  def self.gem_version_string
    "strongspace-gem/#{version}"
  end

  attr_accessor :host, :user, :password

  def self.auth(user, password, host='https://www.strongspace.com')
    begin
      client = new(user, password, host)
      return JSON.parse client.get('/api/v1/api_token', :username => user, :password => password).to_s
    rescue RestClient::Request::Unauthorized => e
      raise Strongspace::Exceptions::InvalidCredentials
    rescue SocketError => e
      raise Strongspace::Exceptions::NoConnection
    end
  end

  def username
    return nil if !user

    self.user.split("/")[0]
  end

  def login_token
    doc = JSON.parse get('/api/v1/login_token')
  end

  def initialize(user, password, host='https://www.strongspace.com')
    @user = user
    @password = password
    @host = host
  end

  # returns a tempfile to the loaded file
  def download(path)
    RestClient::Request.execute(:method => :get, :url => (@host + '/api/v1/files' + escape(path)), :user => @user, :password => @password, :raw_response => true, :headers =>  {:accept_encoding => ''}).file
  end

  def upload(file, dest_path)
    r = resource(@host + '/api/v1/files/' + escape(dest_path[1..-1] + "/" + File.basename(file.path)))
    r.post(:file => file)
  end

  def mkdir(path)
    doc = post("/api/v1/files/#{escape(path[1..-1])}", :op => "mkdir")
  end

  def rm(path)
    doc = delete("/api/v1/files/#{escape(path[1..-1])}")
  end

  def size(path)
    doc = JSON.parse get("/api/v1/files/#{escape(path[1..-1])}?op=size")
  end

  def spaces
    doc = JSON.parse get('/api/v1/spaces')
    doc["spaces"]
  end

  def delete_space(space_name)
    doc = JSON.parse delete("/api/v1/spaces/#{escape(space_name)}").to_s
  end

  def create_space(name, type='normal')
    doc = JSON.parse post("/api/v1/spaces", :name => name, :type => type)
  end

  def get_space(space_name)
    doc = JSON.parse get("/api/v1/spaces/#{escape(space_name)}")
  end

  def snapshots(space_name)
    doc = JSON.parse get("/api/v1/spaces/#{escape(space_name)}/snapshots").to_s
    doc["snapshots"]
  end

  def delete_snapshot(space_name, snapshot_name)
    doc = JSON.parse delete("/api/v1/spaces/#{escape(space_name)}/snapshots/#{escape(snapshot_name)}").to_s
  end

  def create_snapshot(space_name, snapshot_name)
    doc = JSON.parse post("/api/v1/spaces/#{escape(space_name)}/snapshots", :name => snapshot_name)
  end

  def filesystem
    doc = JSON.parse get("/api/v1/filesystem").to_s
    doc["filesystem"]
  end

  # Get the list of ssh public keys for the current user.
  def keys
    doc = JSON.parse get('/api/v1/ssh_keys')
    doc["ssh_keys"]
  end

  # Add an ssh public key to the current user.
  def add_key(key)
    post("/api/v1/ssh_keys", :key => key).to_s
  end

  # Remove an existing ssh public key from the current user.
  def remove_key(key_id)
    delete("/api/v1/ssh_keys/#{key_id}").to_s
  end

  # Clear all keys on the current user.
  def remove_all_keys
    delete("/api/v1/ssh_keys").to_s
  end

  ##################

  def resource(uri)
    RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    if uri =~ /^https?/
      RestClient::Resource.new(uri, user, password)
    elsif host =~ /^https?/
      RestClient::Resource.new(host, user, password)[uri]
    end
  end

  def get(uri, extra_headers={})    # :nodoc:
    process(:get, uri, extra_headers)
  end

  def post(uri, payload="", extra_headers={})    # :nodoc:
    process(:post, uri, extra_headers, payload)
  end

  def put(uri, payload, extra_headers={})    # :nodoc:
    process(:put, uri, extra_headers, payload)
  end

  def delete(uri, extra_headers={})    # :nodoc:
    process(:delete, uri, extra_headers)
  end

  def process(method, uri, extra_headers={}, payload=nil)
    headers  = strongspace_headers.merge(extra_headers)
    args     = [method, payload, headers].compact
    response = resource(uri).send(*args)
  end

  def escape(value)  # :nodoc:
    escaped = URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    escaped.gsub('.', '%2E') # not covered by the previous URI.escape
  end

  def strongspace_headers   # :nodoc:
    {
      'X-Strongspace-API-Version' => '1',
      'User-Agent'           => self.class.gem_version_string,
      'X-Ruby-Version'       => RUBY_VERSION,
      'X-Ruby-Platform'      => RUBY_PLATFORM
    }
  end

end
