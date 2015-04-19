# encoding: utf-8

module Webservice

class Builder

  def self.load_file( path)
    code = File.read_utf8( path )
    self.load( code )
  end

  def self.load( code )
    builder = Builder.new
    builder.instance_eval( code )
    builder
  end


  include LogUtils::Logging

  def initialize
    # to be done
  end

  def get( pattern, &block )
    puts "add route get '#{pattern}'"
  end

end # class Builder

end # module Webservice

