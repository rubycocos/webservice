# encoding: utf-8


module Webservice

class Base < Metal


  ## note: before (filter) for now is just a method (NOT a chain for blocks, etc.);
  ##   override method to change before (filter)
  def before
     ### move cors headers to responseHandler to initialize!!!! - why? why not??
     ## (auto-)add (merge in) cors headers
     ##   todo: move into a before filter ??  lets you overwrite headers - needed - why? why not??
     headers 'Access-Control-Allow-Origin'  => '*',
             'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With',
             'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
  end


  # note: for now use "plugable" response handler
  ##   rename to respond_with or something? why? why not??
  ##    make it a "stateless" function e.g. just retrun tripled [status, headers, body] - why? why not??
  def handle_response( obj, opts={} )
    handler   = ResponseHandler.new( self )    ## for now "hard-coded"; make it a setting later - why? why not?
    handler.handle_response( obj )   ## prepare response
  end


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
    REQUEST_URI:    >#{request.url}<


#{dump_routes}

#{dump_version}
TXT

    halt 404, msg
  end


############################
## fallback helpers

  def dump_routes    ## todo/check - rename to build_routes/show_routes/etc. - why? why not?
    buf = ""
    walk_routes_for( buf, self.class )
    buf
  end

  def walk_routes_for( buf, base=self.class )

    buf << "  Routes >#{base.name}<:\n\n"

    base.routes.each do |method,routes|
      buf << "    #{method}:\n"
      routes.each do |pattern,block|
        buf << "      #{pattern.to_s}\n"
      end
    end

    if base.superclass.respond_to? :routes
      buf << "\n\n"
      walk_routes_for( buf, base.superclass )
    end
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
