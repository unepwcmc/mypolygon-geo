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
      result_sets = [
          "coral",
          #"seagrass",
          #"mangrove"
      ]

      if !result_sets.include?(params[:name])
        raise "requested dataset does not exist"
      end

      conn = PGconn.open(:dbname => 'coral_distribution_2', :user => 'postgres', :password => '')

      json[:results] = []
      data.each do |d|
        if d["id"].blank? || d["the_geom"].blank?
          raise "each search item must provide an id and a geom in WKT format"
        end

        arr = []

        #query the data
        # 4326 = SRID
        result = conn.exec("
        SELECT
          ST_Union(the_geom) as shape,
          SUM(shape_area) as shape_area,
          ST_Area(ST_Intersection(
            ST_Union(the_geom),
            ST_GeomFromText('#{d["the_geom"]}',4326))) as overlapped_area
        FROM #{params[:name]}_dev
        WHERE ST_Intersects(ST_GeomFromText('#{d["the_geom"]}',4326), the_geom)"
        )
        #ST_Intersects to get the geometries that touch it
        #ST_Union to merge them into a single shape
        #ST_Intersection to find the overlap
        #ST_Area to find the area of the overlap

        #construct the response
        # (The current query will return a single row with the total area of overlap for all the intersected polygons.
        #  this structure would make it possible to return the area for each one, and you could put in ids, names, etc. too)
        total_overlapped_area = 0
        result.each do |row|
          next unless row['overlapped_area']   #don't bother if there's no overlap
          rjson = {
            :id => d["id"],
            :data_standard => { "NAME" => "coral" },
            # no carbon data
            :simple_geom => "SRID=4326;#{row['shape']}",
            :protected_area_km2 => row['shape_area'],
            :query_area_protected_km2 => row['overlapped_area'],
            # ep1 seems like protectedPlanet url args or something... ignore?
            # example: "epl"=>"?size=197x124&maptype=terrain&path=fillcolor:0xED671E66|color:0xED671EFF|weight:2|enc:v|lvAfr|p_@wkB??ooBvkB??noB"
            :image => nil,
            :wdpaid => -1 # no information about this in coral DB...
          }
          total_overlapped_area += row["overlapped_area"].to_f
          arr << rjson
        end
        if arr.any?
          json[:results] << {
            :query_area_km2 => total_overlapped_area,
            :protected_areas => arr
          }
        end
      end
    rescue Exception => e
      msg = "An error occurred during the processing of your request #{e}"
      puts msg
      json = {:error => msg}
    end
  end

  json.to_json
end
