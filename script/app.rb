###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib script/app.rb


require 'webservice'


class MiniApp < Webservice::Base
  get('/') { "Hello from MiniApp" }
  get('/:something') { params['something'] }
end


class App < Webservice::Base
  ## use Rack::Runtime
  ## use Rack::Session::Cookie, secret: ENV['SECRET']
  ## use Rack::Static, urls: ["/js"], root: "public"

  get '/' do
    "Hello World"
  end

  get '/hello/:name' do
    "Hello #{params['name']}"
  end

  get '/:message/:name' do
    @message = params['message']
    @name    = params['name']
    "#{@message} #{@name}"
  end

  get '/halt/404' do
    halt 404  # 404 - not found
    ## todo: check why log reports 200-OK (for status code)!!
  end

  get '/halt_error' do
    halt 500, "Error fatal"  # 500 - internal server error
    ## todo: check why log reports 200-OK (for status code)!!
  end

=begin
  get "/redirect" do
    session["test"] = "test"
    redirect "/session"
  end

  get "/session" do
    "#{session['test']}"
  end

  get "/set_session" do
    session["test"] = "test 2"
  end

  post '/params/:params' do
    "#{params}"
  end

  patch '/test' do
    "PATCH method supported"
  end


  map "/rack" do
    run lambda{|env| [200, {"Content-Type" => "text/html"}, ["PATH_INFO: #{env["PATH_INFO"]}"]]}
  end

  map "/mini" do
    run MiniApp.new
  end
=end

end


#############
# for testing startup server

puts "dump routes:"
pp App.routes

puts "starting server..."
App.run!
puts "bye"
