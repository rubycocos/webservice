# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_mustermann.rb


require 'helper'


class TestMustermann < MiniTest::Test

  def test_hello

    pp Rack::VERSION
    pp Mustermann::VERSION

    pattern = Mustermann::Sinatra.new( '/:name' )
    pp pattern
    pp pattern.names

    m = pattern.match( "/test" )
    pp m
    pp m.captures
    params = pattern.params( "/test" )
    pp params


    m = pattern.match( "/test/test" )
    pp m
    params = pattern.params( "/test/test" )
    pp params

    splat = Mustermann::Sinatra.new( '/:prefix/*.*' )
    params = splat.params('/a/b.c') # => { "prefix" => "a", splat => ["b", "c"] }
    pp params

    fmt = Mustermann::Sinatra.new( '/:name(.:format)?' )
    params = fmt.params( '/hello.json' )
    pp params
    params = fmt.params( '/hello' )
    pp params

    rnd = Mustermann::Sinatra.new( '/beer/(r|rnd|random)' )
    params = rnd.params( '/beer/rnd' )
    pp params
    params = rnd.params( '/beer/ottakringer' )
    pp params
    params = rnd.params( '/test/beer/ottakringer' )
    pp params


    assert true  # if we get here - test success
  end

end # class TestMustermann
