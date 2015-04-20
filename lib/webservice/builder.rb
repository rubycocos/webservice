# encoding: utf-8

module Webservice

class Builder

  def self.load_file( path)
    code = File.read_utf8( path )
    self.load( code )
  end

  def self.load( code )
     app_class = Class.new( Base )
     app_class.instance_eval( code )  ## use class_eval ??

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

