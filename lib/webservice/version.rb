# encoding: utf-8

module Webservice

   module Version
     MAJOR = 0    ## todo: namespace inside version or something - why? why not??
     MINOR = 6
     PATCH = 1    ## note: if not put in module will overwrite PATCH (HTTP Verb Constant)!!!
   end

   VERSION = [Version::MAJOR,
              Version::MINOR,
              Version::PATCH].join('.')

  def self.version
    VERSION
  end

  def self.banner
    "webservice/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname(File.dirname(File.dirname(__FILE__))) )}"
  end
end # module Webservice
