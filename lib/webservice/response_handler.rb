# encoding: utf-8

## default (built-in) response handler

module Webservice


class ResponseHandler


  def initialize( app )
    @app = app
  end

  ## delegate request, response, params, env
  ##   todo/fix: use def_delegate - why? why not???
  def request()   @app.request;   end
  def response()  @app.response;  end
  def params()    @app.params;    end
  def env()       @app.env;       end

  ## delegate some helpers too
  def content_type( type=nil )  @app.content_type( type ); end



  ## todo: add as_json like opts={}  why? why not?
  def handle_response( obj, opts={} )
    puts "[Webservice::Handler#handle_response (#{request.path_info}) params: #{params.inspect}] - obj : #{obj.class.name}"
    pp obj

    ## "magic" param format; default to json
    format = params['format'] || 'json'

    ## note: response.body must be (expects) an array!!!
    ##   thus, [json] etc.

    if format == 'csv'  || format == 'txt' ||
       format == 'html' || format == 'htm'

      data = as_tabular( obj )

      if data.is_a? Tabular
        if format == 'csv'  || format == 'txt'
           content_type :txt   ## use csv content type - why? why not??
           response.body = [data.to_csv]
        else
          ## assume html
          content_type :html
          response.body = [data.to_html_table]
        end
      else
        ## wrong format (expected Tabular from as_tabular - cannot convert)
        ##   todo: issue warning/notice about wrong format - how?
        ##   use different http status code - why? why not??
        content_type :txt
        ##  todo/check: use just data.to_s  for all - why? why not?
        ## for now return as is (convert to string with to_s or inspect)
        response.body = [data.is_a?( String ) ? data.to_s : data.inspect]
      end
    else    ## default/assume json
      data = as_json( obj )

      ## note: hash or array required!!! for now for json generation
      #   hash   => single record
      #   array  => multiple records (that is, array of hashes)

      if data.is_a?( Hash ) || data.is_a?( Array )
        json = JSON.pretty_generate( data )   ## use pretty printer

        callback = params.delete( 'callback' )

        if callback
          content_type :js
          response.body = ["#{callback}(#{json})"]
        else
          content_type :json
          response.body = [json]
        end
      else
         ## todo/fix/check: change http status to unprocessable entity
         ##   or something --  why ??? why not??
         ##
         ##  allow "standalone" number, nils, strings - why? why not?
         ##   for now valid json must be wrapped in array [] or hash {}
         content_type :txt
         ##  todo/check: use just data.to_s  for all - why? why not?
         ## for now return as is (convert to string with to_s or inspect)
         response.body = [data.is_a?( String ) ? data.to_s : data.inspect]
      end
    end
  end  # method handle_response


  ##########################################
  ## auto-generate/convert "magic"

  def as_tabular( obj, opts={} )
     headers = []
     headers_clone = []  ## keep an unmodified (e.g. with symbols not string) headers/keys clone
     rows    = []
     errors  = []

     if obj.respond_to? :to_a    ### convert activerecord relation to array (of records)
       recs = obj.to_a
     elsif obj.is_a? Array
       recs = obj
     else
       ## return as is; cannot convert
       ##   todo/fix: handle cannot convert different (e.g. except etc.) - why? why not??
       puts "!!!! [as_tabular] sorry; can't convert <#{obj.class.name}> - Array or to_a method required"
       return obj
     end


       recs.each do |rec|
         puts "rec #{rec.class.name}"
         if rec.respond_to? :as_row
           row = rec.as_row
           rows << row.values   ## add rows as is 1:1
         elsif rec.respond_to?( :as_json_v3 ) ||
               rec.respond_to?( :as_json_v2 ) ||
               rec.respond_to?( :as_json )    ||
               rec.is_a?( Hash )   ## allow (plain) hash too  - give it priority (try first?) - why? why not??

           if rec.respond_to? :as_json_v3
               row = rec.as_json_v3
           elsif rec.respond_to? :as_json_v2
               row = rec.as_json_v2
           elsif rec.respond_to? :as_json
               row = rec.as_json
           else
               row = rec    ## assume it's already a hash (with key/value pairs)
           end

           ##  convert nested values e.g. array and hash to strings
           values = row.values.map do |value|
             if value.is_a? Hash
               ## todo: use our own "pretty printer" e.g. use unqouted strings - why? why not?
               value.to_json  ## use to_json "key": "value" instead of :key => "value"
             elsif value.is_a? Array
               ## todo: use our own "pretty printer" e.g. use unqouted strings - why? why not?
               ## value = "[#{value.join('|')}]" ## use | for joins (instead of ,) - why? why not?? keep comma(,) - why? why not??
               value.to_json
             else
               value
             end
           end
           pp values
           rows << values
         else
            ## todo: add record index - why? why not?
            puts "sorry; can't convert - as_row or as_json method or hash required"
            errors << "sorry; can't convert <#{rec.class.name}> - as_row or as_json method or hash required"
            next
         end

         ## check headers - always must match!!!!!!!
         if headers.empty?
           headers_clone = row.keys
           pp headers_clone
           headers = headers_clone.map { |header| header.to_s }
           pp headers
         else
           ## todo: check if headers match!!!
         end
       end  # recs.each

    if errors.empty?
      Tabular.new( headers, rows )
    else   ## return row of errors
      ##  return errors as a (simple) multi-line string - why? why not??
      errors.join( "\n" )
    end

  end   # method as_tabular


  def as_json( obj, opts={} )
    if obj.respond_to? :as_json_v3     ## try (our own) serializer first
      obj.as_json_v3
    elsif obj.respond_to? :as_json_v2     ## try (our own) serializer first
      obj.as_json_v2
    elsif obj.respond_to? :as_json     ## try (activerecord) serializer
      obj.as_json
    else
      obj   ## just try/use as is
    end
  end


######
#  Tabular helper/support class

  class Tabular

    attr_reader :headers
    attr_reader :rows

    def initialize( headers, rows )
      @headers = headers
      @rows    = rows
    end

    def to_csv( opts={} )
       ## allow changing of column/value separator (col_sep) - why? why not?
       ##   :col_sep => "\t"
       ##   :col_sep => ";"

       pp self

       CSV.generate( headers: true ) do |csv|
        csv << headers
        rows.each do |row|
          csv << row
        end
      end
    end # method to_csv


    def to_html_table( opts={} )

      ## todo/fix: html escape values - why? why not??

      pp self

      buf = ""
      buf << "<table>\n"
      buf << "  <tr>"
      headers.each do |header|
        buf << "<th>#{header}</th>"
      end
      buf << "</tr>\n"

      rows.each do |row|
        buf << "  <tr>"
        row.each do |value|
          buf << "<td>#{value}</td>"
        end
        buf << "</tr>\n"
      end
      buf << "</table>\n"
      buf
    end # method to_html_table
  end # class Tabular

end  # class ResponseHandler
end # module Webservice
