###
# test base w/ apps

###
#  to run use
#     ruby -I ./lib  script/dyna.rb


require 'webservice'


builder = Webservice::Builder.load_file( "#{Webservice.root}/examples/debug.rb" )


#############
# for testing startup server

puts "dump routes:"
pp builder.app_class.routes

puts "starting server..."
builder.app_class.run!
puts "bye"
