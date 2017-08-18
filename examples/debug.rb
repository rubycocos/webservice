# encoding: utf-8


##  gets evaluated in class context (self is class) -- uses class_eval
puts "[debug] eval (top) self = name:>#{self.name}< object_id:(#{self.object_id})"

get '/hello' do

  ## gets evaluated in object context (self is object) -- uses instance_eval
  puts "[debug] eval (get /hello) self = name:>#{self.class.name}< object_id:(#{self.class.object_id})"

  data = { text: 'hello' }
  data
end
