# encoding: utf-8

## stdlib
require 'json'
require 'csv'
require 'date'
require 'time'
require 'uri'
require 'pp'


# 3rd party gems/libs

require 'logutils'

require 'mustermann'
require 'mustermann/version'
require 'mustermann/sinatra'

require 'rack'


# our own code
require 'webservice/version'   # note: let version always go first
require 'webservice/metal'

require 'webservice/base/base'
require 'webservice/base/response_handler'     ## default (built-in) response handler (magic)



module Webservice
  def self.load_file( path )
    code = File.open( path, 'r:bom|utf-8' ).read
    self.load( code )
  end

  def self.load( code )
    app_class = Class.new( Base )     ## create new app_class or just use Base itself - why? why not?
    app_class.class_eval( code )   ## note: use class_eval (NOT instance_eval)
    app_class
  end
end # module Webservice


# say hello
puts Webservice.banner    if defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG
