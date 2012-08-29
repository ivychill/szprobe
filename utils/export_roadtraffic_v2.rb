require File.expand_path("../util_helper", __FILE__)

def export_db_sort_by_absolute_cursor
  roadtraffic_size = RoadTraffic.all.size
  records_per_file = 80000
  for idx in 0..(roadtraffic_size/records_per_file+1)
    file_json = 'roadtraffic-v2-frozen-20120824-'+idx.to_s+'.json'
    File.open(file_json, 'w') do |file|
      file.puts RoadTraffic.asc(:snap_ts).limit(records_per_file).offset(idx*records_per_file).to_json
    end
  end
end


export_db_sort_by_absolute_cursor