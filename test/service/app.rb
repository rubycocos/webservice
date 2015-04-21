
get '/' do
  "Hello World"
end

get '/hello/:name' do
  "Hello #{params['name']}"
end

get '/:message/:name' do
  @message = params['message']
  @name    = params['name']
  "#{@message} #{@name}"
end

get '/halt/404' do
  halt 404  # 404 - not found
  ## todo: check why log reports 200-OK (for status code)!!
end

get '/halt_error' do
  halt 500, "Error fatal"  # 500 - internal server error
  ## todo: check why log reports 200-OK (for status code)!!
end

