# encoding: utf-8


module Webservice


module Helpers
    ## add some more helpers
    ##   "inspired" by sinatra (mostly) - for staying compatible
    ##   see https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb

    ## todo -- add redirect/redirect_to
    ##         add status -- why? why not??

    # Halt processing and return the error status provided.
    def error(code, body=nil)
      code = 500
      body = code.to_str if code.respond_to? :to_str

      response.body = body unless body.nil?
      halt code
    end

    # Halt processing and return a 404 Not Found.
    def not_found(body=nil)
      error 404, body
    end

    # Set multiple response headers with Hash.
    def headers(hash=nil)
      response.headers.merge! hash if hash
      response.headers
    end



    ## (simple) content_type helper - all "hard-coded" for now; always uses utf-8 too
    def content_type( type=nil )
      return response['Content-Type'] unless type

      if type.to_sym == :json
        response['Content-Type'] = 'application/json; charset=utf-8'
      elsif type.to_sym == :js || type.to_sym == :javascript
        response['Content-Type'] = 'application/javascript; charset=utf-8'
        ## use 'text/javascript; charset=utf-8'  -- why? why not??
        ## note: ietf recommends application/javascript
      elsif type.to_sym == :csv || type.to_sym == :text || type.to_sym == :txt
        response['Content-Type'] = 'text/plain; charset=utf-8'
      elsif type.to_sym == :html || type.to_sym == :htm
        response['Content-Type'] = 'text/html; charset=utf-8'
      else
        ### unknown type; do nothing - sorry; issue warning - why? why not??
      end
    end  ## method content_type
end  ## module Helpers


class Base
  include Helpers

  class << self

    ## todo/check: all verbs needed! (supported) - why, why not??
    ##   e.g. add LINK, UNLINK ??

    # Note: for now defining a `GET` handler also automatically defines
    # a `HEAD` handler  (follows sinatra convention)
    def get( pattern, &block)
      route( 'GET',   pattern, &block )
      route( 'HEAD',  pattern, &block )
    end

    def post( pattern, &block)    route( 'POST',    pattern, &block ); end
    def patch( pattern, &block)   route( 'PATCH',   pattern, &block ); end
    def put( pattern, &block)     route( 'PUT',     pattern, &block ); end
    def delete( pattern, &block)  route( 'DELETE',  pattern, &block ); end
    def head( pattern, &block)    route( 'HEAD',    pattern, &block ); end
    def options( pattern, &block) route( 'OPTIONS', pattern, &block ); end

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
      (ENV['RACK_ENV'] || :development).to_sym
    end

    def development?() environment == :development; end
    def production?()  environment == :production;  end
    def test?()        environment == :test;        end


    ## convenience method
    def run!
      puts "[debug] Webservice::Base.run! - self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"  # note: assumes self is class
      app    = self.new   ## note: use self; will be derived class (e.g. App and not Base)
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

  def call(env)
    dup.call!(env)
  end

  def call!(env)
    env['PATH_INFO'] = '/'  if env['PATH_INFO'].empty?
    @request   = Rack::Request.new(env)
    @response  = Rack::Response.new
    @params    = request.params
    @env       = env
    route_eval
    @response.finish
  end


  def halt( *args )
    response.status = args.detect{|arg| arg.is_a?(Fixnum) } || 200
    response.header.merge!(args.detect{|arg| arg.is_a?(Hash) } || {})
    response.body = [args.detect{|arg| arg.is_a?(String) } || '']
    throw :halt, response
  end

private

  def route_eval
    catch(:halt) do
      self.class.routes[request.request_method].each do |pattern, block|
        ## puts "trying matching route >#{request.path_info}<..."
        url_params = pattern.params( request.path_info )
        if url_params   ## note: params returns nil if no match
          ## puts "  BINGO! url_params: #{url_params.inspect}"
          if !url_params.empty?   ## url_params hash NOT empty (e.g. {}) merge with req params
            ## todo/fix: check merge order - params overwrites url_params - why? why not??
            @params = url_params.merge( params )
          end
          handle_response( instance_eval( &block ))
          return
        end
      end
      halt 404
    end
  end




  def handle_response( obj )
    puts "[Webservice::Base#handle_response (#{request.path_info}) params: #{params.inspect}] - obj : #{obj.class.name}"
    pp obj

    ## "magic" param format; default to json
    format = params['format'] || 'json'

    if format == 'csv' || format == 'txt'
      text = generate_csv( obj )
      content_type :text
      response.write text
    elsif format == 'html' || format == 'htm'
      text = generate_html_table( obj )
      content_type :html
      response.write text
    else
      json = generate_json( obj )

      callback = params.delete('callback')

      if callback
        content_type :js
        response.write "#{callback}(#{json})"
      else
        content_type :json
        response.write json
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


  def generate_json( obj )
    if obj.respond_to? :as_json_v2     ## try (our own) serializer first
      obj.as_json_v2
    elsif obj.respond_to? :as_json     ## try (activerecord) serializer
      obj.as_json_v2
    else
      ## just try/use to_json
      obj.to_json
    end
  end

end # class Base

end # module Webservice
