# Notes

## Todos


### as_tab on City.all queries


check if respond_to? :as_tab if not?
 - check if record object respons_to? :as_tab?  possible?
 - if yes use as_tab if content_type is csv/html otherwise use as_json_v3 etc.



### Add Header Row to CSV / Table Headers to HTML

Use rec.key for headers/first row for csv/html - why? why not??


### Content-Type

Use text/csv content type - why? why not??
use special case for windows (excel) e.g.

```
def csv_content_type
  case request.user_agent
  when /windows/i then 'application/vnd.ms-excel'
  else                 'text/csv'
  end
end
```


### Rack.builder

(auto-)wrap app in rack builder - why? why not?

- let you use `use` for middleware

- also support `map` or add a "custom" `mount` - why? why not?


```
builder = Rack::Builder.new do

  map "/rack" do
    run lambda{|env| [200, {"Content-Type" => "text/html"}, ["PATH_INFO: #{env["PATH_INFO"]}"]]}
  end

  map "/mini" do
    run MiniApp.new
  end

  run App.new
end

app = builder.to_app
```


### add before and after filters / hooks

add

```
before do
end

after do
end
```

why? why not??



### call.dup

sinatra 2.0 uses a mutex with synchonize on call

is call.dup still recommend
