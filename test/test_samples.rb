# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_samples.rb


require 'helper'


class TestSamples < MiniTest::Test

  def test_beer
    app_class = Webservice.load_file( "#{Webservice.root}/samples/beer.rb" )
    pp app_class.routes

    assert true  # if we get here - test success
  end

  def test_football
    app_class = Webservice.load_file( "#{Webservice.root}/samples/football.rb" )
    pp app_class.routes

    assert true  # if we get here - test success
  end

  def test_world
    app_class = Webservice.load_file( "#{Webservice.root}/samples/world.rb" )
    pp app_class.routes

    assert true  # if we get here - test success
  end

end # class TestSamples
