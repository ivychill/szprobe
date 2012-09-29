#encoding: utf-8

$reg_desc = /(东向|西向|东南向|东北向|西南向|西北向|南向|北向): /
$reg_tsr = /(\t|\r|\n| )*/ #tab, space, return
$reg_cross_road = /路口/
$reg_two_roads = /(.*路)(.*路)/
$traffic_prefix = /目前拥堵路段/

def traffic_lexical(roadname, traffic_desc)
	from_and_to = traffic_desc.split /->/
	from_ref = from_and_to[0].gsub($reg_desc, "") 
	to_ref = from_and_to[1].gsub($reg_desc, "")
	objs_to_process = [{:desc=>from_ref, :poi => {:ref=>"", :ref_type=>""}}, {:desc => to_ref, :poi => {:ref=>"", :ref_type=>""}}]
	for obj in objs_to_process do 
		obj[:poi][:ref] = obj[:desc].gsub $reg_tsr, ""
		obj[:poi][:ref_type] = "路口" if (obj[:desc].match $reg_cross_road)
		reg_this_road = Regexp.new roadname+"(口*)"
		obj[:poi][:ref].gsub! reg_this_road, ""
		obj[:poi][:ref].gsub! $reg_cross_road, "路"
	end
	objs_to_process		
end
#puts traffic_lexical("教育中路", "北向: 兴华路教育中路口->教育中路吉祥路口")
#puts traffic_lexical("教育中路", "南向: 兴华路教育中路口->教育中路联想大厦")

$reg_whitespace = /\s*/ #tab, return, space
#$reg_direction = /(东向|西向|南向|北向|东南向|西南向|东北向|西北向)/
$reg_direction = /^.+向(:|：)/
$reg_cross = /(街|道|路)?路口$/
$reg_speed_en = /(\d*)km\/h/i
$reg_speed_cn = /(\d*)公里每小时/

def format_poi_ref(roadname, ref)
  road_tail = $reg_cross.match(ref)
  formated_ref = ref
  formated_ref = ref.gsub($reg_cross, "")<<road_tail.to_s[0] if road_tail
  result = formated_ref.gsub roadname, ""
  result.gsub! /(道){2}/, "道"
  result.gsub! /(路){2}/, "路"
  result.gsub! /道路/, "道"
  result.gsub! /路道/, "路"
  result.gsub! /街路/, "街"
  result.gsub! $reg_direction, ""
  result.gsub! /市区/, ""
  result
end

def format_speed(speedDesc)
  speed = ""
  if $reg_speed_en.match(speedDesc)
    speed = $1
  else 
    if $reg_speed_cn.match(speedDesc)
      speed = $1
    end
  end
end
#puts format_speed "15km/h"
#puts format_speed "15Km/h"
#puts format_speed "15公里每小时"

def direction_lexical(specifiedDesc)
  direction = ""
  if $reg_direction.match(specifiedDesc)
    direction = $&
  end
  direction.gsub! /(:|：)/, ""
  direction.gsub! $reg_whitespace, ""
end

#puts direction_lexical "北向: 兴华路教育中路口->教育中路吉祥路口"
#puts direction_lexical "南山方向: 兴华路教育中路口->教育中路吉祥路口"

def traffic_lexical_v2(roadname, traffic_desc)
  from_to_desc = traffic_desc.gsub($reg_whitespace, "").sub($reg_direction, "")
  #puts "desc: "+from_to_desc

  from_and_to = from_to_desc.split /->/

  objs_to_process = [{:desc=>from_and_to[0], :poi => {:ref=>"", :ref_type=>""}}, {:desc => from_and_to[1], :poi => {:ref=>"", :ref_type=>""}}]

  for obj in objs_to_process do 
    #obj[:poi][:ref] = obj[:desc].dup #alternate for the next line
    #obj[:poi][:ref] = obj[:desc].clone
    #road_tail = $reg_cross.match(obj[:poi][:ref])
    #obj[:poi][:ref].gsub!($reg_cross, "")<<road_tail.to_s[0] if road_tail
    #obj[:poi][:ref].gsub! roadname, ""
    obj[:poi][:ref] = format_poi_ref roadname, obj[:desc]
    obj[:poi][:ref_type] = "路口" if ($reg_cross.match obj[:desc])
  end

  #puts objs_to_process.inspect
  objs_to_process    
end
#v2 test cases
#puts traffic_lexical_v2("上步路", " 北向: 红荔路口->笋岗西路路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("福田南路", " 北向: 百合路福田南路口->皇岗海关\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("北环大道", " 南山方向: 松岗收费站->沙江路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("布澜路", " 西向: 布澜路扳雪岗大道路口->布澜路冲之大道路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("布澜路", " 西向: 扳雪岗大道布澜路口->冲之大道布澜路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("布澜路", " 西向: 扳雪岗大道布澜路道路口->冲之大道布澜路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical_v2("文锦中路", "文锦中路市区凤凰路口->冲之大道文锦中路口\r\n\t\t\t\t\t  ")


def duration_lexical(duration)
  #1m57s -> 117
  #1分57秒 -> 117
  reg = /(\d*)(h|H|时|小时)(\d*)(m|M|分|分钟)(\d*)(s|S|秒)/
  if duration.match reg
    hr = $1
    min = $3
    sec = $5
    return hr.to_i*3600+min.to_i*60+sec.to_i
  end
  reg = /(\d*)(m|M|分|分钟)(\d*)(s|S|秒)/
  if duration.match reg
    min = $1
    sec = $3
    return min.to_i*60+sec.to_i
  end
  reg = /(\d*)(s|S|秒)/
  if duration.match reg
    sec = $1
    return sec.to_i
  end
  ""
end
#puts duration_lexical("201秒")
#puts duration_lexical("1m21s")
#puts duration_lexical("1分21s")
#puts duration_lexical("1分钟21s")
#puts duration_lexical("66m21秒")
#puts duration_lexical("1时7分21s")

def traffic_lexical_wap_v1(raw_content, title_or_segments)
  #puts raw_content
  raw_content.gsub! $reg_whitespace, ""
  formated_raw_content = raw_content.dup
  roadname = ""
  title_or_segments.each do |ts|
  	ts.gsub! $reg_whitespace, ""
  	#puts "ts="+ts
  	if ts.match $traffic_prefix
  		raw_content.gsub! ts, "" 
  		roadname = ts.gsub $traffic_prefix, ""
  	else
  		formated_raw_content.gsub! ts, "%"
  	end
  end
  #puts raw_content
  #puts formated_raw_content
  speed_and_duration = formated_raw_content.split /%/
  speed_and_duration.each do |sd|
  	next if !sd || sd.length == 0
  	raw_content.gsub! sd, sd+"%"
  end
  #puts raw_content
  new_desc = raw_content.split /%/
  segments = []
  new_desc.each do |nd|
  	#puts nd
  	origina_desc = nd.dup
  	next if !nd || nd.length == 0
	speed_and_duration.each do |sd|
  		next if !sd || sd.length == 0
	  	nd.gsub! sd, ""
	end
  	start_end = nd.split /->/
	seg = { :desc => origina_desc,  
		:speed => format_speed(origina_desc),
		:direction => direction_lexical(origina_desc),
		:duration => duration_lexical(origina_desc),
		:start => {:ref=>"", :ref_type=>""}, 
		:end => {:ref=>"", :ref_type=>""}}
	seg[:start][:ref] = format_poi_ref roadname, start_end[0]
    	seg[:start][:ref_type] = "路口" if ($reg_cross.match start_end[0])
	seg[:end][:ref] = format_poi_ref roadname, start_end[1]
    	seg[:end][:ref_type] = "路口" if ($reg_cross.match start_end[1])
	segments.push seg
  end

  segments    
end
#wap_v1 test cases
#puts traffic_lexical_wap_v1("泰然九路目前拥堵路段北向：泰然九路泰然四路口->时代科技大厦 速度：10km/h通行时间：1分钟40秒南向：泰然九路泰然六路口->滨海大道泰然九路口 速度：9km/h通行时间：1分钟16秒", ["泰然九路目前拥堵路段", "北向：泰然九路泰然四路口->时代科技大厦 ", "南向：泰然九路泰然六路口->滨海大道泰然九路口 "])
#puts traffic_lexical_wap_v1("泰然九路目前拥堵路段北京方向：泰然九路泰然四路口->时代科技大厦 速度：101km/h通行时间：1小时2分钟40秒南向：泰然九路泰然六路口->滨海大道泰然九路口 速度：9km/h通行时间：1分钟16秒", ["泰然九路目前拥堵路段", "北京方向：泰然九路泰然四路口->时代科技大厦 ", "南向：泰然九路泰然六路口->滨海大道泰然九路口 "])


