# encoding: utf-8


puts "[debug] eval (top) self = >#{self.class.name}< (#{self.class.object_id})"

get '/hello' do

  puts "[debug] eval (get) self = >#{self.class.name}< (#{self.class.object_id})"

  data = { text: 'hello' }
  data
end

