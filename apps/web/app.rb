require 'sinatra'

CALLBACK_URL = 'http://localhost:3000/oauth'

set :port, 3000
set :bind, '0.0.0.0'

get '/' do
  'Hello, World!'
end