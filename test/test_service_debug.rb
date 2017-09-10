# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_service_debug.rb


require 'helper'


class TestServiceDebug < MiniTest::Test

  include Rack::Test::Methods

  def app
    ## return (rack-ready) app object
    @@app ||= begin
      app_class = Webservice.load_file( "#{Webservice.root}/test/service/debug.rb" )
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

end # class TestServiceDebug
