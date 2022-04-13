# frozen_string_literal: true

$LOAD_PATH << File.join(__dir__, 'lib')

require 'devpack' if ENV['RACK_ENV'] == 'development'

require 'yaml'

require 'rubygems'
require 'geminabox'
require 'authorization'

USERS_PATH = ENV.fetch('PRIVATE_GEMS_USERS_PATH', '/privategems-users.yml')
DATA_PATH = ENV.fetch('PRIVATE_GEMS_DATA_PATH', '/privategems/data')

Geminabox.data = DATA_PATH
Geminabox.views = ENV.fetch('PRIVATE_GEMS_VIEWS_PATH') if ENV.key?('PRIVATE_GEMS_VIEWS_PATH')
Geminabox.allow_remote_failure = true

use Rack::Session::Cookie, key: '_session',
                           domain: 'localhost',
                           path: '/',
                           expire_after: 2_592_000,
                           secret: ENV.fetch('SECRET_KEY_BASE')

Geminabox::Server.before '/upload' do
  authorization(:upload)
end

Geminabox::Server.before do
  if request.delete?
    authorization(:yank)
  else
    authorization(:default)
  end
end

Geminabox::Server.get '/api/v1/api_key' do
  status 200

  authorization_request.create_api_key

  config = YAML.safe_load(File.read(USERS_PATH))
  config['users'] = authorization_request.users

  File.write(USERS_PATH, config.to_yaml)

  body authorization_request.user.api_key
end

Geminabox::Server.helpers do
  def authorization(action)
    return if env['HTTP_AUTHORIZATION'] && authorization_request.authorized?(action)

    response['WWW-Authenticate'] = %(Basic realm="Gem In a Box")
    halt 401, "Not Authorized.\n"
  end

  def authorization_request
    @authorization_request ||= Authorization::Request.new(users: users, **credentials)
  end

  def users
    # Read from disk for every request to allow live-loading user data.
    YAML.safe_load(users_yaml)['users']
  end

  def users_yaml
    File.read(USERS_PATH)
  end

  def basic_auth
    @basic_auth ||= Rack::Auth::Basic::Request.new(request.env)
  end

  def credentials
    {
      username: basic_auth.credentials.first,
      password: basic_auth.credentials.last,
      api_key: env['HTTP_AUTHORIZATION']
    }
  end
end

run Geminabox::Server
