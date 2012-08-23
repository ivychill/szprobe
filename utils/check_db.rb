#encoding: utf-8

require File.expand_path("../util_helper", __FILE__)

def db_status
	total_roads = StaticRoad.all.size
	total_pois = 0
	solved_pois = 0
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			total_pois = total_pois+1
			solved_pois=solved_pois+1 if poi.lat && poi.lng
			unless poi.lat || poi.lng
				ref_type = (poi.ref_type!=nil) ? poi.ref_type : ""
				puts road.name+"/"+poi.ref+"("+ref_type+")"
				#puts poi.lat
				#puts poi.lng
			end
		end
	end
	{:total_roads => total_roads, :total_pois => total_pois, :solved_pois => solved_pois}
end

def clear_db
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			if poi.lat && poi.lng
				drop_duplicated_records(road.static_pois, poi)
			end
		end
	end
end

#drop duplicated_records like two rows contain the same poi.ref
def drop_duplicated_records(pois, poi)
	pois.each do |xx|
		xx.destroy if xx.ref == poi.ref && (!xx.lat || !xx.lng)
	end
end

#锦龙路:淮河路口 -> 锦龙路:淮河路
#路口应该去重：高新南一道:科技南十路路->科技南十路 (删除格式化后重复的记录或者格式化)
def format_poi
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			poi.destroy unless poi.ref 
			formated_ref = format_poi_ref(road.name, poi.ref) 
			if poi.ref != formated_ref
				puts "路口应该去重："+road.name+":"+poi.ref+"->"+formated_ref 
				if road.static_pois.where(:ref => formated_ref).size>0
					puts "will delete this" 
					poi.destroy
				else
					poi.ref = formated_ref
					poi.lat = nil
					poi.lng = nil
					poi.save
				end
			end
		end
	end
end

#检查是否有重复的记录
def check_repeated_poi
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			if road.static_pois.where(:ref => poi.ref).size>1
				puts "repeated record:"+road.name+":"+poi.ref
				poi.destroy unless poi.lat || poi.lng
			end
		end
	end
end

def drop_null_ref
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			poi.destroy unless poi.ref 
		end
	end
end

def reset_lat_lng
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			poi.lat = nil
			poi.lng = nil
			poi.save 
		end
	end
end

def check_name_contains_urban
	StaticRoad.all.each do |road|
		road.static_pois.each do |poi|
			if poi.ref.match /市区/
				ref_type = (poi.ref_type!=nil) ? poi.ref_type : ""
				puts road.name+"/"+poi.ref+"("+ref_type+")" 
				#poi.ref = format_poi_ref road.name, 
			end
		end
	end
end

def show_diffrences
	json = File.read('static_roads-v2-frozen-20120822.json')
	roads = JSON.parse(json)
	
	roads.each do |rd|
		static_road = StaticRoad.where(:name => rd["name"]).limit(1).first
		#puts rd["name"]
		next unless rd["static_pois"]
		rd["static_pois"].each do |old_poi|
			new_poi = static_road.static_pois.where(:ref => old_poi["ref"]).limit(1).first
			if  new_poi
				if new_poi.lat != old_poi["lat"] || new_poi.lng != old_poi["lng"]
					oldlat = (old_poi["lat"]!=nil) ? old_poi["lat"] : ""
					oldlng = (old_poi["lng"]!=nil) ? old_poi["lng"] : ""
					newlat = (new_poi["lat"]!=nil) ? new_poi["lat"] : ""
					newlng = (new_poi["lng"]!=nil) ? new_poi["lng"] : ""
					puts rd["name"]+"/"+old_poi["ref"]+" has been changed. old one=("+oldlat+","+oldlng+"), new one =("+newlat+","+newlng+")" 
				end
			else
				puts rd["name"]+"/"+old_poi["ref"]+" has been changed" 
			end
		end
	end
end

check_name_contains_urban
puts db_status
drop_null_ref

#reset_lat_lng

#clear_db

#format_poi
show_diffrences
#check_repeated_poi

