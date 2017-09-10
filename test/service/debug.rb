# encoding: utf-8


##  gets evaluated in class context (self is class) -- uses class_eval
puts "[debug] eval (top) self = #<#{self.name}:#{self.object_id}> : #{self.class.name}"

get '/hello' do

  ## gets evaluated in object context (self is object) -- uses instance_eval
  puts "[debug] eval (get /hello) self = #<#{self.class.name}:#{self.class.object_id}> : #{self.class.class.name}"

  data = { text: 'hello' }
  data
end
