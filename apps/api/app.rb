require 'json'
require 'sinatra'
require "sinatra/cors"
require 'twitter_oauth2'
require 'x'

set :port, 3001
set :bind, '0.0.0.0'
enable :sessions
set :allow_origin, "http://localhost:3000"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"
set :allow_credentials, true

use Rack::Session::Cookie,
  :path => '/',
  :expire_after => 3600*24, # 有効期限、秒数
  :secret => ENV['SESSION_SECRET'] # 暗号化キー

def make_client
  TwitterOAuth2::Client.new(
    identifier: ENV['CLIENT_KEY'],
    secret: ENV['CLIENT_SECRET'],
    redirect_uri: ENV['CALLBACK_URL']
  )
end

get '/api/v1/oauth' do
  content_type :json
  client = make_client
  authorization_uri = client.authorization_uri(
    scope: [
      :'users.read',
      :'tweet.read',
      :'offline.access'
    ]
  )
  session[:code_verifier] = client.code_verifier
  session[:state] = client.state
  {url: authorization_uri}.to_json
end

post '/api/v1/oauth' do
  params = JSON.parse request.body.read
  code = params['code']
  code_verifier = session[:code_verifier]
  state = session[:state]
  client = make_client
  client.authorization_code = code
  token_response = client.access_token! code_verifier
  access_token = token_response.access_token
  pp token_response
  x_client = X::Client.new(bearer_token: access_token)
  res = x_client.get("users/me")
  pp res
  res = x_client.get("users/by/username/shiratoy?user.fields=connection_status")
  pp res
  content_type :json
  {ok: 1}.to_json
end