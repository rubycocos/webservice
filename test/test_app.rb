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
    assert_equal "Hello World", last_response.body

    get '/hello/world'
    assert last_response.ok?
    assert_equal "Hello world", last_response.body

    ##############################
    ## get '/hello/:name'
    get '/hello/ruby'
    assert last_response.ok?
    assert_equal "Hello ruby", last_response.body

    get '/hello/ruby?test=t'   ## try w/ extra query string/params
    assert last_response.ok?
    assert_equal "Hello ruby", last_response.body

    ##################################
    ## get '/:message/:name'
    get '/servus/wien'
    assert last_response.ok?
    assert_equal "servus wien", last_response.body

    get '/Hallo/Welt'
    assert last_response.ok?
    assert_equal "Hallo Welt", last_response.body
  end


  def test_format
    get '/key.format'
    assert last_response.ok?
    assert_equal "key format", last_response.body

    get '/ottakringer.xxx'
    assert last_response.ok?
    assert_equal "ottakringer xxx", last_response.body

    get '/ottakringer'
    assert last_response.ok?
    assert_equal "ottakringer ", last_response.body
  end


  def test_countries

    get '/countries.csv'
    assert last_response.ok?
    assert_equal <<CSV, last_response.body
key,name
at,Austria
mx,Mexico
CSV

    get '/countries.html'
    assert last_response.ok?
    assert_equal <<HTML, last_response.body
<table>
  <tr><th>key</th><th>name</th></tr>
  <tr><td>at</td><td>Austria</td></tr>
  <tr><td>mx</td><td>Mexico</td></tr>
</table>
HTML


  countries_json = [
    { 'key' => 'at', 'name' => 'Austria' },
    { 'key' => 'mx', 'name' => 'Mexico'  },
  ]

   get '/countries.json'
   assert last_response.ok?
   assert_equal countries_json, JSON.parse( last_response.body )

   get '/countries'
   assert last_response.ok?
   assert_equal countries_json, JSON.parse( last_response.body )
  end  # method test_countries



  def test_halt
    get '/halt/404'
    assert_equal 404, last_response.status

    get '/halt_error'   ##  500, "Error fatal"  # 500 - internal server error
    assert_equal 500,               last_response.status
    assert_equal "Error fatal", last_response.body
  end

end # class TestApp
