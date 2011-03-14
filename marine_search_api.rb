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
      result_sets = ["coral", "seagrass", "mangrove"]

      if !result_sets.include?(params[:name])
        raise "requested dataset does not exist"
      end

      conn = PGconn.open(:dbname => 'coral_distribution_2', :user => 'postgres', :password => '')

      data.each do |d|
        if d["id"].blank? || d["the_geom"].blank?
          raise "each search item must provide an id and a geom in WKT format"
        end

        arr = []

        #query the data
        result = conn.exec("SELECT
          ST_Area(
            ST_Transform(
              ST_Intersection(uni_coral.singlegeom,ST_GeomFromText('#{d["the_geom"]}',4326))
              , 954009)
          )
          FROM
          (Select ST_Union(the_geom) as singlegeom from #{params[:name]}_dev
          where
            ST_Intersects(ST_GeomFromText('#{d["the_geom"]}',4326), the_geom)) as uni_coral"
        )
        #ST_Intersects to get the geometries that touch it
        #ST_Union to merge them into a single shape
        #ST_Intersection to find the overlap
        #ST_Area to find the area of the overlap

        #construct the response
        # (The current query will return a single row with the total area of overlap for all the intersected polygons.
        #  this structure would make it possible to return the area for each one, and you could put in ids, names, etc. too)
        result.each do |row|
          unless !row['st_area']   #don't bother if there's no overlap
            rjson = {
              :area => row['st_area']
            }
            arr << rjson
          end
        end
        json[:results] = arr
      end

    rescue Exception => e
      msg = "An error occurred during the processing of your request #{e}"
      puts msg
      json = {:error => msg}
    end
  end

  json.to_json
end