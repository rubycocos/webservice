# encoding: utf-8


module Webservice

  ## use (an reuse from Rack) some freezed string constants
  ##  HTTP verbs
  GET     = Rack::GET
  POST    = Rack::POST
  PATCH   = Rack::PATCH
  PUT     = Rack::PUT
  DELETE  = Rack::DELETE
  HEAD    = Rack::HEAD
  OPTIONS = Rack::OPTIONS

  ##  HTTP headers
  CONTENT_LENGTH = Rack::CONTENT_LENGTH
  CONTENT_TYPE   = Rack::CONTENT_TYPE
  # -- more HTTP headers - not available from Rack
  LOCATION       = 'Location'.freeze
  LAST_MODIFIED  = 'Last-Modified'.freeze


module Helpers
    ## add some more helpers
    ##   "inspired" by sinatra (mostly) - for staying compatible
    ##   see https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb

    ## todo -- add status -- why? why not??

    # Halt processing and return the error status provided.
    def error( code, body=nil )
      response.body = body unless body.nil?
      halt code
    end

    # Halt processing and return a 404 Not Found.
    def not_found( body=nil )
      error 404, body
    end


    def redirect( uri, status=302 )    ## Note: 302 == Found, 301 == Moved Permanently

      ##
      ## todo/fix: add/prepepand SCRIPT_NAME if NOT empty - why? why not??
      ##    without SCRIPT_NAME redirect will not work with (non-root) mounted apps

      halt status, { LOCATION => uri }
    end
    alias_method :redirect_to, :redirect


    # Set multiple response headers with Hash.
    def headers( hash=nil )
      response.headers.merge! hash if hash
      response.headers
    end



    ## (simple) content_type helper - all "hard-coded" for now; always uses utf-8 too
    def content_type( type=nil )
      return response[ CONTENT_TYPE ] unless type

      if type.to_sym == :json
        response[ CONTENT_TYPE ] = 'application/json; charset=utf-8'
      elsif type.to_sym == :js || type.to_sym == :javascript
        response[ CONTENT_TYPE ] = 'application/javascript; charset=utf-8'
        ## use 'text/javascript; charset=utf-8'  -- why? why not??
        ## note: ietf recommends application/javascript
      elsif type.to_sym == :csv || type.to_sym == :text || type.to_sym == :txt
        response[ CONTENT_TYPE ] = 'text/plain; charset=utf-8'
      elsif type.to_sym == :html || type.to_sym == :htm
        response[ CONTENT_TYPE ] = 'text/html; charset=utf-8'
      else
        ### unknown type; do nothing - sorry; issue warning - why? why not??
      end
    end  ## method content_type


  ## simple send file (e.g. for images/binary blobs, etc.) helper
  def send_file( path )
    ## puts "send_file path=>#{path}<"

    ## puts "HTTP_IF_MODIFIED_SINCE:"
    ## puts request.get_header('HTTP_IF_MODIFIED_SINCE')

    last_modified = File.mtime(path).httpdate
    ## puts "last_modified:"
    ## puts last_modified

    ## HTTP 304 => Not Modified
    halt 304     if request.get_header('HTTP_IF_MODIFIED_SINCE') == last_modified

    headers[ LAST_MODIFIED ] = last_modified

    bytes = File.open( path, 'rb' ) { |f| f.read }

    ## puts "encoding:"
    ## puts bytes.encoding

    ## puts "size:"
    ## puts bytes.size

    extname = File.extname( path )
    ## puts "extname:"
    ## puts extname

    ## puts "headers (before):"
    ## pp headers

    if extname == '.png'
      headers[ CONTENT_TYPE ] = 'image/png'
    else
      ## fallback to application/octet-stream
      headers[ CONTENT_TYPE ] = 'application/octet-stream'
    end

    headers[ CONTENT_LENGTH ] = bytes.size.to_s   ## note: do NOT forget to use to_s (requires string!)

    ## puts "headers (after):"
    ## pp headers

    halt 200, bytes
  end # method send_file



end  ## module Helpers


class Metal    ## bare bones core (use base for more built-in functionality)
  include Helpers


  class << self

    def call( env )    ## note self.call(env) lets you use =>  run Base instead of run Base.new
      ## puts "calling #{self.name}.call"
      prototype.call( env )
    end

    def prototype
      ## puts "calling #{self.name}.prototype"
      @prototype ||= self.new
      ## pp @prototype
      ## @prototype
    end


    ## todo/check: all verbs needed! (supported) - why, why not??
    ##   e.g. add LINK, UNLINK ??

    # Note: for now defining a `GET` handler also automatically defines
    # a `HEAD` handler  (follows sinatra convention)
    def get( pattern, &block )
      route( GET,   pattern, &block )
      route( HEAD,  pattern, &block )
    end

    def post( pattern, &block)    route( POST,    pattern, &block ); end
    def patch( pattern, &block)   route( PATCH,   pattern, &block ); end
    def put( pattern, &block)     route( PUT,     pattern, &block ); end
    def delete( pattern, &block)  route( DELETE,  pattern, &block ); end
    def head( pattern, &block)    route( HEAD,    pattern, &block ); end
    def options( pattern, &block) route( OPTIONS, pattern, &block ); end

    def route( method, pattern, &block )
      puts "[debug] Webservice::Metal.#{method.downcase} - add route #{method} '#{pattern}' to #<#{self.name}:#{self.object_id}> : #{self.class.name}"

      ## note: for now use (default to) the sintatra-style patterns (with mustermann)
      routes[method] << [Mustermann::Sinatra.new(pattern), block]
    end

    def routes
      @routes ||= Hash.new { |hash, key| hash[key]=[] }
    end

    def environment
      ## include APP_ENV why? why not?
      ##   todo -- cache value? why why not?  (see/follow sinatara set machinery ??)
      (ENV['APP_ENV'] || ENV['RACK_ENV'] || :development).to_sym
    end

    def development?() environment == :development; end
    def production?()  environment == :production;  end
    def test?()        environment == :test;        end

    ## convenience method
    def run!
      puts "[debug] Webservice::Metal.run! - self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"  # note: assumes self is class
      app    = self     ## note: use self; will be derived class (e.g. App and not Base)
      port   = 4567
      Rack::Handler::WEBrick.run( app, Port:port ) do |server|
        ## todo: add traps here - why, why not??
      end
    end
  end  ## class << self


  attr_reader :request
  attr_reader :response
  attr_reader :params
  attr_reader :env


  def call( env )
    dup.call!( env )
  end

  def call!( env )
    env['PATH_INFO'] = '/'  if env['PATH_INFO'].empty?

    @request   = Rack::Request.new( env )
    @response  = Rack::Response.new
    @params    = request.params
    @env       = env

    catch(:halt) do
      ## call before if defined in derived (sub)classes
      before  if respond_to? :before

      route!
    end

    @response.finish
  end


  def halt( *args )
    response.status = args.detect{ |arg| arg.is_a?(Fixnum) } || 200
    response.header.merge!( args.detect{ |arg| arg.is_a?(Hash) } || {} )
    response.body = [args.detect{ |arg| arg.is_a?(String) } || '']
    throw :halt, response           ## todo/check response arg used - what for??
  end


private

  ## run a route block and throw :halt
  def route_eval( &block )
    obj = instance_eval( &block )    ## return result - for now assumes a single object

    if respond_to? :handle_response
      handle_response( obj )    ## prepare response
    else
      ## default response; string expected
      ##   if string pass it along
      ##   if NOT string for debugging / dump to string with inspect
      response.status = 200
      response.body   = [obj.is_a?(String) ? obj.to_s : obj.inspect]
    end

    throw :halt
  end


  def route!( base=self.class )

    puts "  [#{base.name}] try matching route >#{request.request_method} #{request.path_info}<..."

      routes = base.routes[ request.request_method ]
      routes.each do |pattern, block|
        ## puts "trying matching route >#{request.path_info}<..."
        url_params = pattern.params( request.path_info )
        if url_params   ## note: params returns nil if no match
          ## puts "  BINGO! url_params: #{url_params.inspect}"
          if !url_params.empty?   ## url_params hash NOT empty (e.g. {}) merge with req params
            ## todo/fix: check merge order - params overwrites url_params - why? why not??

            ## todo/fix: check params - params works with string keys only - check for indiffent keys - why? why not?
            ##   check rack params - works with indifferent keys by default??
            @params = url_params.merge( @params )
          end
          route_eval( &block )
          ##  todo/check: keep return - why? why not?  - note: route_eval will always throw :halt
          ## handler.handle_response( instance_eval( &block ))
          ## return
        end
      end

      ## check recursive - all super(parent)classes too (e.g. App > Base > Metal etc.)
      ##   note: superclass is the parent class (returns nil if no more parent class)
      if base.superclass.respond_to? :routes
        route!( base.superclass )
        return
      end

      # no match found for route/request
      halt 404
  end


end # class Metal

end # module Webservice
