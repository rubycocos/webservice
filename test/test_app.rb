# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_app.rb


require 'helper'


class TestApp < MiniTest::Test

  include Rack::Test::Methods

  def app
    ## return (rack-ready) app object
    @@app ||= begin
      builder = Webservice::Builder.load_file( "#{Webservice.root}/test/service/app.rb" )
      pp builder.app_class.routes
      builder.app_class.new
    end
  end

  def test_get
    get '/'
    assert last_response.ok?
    assert_equal 'Hello World', last_response.body

    get '/hello/world'
    assert last_response.ok?
    assert_equal 'Hello world', last_response.body

    ##############################
    ## get '/hello/:name'
    get '/hello/ruby'
    assert last_response.ok?
    assert_equal 'Hello ruby', last_response.body

    get '/hello/ruby?test=t'   ## try w/ extra query string/params
    assert last_response.ok?
    assert_equal 'Hello ruby', last_response.body

    ##################################
    ## get '/:message/:name'
    get '/servus/wien'
    assert last_response.ok?
    assert_equal 'servus wien', last_response.body

    get '/Hallo/Welt'
    assert last_response.ok?
    assert_equal 'Hallo Welt', last_response.body
  end

  def test_halt
    ## get '/halt/404'
    get '/halt/404'

    ## get '/halt_error'   - 500, "Error fatal"  # 500 - internal server error
    get '/halt_error'

    ## todo: check error codes
    assert true
  end

end # class TestApp
