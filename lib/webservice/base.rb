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

  LOCATION      = 'Location'.freeze      # not available from Rack


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


    def redirect_to( uri, status=302 )    ## Note: 302 == Found, 301 == Moved Permanently
      halt status, { LOCATION => uri }
    end
    alias_method :redirect, :redirect_to


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
end  ## module Helpers


class Base
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
      puts "[debug] Webservice::Base.#{method.downcase} - add route #{method} '#{pattern}' to #<#{self.name}:#{self.object_id}> : #{self.class.name}"

      ## note: for now use the sintatra-style patterns (with mustermann)
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
      puts "[debug] Webservice::Base.run! - self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"  # note: assumes self is class
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


    ## (auto-)add (merge in) cors headers
    ##   todo: move into a before filter ??  lets you overwrite headers - needed - why? why not??
    headers 'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With',
            'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'

    route_eval

    @response.finish
  end


  def halt( *args )
    response.status = args.detect{ |arg| arg.is_a?(Fixnum) } || 200
    response.header.merge!( args.detect{ |arg| arg.is_a?(Hash) } || {} )
    response.body = [args.detect{ |arg| arg.is_a?(String) } || '']
    throw :halt, response
  end

private

  def route_eval
    catch(:halt) do
      routes = self.class.routes[ request.request_method ]
      routes.each do |pattern, block|
        ## puts "trying matching route >#{request.path_info}<..."
        url_params = pattern.params( request.path_info )
        if url_params   ## note: params returns nil if no match
          ## puts "  BINGO! url_params: #{url_params.inspect}"
          if !url_params.empty?   ## url_params hash NOT empty (e.g. {}) merge with req params
            ## todo/fix: check merge order - params overwrites url_params - why? why not??
            @params = url_params.merge( @params )
          end
          handle_response( instance_eval( &block ))
          return
        end
      end
      # no match found for route/request
      halt 404
    end
  end



  ## todo: add as_json like opts={}  why? why not?
  def handle_response( obj, opts={} )
    puts "[Webservice::Base#handle_response (#{request.path_info}) params: #{params.inspect}] - obj : #{obj.class.name}"
    pp obj

    ## "magic" param format; default to json
    format = params['format'] || 'json'

    ## note: response.body must be (expects) an array!!!
    ##   thus, [json] etc.

    if format == 'csv'  || format == 'txt' ||
       format == 'html' || format == 'htm'

      data = as_tabular( obj )

      ## note: array required!!!
      #   array   => multiple records (array of hashes)
      if data.is_a?( Array )
        if format == 'csv'  || format == 'txt'
           content_type :txt   ## use csv content type - why? why not??
           response.body = [generate_csv( data )]
        else
          ## asume html
          content_type :html
          response.body = [generate_html_table( data )]
        end
      else
        ## wrong format (expect array of hashes)
        ##   todo: issue warning/notice about wrong format - how?
        ##   use different http status code - why? why not??
        content_type :txt
        ##  todo/check: use just data.to_s  for all - why? why not?
        ## for now return as is (convert to string with to_s or inspect)
        response.body = [data.is_a?( String ) ? data.to_s : data.inspect]
      end
    else
      data = as_json( obj )

      ## note: hash or array required!!! for now for json generation
      #   hash   => single record
      #   array  => multiple records (that is, array of hashes)

      if data.is_a?( Hash ) || data.is_a?( Array )
        json = JSON.pretty_generate( data )   ## use pretty printer

        callback = params.delete( 'callback' )

        if callback
          content_type :js
          response.body = ["#{callback}(#{json})"]
        else
          content_type :json
          response.body = [json]
        end
      else
         ## todo/fix/check: change http status to unprocessable entity
         ##   or something --  why ??? why not??
         ##
         ##  allow "standalone" number, nils, strings - why? why not?
         ##   for now valid json must be wrapped in array [] or hash {}
         content_type :txt
         ##  todo/check: use just data.to_s  for all - why? why not?
         ## for now return as is (convert to string with to_s or inspect)
         response.body = [data.is_a?( String ) ? data.to_s : data.inspect]
      end
    end
  end  # method handle_response



  def generate_csv( recs )
    ## note: for now assumes (only works with) array of hash records e.g.:
    ## [
    ##     { key: 'at', name: 'Austria', ...},
    ##     { key: 'mx', name: 'Mexico', ...},
    ##     ...
    ## ]

    ## :col_sep => "\t"
    ## :col_sep => ";"

    ## todo: use rec.key for headers/first row

    ## pp recs

    CSV.generate do |csv|
      recs.each do |rec|
        csv << rec.values
      end
    end
  end


  def generate_html_table( recs )
    ## note: for now assumes (only works with) array of hash records e.g.:
    ## [
    ##     { key: 'at', name: 'Austria', ...},
    ##     { key: 'mx', name: 'Mexico', ...},
    ##     ...
    ## ]

    ## pp recs

    buf = ""
    buf << "<table>\n"
    recs.each do |rec|
      buf << "  <tr>"
      rec.values.each do |value|
        buf << "<td>#{value}</td>"
      end
      buf << "</tr>\n"
    end
    buf << "</table>\n"
    buf
  end


  ##########################################
  ## auto-generate/convert "magic"

  def as_tabular( obj, opts={} )
    ##  for now allow
    ##    as_tab, as_tabular  - others too? e.g. as_table why? why not?
    ##   like as_json will return a hash or array of hashes NOT a string!!!!

    if obj.respond_to? :as_tab
      obj.as_tab
    elsif obj.respond_to? :as_tabular
      obj.as_tabular
    else
      ## note: use as_json will return hash (for record) or array of hashes (for records)
      if obj.respond_to? :as_json
        obj.as_json
      else
        obj   ## just try/use as is (assumes array of hashesd)
      end
    end
  end


  def as_json( obj, opts={} )
    if obj.respond_to? :as_json_v3     ## try (our own) serializer first
      obj.as_json_v3
    elsif obj.respond_to? :as_json_v2     ## try (our own) serializer first
      obj.as_json_v2
    elsif obj.respond_to? :as_json     ## try (activerecord) serializer
      obj.as_json
    else
      obj   ## just try/use as is
    end
  end

end # class Base

end # module Webservice
