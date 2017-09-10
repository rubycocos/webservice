###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib  script/metal.rb


require 'webservice'


class App < Webservice::Metal

  get '/hello' do
    'Hello, World!'
  end

end # class App

#############
# for testing startup server

puts "dump routes:"     ## App <> App < Metal
puts App.name
pp   App.ancestors
pp   App.routes

puts App.superclass.name   ##  Metal <> App  < Metal
pp   App.superclass.routes


puts "starting server..."
App.run!
puts "bye"
