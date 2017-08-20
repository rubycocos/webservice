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
      app_class = Webservice.load_file( "#{Webservice.root}/test/service/app.rb" )
      pp app_class.routes
      app_class.new
    end
  end

  def test_get
    get '/'
    assert last_response.ok?
    assert_equal %q{"Hello World"}, last_response.body

    get '/hello/world'
    assert last_response.ok?
    assert_equal %q{"Hello world"}, last_response.body

    ##############################
    ## get '/hello/:name'
    get '/hello/ruby'
    assert last_response.ok?
    assert_equal %q{"Hello ruby"}, last_response.body

    get '/hello/ruby?test=t'   ## try w/ extra query string/params
    assert last_response.ok?
    assert_equal %q{"Hello ruby"}, last_response.body

    ##################################
    ## get '/:message/:name'
    get '/servus/wien'
    assert last_response.ok?
    assert_equal %q{"servus wien"}, last_response.body

    get '/Hallo/Welt'
    assert last_response.ok?
    assert_equal %q{"Hallo Welt"}, last_response.body
  end


  def test_format
    get '/key.format'
    assert last_response.ok?
    assert_equal %q{"key format"}, last_response.body

    get '/ottakringer.xxx'
    assert last_response.ok?
    assert_equal %q{"ottakringer xxx"}, last_response.body

    get '/ottakringer'
    assert last_response.ok?
    assert_equal %q{"ottakringer "}, last_response.body
  end


  def test_countries

    get '/countries.csv'
    assert last_response.ok?
    assert_equal <<CSV, last_response.body
at,Austria
mx,Mexico
CSV

    get '/countries.html'
    assert last_response.ok?
    assert_equal <<HTML, last_response.body
<table>
  <tr><td>at</td><td>Austria</td></tr>
  <tr><td>mx</td><td>Mexico</td></tr>
</table>
HTML

   get '/countries.json'
   assert last_response.ok?
   assert_equal %q<[{"key":"at","name":"Austria"},{"key":"mx","name":"Mexico"}]>, last_response.body

   get '/countries'
   assert last_response.ok?
   assert_equal %q<[{"key":"at","name":"Austria"},{"key":"mx","name":"Mexico"}]>, last_response.body
  end  # method test_countries


  def test_halt
    get '/halt/404'
    assert_equal 404, last_response.status

    get '/halt_error'   ##  500, "Error fatal"  # 500 - internal server error
    assert_equal 500, last_response.status
  end

end # class TestApp
