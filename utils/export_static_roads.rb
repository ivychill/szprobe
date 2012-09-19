#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

#$export_file = "static_roads-v2-frozen-20120822.json"
#$export_file = "static_roads-v2-frozen-20120823.json"
$export_file = "static_roads-v2-frozen-20120907.json"

File.open($export_file, "w") do |file|
	file.puts StaticRoad.all.to_json
end