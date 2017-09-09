# encoding: utf-8

###
## todo/fix:  move to folder base/base



module Webservice

class Base < Metal

  class << self

    ## convenience method
    def run!
      puts "[debug] Webservice::Base.run! - self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"  # note: assumes self is class
      app    = self     ## note: use self; will be derived class (e.g. App and not Base)
      port   = 4567
      Rack::Handler::WEBrick.run( app, Port:port ) do |server|
        ## todo: add traps here - why, why not??
      end
    end
  end  ## class << self



  ##################################
  ##  add some fallback (builtin) routes

  get '/favicon.ico' do
    ## use 302 to redirect
    ##  note: use strg+F5 to refresh page (clear cache for favicon.ico)
    redirect '/webservice-32x32.png'
  end

  get '/webservice-32x32.png' do
    send_file "#{Webservice.root}/assets/webservice-32x32.png"
  end

  get '/routes' do
    msg =<<TXT
#{dump_routes}

#{dump_version}
TXT
end

  ## catch all (404 not found)
  get '/*' do
    pp env
    pp self.class.routes   ## note: dump routes of derived class

    msg =<<TXT
  404 Not Found

  No route matched >#{request.request_method} #{request.path_info}<:

    REQUEST_METHOD: >#{request.request_method}<
    PATH_INFO:      >#{request.path_info}<
    QUERY_STRING:   >#{request.query_string}<

    SCRIPT_NAME:    >#{request.script_name}<
    REQUEST_URI:    >#{env['REQUEST_URI']}<    ## fix: use request.url - available, same, string ???


#{dump_routes}

#{dump_version}
TXT

    halt 404, msg
  end

############################
## fallback helpers

  def dump_routes    ## todo/check - rename to build_routes/show_routes/etc. - why? why not?

   ### fix: make dump routes recursive!!!!!
   ##    returns all routes from subclasses to class.respond_to? :routes

    buf = ""
    buf << "  Routes >#{self.class.name}<:\n\n"

    self.class.routes.each do |method,routes|
      buf << "    #{method}:\n"
      routes.each do |pattern,block|
        buf << "      #{pattern.to_s}\n"
      end
    end
    buf
  end

  def dump_version
    ## single line version string
    buf = "  "   # note: start with two leading spaces (indent)
    buf << "webservice/#{VERSION} "
    buf << "(#{self.class.environment}), "
    buf << "rack/#{Rack::RELEASE} (#{Rack::VERSION.join('.')}) - "
    buf << "ruby/#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}/#{RUBY_PLATFORM})"
    buf
  end

end # class Base

end # module Webservice
