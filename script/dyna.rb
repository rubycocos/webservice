###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib  script/dyna.rb


require 'webservice'


App = Webservice.load_file( "#{Webservice.root}/samples/debug.rb" )


#############
# for testing startup server

puts "dump routes:"
pp App.routes

puts "starting server..."
App.run!
puts "bye"
