
    ##########################
    ##  support for "builtin" fallback routes
    ##
    ##  e.g. use like
    ##   fallback_route GET, '/' do
    ##     "Hello, World!"
    ##   end
    def fallback_route( method, pattern, &block )
      puts "[debug] Webservice::Base.#{method.downcase} - add (fallback) route #{method} '#{pattern}' to #<#{self.name}:#{self.object_id}> : #{self.class.name}"

      ## note: for now use the sintatra-style patterns (with mustermann)
      fallback_routes[method] << [Mustermann::Sinatra.new(pattern), block]
    end

    def fallback_routes
      ## note: !!! use @@ NOT just @ e.g.
      ##   routes get shared/used by all classes/subclasses
      @@fallback_routes ||= Hash.new { |hash, key| hash[key]=[] }
    end
