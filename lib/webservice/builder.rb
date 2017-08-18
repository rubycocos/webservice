# encoding: utf-8

module Webservice

class Builder

  def self.load_file( path)
    code = File.open( path, 'r:bom|utf-8' ).read
    self.load( code )
  end

  def self.load( code )
     app_class = Class.new( Base )
     app_class.class_eval( code )   ## note: use class_eval (NOT instance_eval)

     builder = Builder.new
     builder.app_class = app_class
     builder
  end


  include LogUtils::Logging

  attr_accessor :app_class

  def initialize
  end


end # class Builder

end # module Webservice
