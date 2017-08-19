

##    def builder
##      @builder ||= Rack::Builder.new
##    end



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


  def session
    request.env["rack.session"] || raise("Rack::Session handler is missing")
  end


### before mustermann

    ## todo/check: all verbs needed! (supported) - why, why not??
    HTTP_VERBS.each do |method|
      define_method( method.downcase ) do |pattern, &block|
        puts "[debug] Webservice::Base.#{method.downcase} - add route #{method} '#{pattern}' to #<#{self.name}:#{self.object_id}> : #{self.class.name}"
        routes[method] << [compile_pattern(pattern), block]
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
