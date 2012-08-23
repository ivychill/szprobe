# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
addrs = null
startIndex = 0
resolved_pois = 0
to_be_resolved_pois = []
global_timer = 0;

$(document).ready ->
	#initMap()
	#when get all static_roads(index view), call ajax.get to fetch all roads with Pois
	if ($(location).attr('pathname').match /static_roads(\/)?$/)
		allroads = get_all_roads()
	else if ($(location).attr('pathname').match /fix(\/)?$/)
		alert("fixing")

processRoads = (data) ->
	#str_road = ''
	#for xx in data
	#	str_road += xx.name
	#alert str_road
	addrs = data
	showAllPois()
	alert("total resolved pois: "+resolved_pois)
	geocodeSearch()

showAllPois = () ->
	for road in addrs
		#if road.pois has a lat, lng add a marker
		if road.static_pois
			for poi in road.static_pois
				if poi.lat && poi.lng
					point = new BMap.Point(poi.lng, poi.lat)
					#addMarker(point, road.name+poi.ref, road.name+poi.ref)
					resolved_pois++
				else
					#push this poi to an unresolved poi
					poi_obj = {road_id:road._id, road_name:road.name, ref:poi.ref, ref_type:poi.ref_type}
					to_be_resolved_pois.push(poi_obj)
					

geocodeSearch = () ->
	ii = 0
	#for road in [addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], addrs[5]]
	for poi in to_be_resolved_pois
		continue if ii++ < startIndex
		get_lat_lng(poi.road_name, poi.ref, poi.ref_type, (point) ->
			if (point)
				poi.lat = point.lat
				poi.lng = point.lng
				#addrComp = point.addressComponents
				#ajax post poi to server
				poi_url = "/static_roads/"+poi.road_id+"/static_pois"
				$.ajax({
					type: 'POST',
					url: poi_url,
					data: poi,
					success: ->
						return
					,
					dataType: "json"
				})							
				addMarker(point, poi.road_name+poi.ref, poi.road_name+poi.ref)
			)
		clearTimeout(global_timer)
		global_timer = setTimeout(geocodeSearch, 500)
		startIndex++
		return
		
get_all_roads = () ->
	$.get("/static_roads", processRoads, "json")