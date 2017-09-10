# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_metal.rb


require 'helper'


class MetalApp < Webservice::Metal

   get '/hello' do
     'Hello, World!'
   end

end # class MetalApp



class TestMetal < MiniTest::Test

  include Rack::Test::Methods

  def app
    ## return (rack-ready) app object
    @@app ||= begin
      app_class = MetalApp
      pp app_class.routes
      app_class
    end
  end


  def test_get
    get '/hello'
    assert last_response.ok?

    get '/'
    assert_equal 404, last_response.status
  end

end # class TestMetal
