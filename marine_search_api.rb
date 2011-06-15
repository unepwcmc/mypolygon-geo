require 'sinatra'
require 'pg'
require 'json'
require 'active_support/core_ext/object/blank'


post '/marine_search/:name' do
  content_type :json
  json = {}

  data = JSON.parse(params['data'])

  if  !data.blank? && data.kind_of?(Array)
    begin
      case params[:name]
        when "coral"
          table_name = "coral"
          srid = 4326
        when "mangroves"
          table_name = "mangrove"
          # must figure out how to convert this...
          # ST_SetSRID/ST_Transform bump into the table's SRID constraint.
          srid = 4326
        else
          msg = "requested dataset does not exist: " + params[:name]
          puts msg
          raise msg
      end

      conn = PGconn.open(:dbname => 'mypolygon_data', :user => 'postgres', :password => '')

      data.each do |d|
        if d["id"].blank? || d["the_geom"].blank?
          raise "each search item must provide an id and a geom in WKT format"
        end

        arr = []
        sql = "
        SELECT
          ST_Area(ST_Intersection(
            ST_Union(the_geom),
            ST_GeomFromText('#{d["the_geom"]}', #{srid}))) as overlapped_area
        FROM #{table_name}
        WHERE ST_Intersects(ST_GeomFromText('#{d["the_geom"]}', #{srid}), the_geom)"
        
        puts sql
        #query the data
        result = conn.exec(sql)
        #ST_Intersects to get the geometries that touch it
        #ST_Union to merge them into a single shape
        #ST_Intersection to find the overlap
        #ST_Area to find the area of the overlap

        #construct the response
        # (The current query will return a single row with the total area of overlap for all the intersected polygons.
        #  this structure would make it possible to return the area for each one, and you could put in ids, names, etc. too)
        result.each do |row|
          next unless row['overlapped_area']   #don't bother if there's no overlap
          rjson = {
            :id => d["id"],
            :overlapped_area => row['overlapped_area']
          }
          arr << rjson
        end
        json[:results] = arr
      end
    rescue Exception => e
      msg = "An error occurred during the processing of your request #{e}"
      puts msg
      json = {:error => msg}
    ensure
      conn.close if conn
    end
  end

  json.to_json
end
