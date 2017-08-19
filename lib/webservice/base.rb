# encoding: utf-8


module Webservice

class Base

  HTTP_VERBS = %w(GET POST PATCH PUT DELETE HEAD OPTIONS)


  class << self

    ## todo/check: all verbs needed! (supported) - why, why not??
    HTTP_VERBS.each do |method|
      define_method( method.downcase ) do |pattern, &block|
        puts "[debug] Webservice::Base.#{method.downcase} - add route #{method} '#{pattern}' to #<#{self.name}:#{self.object_id}> : #{self.class.name}"
        routes[method] << [compile_pattern(pattern), block]
      end
    end


    def routes
      @routes ||= Hash.new { |hash, key| hash[key]=[] }
    end


    ## convenience method
    def run!
      puts "[debug] Webservice::Base.run! - self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"  # note: assumes self is class
      app    = self.new   ## note: use self; will be derived class (e.g. App and not Base)
      port   = 4567
      Rack::Handler.get('webrick').run( app, Port:port ) do |server|
        ## todo: add traps here - why, why not??
      end
    end


  private

    def compile_pattern( pattern )
      keys = []
      pattern.gsub!( /(:\w+)/ ) do |match|
        keys << $1[1..-1]
        '([^/?#]+)'
      end
      [%r{^#{pattern}$}, keys]
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
      self.class.routes[request.request_method].each do |matcher, block|
        if match = request.path_info.match( matcher[0] )
          if (captures = match.captures) && !captures.empty?
            url_params = Hash[*matcher[1].zip(captures).flatten]
            @params = url_params.merge(params)
          end
          handle_response( instance_eval( &block ))
          return
        end
      end
      halt 404
    end
  end

  def handle_response( obj )
    puts "[Webservice::Base#handle_response] - obj : #{obj.class.name}"

    ### todo/fix: set content type to json

    if obj.respond_to?( :as_json_v2 )
      response.write obj.as_json_v2
    else
      ## just try/use to_json
      response.write obj.to_json
    end
  end


end # class Base

end # module Webservice
