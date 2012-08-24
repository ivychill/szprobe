# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
addrs = null
startIndex = 0
resolved_pois = 0
to_be_resolved_pois = []
global_timer = 0
global_marker = null

$(document).ready ->
	initMap()
	#when get all static_roads(index view), call ajax.get to fetch all roads with Pois
	if ($(location).attr('pathname').match /static_roads(\/)?$/)
		allroads = get_all_roads()
	else if ($(location).attr('pathname').match /fix(\/)?$/)
		$('tr:even').removeClass().addClass("even_tr")
		$('.th').removeClass().addClass("th")
		$('#roads_canvas tr').click( ->
			return $(this).listPois())
		$('#pois_canvas tr').click( ->
			return $(this).panelToPoint())
		$('#pois_canvas tr').dblclick( ->
			$(this).updatePoi())
$.fn.updatePoi = () ->
	thisObj = $(this)
	poi_url = "/static_roads/"+$('.hiddenRID', thisObj).text()+"/static_pois/"+$('.hiddenPoiID', thisObj).text()
	poi_obj = {ref:$('.ref', thisObj).text(), ref_type:$('.ref_type', thisObj).text(), lat: $('.lat', thisObj).text(), lng: $('.lng', thisObj).text()}
	#$.ajax({type:'PUT', url: poi_url, data: poi_obj, dataType: "json", success:null})
	$.ajax({
		type: 'PUT',
		url: poi_url,
		data: poi_obj,
		success: ->
			return
		,
		dataType: "json"
		})							
	#alert(poi_url)
	return

$.fn.listPois = () ->
	thisObj = $(this)
	str_static_pois = $('.hiddenPois', thisObj).text()
	#alert(static_pois)
	static_pois = eval('(' + str_static_pois + ')')
	#alert(static_pois[0].lat)
	
	$('#pois_canvas #tbl_pois tr').remove()
	#$('#pois_canvas').append("<table id=tbl_pois></table>")
	$('#pois_canvas #tbl_pois').append("<tr><th>Ref</th><th>Reftype</th><th>lat</th><th>lng</th></tr>")
	#alert(static_pois.length)
	for ii in [0..static_pois.length-1]
		$('#pois_canvas #tbl_pois tbody').append("<tr class='poi_content' id='poi_"+ii+"'></tr>")
		tr_id = "#pois_canvas #tbl_pois tbody #poi_"+ii
		$(tr_id).append("<td class='ref'>"+static_pois[ii].ref+"</td>")
		$(tr_id).append("<td class='ref_type'>"+static_pois[ii].ref_type+"</td>")
		$(tr_id).append("<td class='hiddenRID'>"+$(".hiddenRID", thisObj).text()+"</td>")
		$(tr_id).append("<td class='hiddenPoiID'>"+static_pois[ii]._id+"</td>")
		$(tr_id).append("<td class='lat'>"+static_pois[ii].lat+"</td>")
		$(tr_id).append("<td class='lng'>"+static_pois[ii].lng+"</td></tr>")

	$('tr:even').removeClass().addClass("even_tr")
	$('.th').removeClass().addClass("th")
	
	$('#pois_canvas tr').click( ->
		return $(this).panelToPoint())
	$('#pois_canvas tr').dblclick( ->
		$(this).updatePoi())
	return

$.fn.panelToPoint = () ->
	thisObj = $(this)
	lat = $('.lat', thisObj).text()
	lng = $('.lng', thisObj).text()
	ref = $('.ref', thisObj).text()
	if lat && lng && lat != "" && lng != "" && lat != "null" && lng != "null"
		point = new BMap.Point(parseFloat(lng), parseFloat(lat))
		removeMarker(global_marker)
		addMarkerDraggable(point, ref, ref, (event) -> 
				newlng = event.point.lng
				newlat = event.point.lat
				$('.lat', thisObj).empty().text(newlat)
				$('.lng', thisObj).empty().text(newlng)
			(marker) ->
				global_marker = marker)
		map.setZoom(19)
		map.panTo(point)
	else
		map.addEventListener("click", (event) ->
				point = new BMap.Point(event.point.lng, event.point.lat)
				$('.lat', thisObj).empty().text(event.point.lat)
				$('.lng', thisObj).empty().text(event.point.lng)
				removeMarker(global_marker)
				addMarkerDraggable(point, ref, ref, (event) -> 
						newlng = event.point.lng
						newlat = event.point.lat
						$('.lat', thisObj).empty().text(newlat)
						$('.lng', thisObj).empty().text(newlng)
					(marker) ->
						global_marker = marker)
			)
	
	return
	

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