

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
