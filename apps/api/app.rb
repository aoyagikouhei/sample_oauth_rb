require 'json'
require 'sinatra'
require "sinatra/cors"
require 'retriable_x'

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
  RetriableX::Oauth2Client::new(
    ENV['CLIENT_KEY'],
    ENV['CLIENT_SECRET'],
    ENV['CALLBACK_URL']
  )
end

get '/api/v1/oauth' do
  content_type :json
  client = make_client
  authorization_uri, code_verifier, state = client.oauth_url(
    RetriableX::Scopes::FollowCheck
  )
  session[:code_verifier] = code_verifier
  session[:state] = state
  {url: authorization_uri}.to_json
end

post '/api/v1/oauth' do
  params = JSON.parse request.body.read
  code = params['code']
  code_verifier = session[:code_verifier]
  state = session[:state]
  token_response = make_client.access_token(code, code_verifier)
  access_token = token_response.access_token
  refresh_token = token_response.refresh_token
  pp token_response
  x_client = RetriableX::Client::new(access_token: access_token)
  res = x_client.follow_check_screenname("uv_jp")
  pp res

  token_response = make_client.refresh(refresh_token)
  x_client = RetriableX::Client.new(access_token: token_response.access_token)
  #x_client = RetriableX::Client.new(access_token: access_token)
  res = x_client.me()
  #res = x_client.follow_check_screenname("uv_jp")
  pp res

  content_type :json
  {ok: 1}.to_json
end