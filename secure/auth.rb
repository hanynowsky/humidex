require 'sinatra'

set :port, 80
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
    return 'Hello world'
end

get '/form/' do
    erb :form
end

post '/form/' do
    username = params[:username] || "No username fetched"
    password = params[:password] || "No password fetched"

    erb :phones, :locals => {'password' => password, 'username' => username}
end
