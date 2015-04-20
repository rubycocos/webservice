# encoding: utf-8


module Webservice

class Base
  class << self

    ## todo/check: all verbs needed! (supported) - why, why not??
    %w(GET POST PATCH PUT DELETE HEAD OPTIONS).each do |method|
      define_method( method.downcase ) do |pattern, &block|
        puts "[debug] Webservice::Base.#{method.downcase} - add route #{method} '#{pattern}' to >#{self.name}< (#{self.object_id})"
        routes[method] << [compile_pattern(pattern), block]
      end
    end

##    def builder
##      @builder ||= Rack::Builder.new
##    end

    def routes
      @routes ||= Hash.new { |hash, key| hash[key]=[] }
    end


    def run!
      app_class = self  ## note: self will be derived class (e.g. App and not Base)
      puts "[debug] Webservice::Base.run! - self: >#{app_class.name}< (#{app_class.object_id}) : #{app_class.class.name}"  # assume self is class
      app_obj = app_class.new
      app = Rack::Builder.new
      app.map( '/' ) { run app_obj }  ## e.g. run App
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
  end


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

  def session
    request.env["rack.session"] || raise("Rack::Session handler is missing")
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
    ### todo/fix: set content type to json
    ###  call serializer or to_json

    ## note: dummy for now
    if obj.is_a?(String)
      response.write obj
    else
      response.write "hello - obj: #{obj.class.name} - to be done"
    end
  end

end # class Base
  
end # module Webservice

