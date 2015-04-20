# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_builder.rb


require 'helper'


class TestBuilder < MiniTest::Test

  def test_beer_builder
    builder = Webservice::Builder.load_file( "#{Webservice.root}/examples/beer.rb" )
    pp builder.app_class.routes

    assert true  # if we get here - test success
  end

  def test_football_builder
    builder = Webservice::Builder.load_file( "#{Webservice.root}/examples/football.rb" )
    pp builder.app_class.routes

    assert true  # if we get here - test success
  end

  def test_world_builder
    builder = Webservice::Builder.load_file( "#{Webservice.root}/examples/world.rb" )
    pp builder.app_class.routes

    assert true  # if we get here - test success
  end

end # class TestBuilder
