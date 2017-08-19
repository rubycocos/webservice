# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_samples_debug.rb


require 'helper'


class TestSamplesDebug < MiniTest::Test

  def test_debug
    app_class = Webservice.load_file( "#{Webservice.root}/samples/debug.rb" )
    pp app_class.routes

    assert true  # if we get here - test success
  end

end # class TestSamplesDebug
