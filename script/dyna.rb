###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib  script/dyna.rb


require 'webservice'


App = Webservice.load_file( "#{Webservice.root}/samples/debug.rb" )


#############
# for testing startup server

puts "dump routes:"     ## App <> App < Base < Metal
puts App.name
pp   App.ancestors
pp   App.routes

puts App.superclass.name   ##  Base <> App < Base < Metal
pp   App.superclass.routes

puts App.superclass.superclass.name   ##  Metal <> App < Base < Metal
pp   App.superclass.superclass.routes


puts "starting server..."
App.run!
puts "bye"
