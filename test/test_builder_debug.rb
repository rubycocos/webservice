# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_builder_debug.rb


require 'helper'


class TestBuilderDebug < MiniTest::Test

  def test_builder
    builder = Webservice::Builder.load_file( "#{Webservice.root}/examples/debug.rb" )
    pp builder.app_class.routes

    assert true  # if we get here - test success
  end

end # class TestBuilderDebug
