###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib script/app.rb


require 'webservice'


class MiniApp < Webservice::Base
  get( '/' )                { 'Hello from MiniApp' }
  get( '/test/:something' ) { params['something']  }
end  # class MiniApp


class App < Webservice::Base

  get '/' do
    'Hello World'
  end


  get '/halt/404' do
    halt 404  # 404 - not found
  end

  get '/halt_error' do
    halt 500, 'Error fatal'  # 500 - internal server error
  end


  get '/hello/:name' do
    "Hello #{params['name']}"
  end

  get '/:message/:name' do
    message = params['message']
    name    = params['name']
    "#{message} #{name}"
  end
end  # class App



#############
# for testing startup server

puts 'dump routes:'
pp App.routes

builder = Rack::Builder.new do

  map '/rack' do
    run lambda { |env| pp env;
                        [200,
                         {'Content-Type' => 'text/html'},
                         ["REQUEST_PATH: #{env['REQUEST_PATH']}, PATH_INFO: #{env['PATH_INFO']}"]
                        ]
               }
  end

  map '/mini' do
    run MiniApp
  end

## note: URLMap will NOT match first-come-first-serve
##   URLMap will try to match longest map path first (e.g. match path sorted by length, longest first)
  run App
end


puts 'starting server...'

app  = builder.to_app
pp app.class.name    #=> Rack::URLMap

Rack::Handler::WEBrick.run app, Port: 4567

puts 'bye'
