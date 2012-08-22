#encoding: utf-8

$reg_desc = /(东向|西向|东南向|东北向|西南向|西北向|南向|北向): /
$reg_tsr = /(\t|\r|\n| )*/ #tab, space, return
$reg_cross_road = /路口/
$reg_two_roads = /(.*路)(.*路)/

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

$reg_whitespace = /\s*/ #tab, return, space
$reg_direction = /^.+向(:|：)/
$reg_cross = /(道|路)?路口$/

def traffic_lexical_v2(roadname, traffic_desc)
  from_to_desc = traffic_desc.gsub($reg_whitespace, "").sub($reg_direction, "")
  #puts "desc: "+from_to_desc

  from_and_to = from_to_desc.split /->/

  objs_to_process = [{:desc=>from_and_to[0], :poi => {:ref=>"", :ref_type=>""}}, {:desc => from_and_to[1], :poi => {:ref=>"", :ref_type=>""}}]

  for obj in objs_to_process do 
    #obj[:poi][:ref] = obj[:desc].dup #alternate for the next line
    obj[:poi][:ref] = obj[:desc].clone
    road_tail = $reg_cross.match(obj[:poi][:ref])
    obj[:poi][:ref].gsub!($reg_cross, "")<<road_tail.to_s[0] if road_tail
    obj[:poi][:ref].gsub! roadname, ""
    obj[:poi][:ref_type] = "路口" if ($reg_cross.match obj[:desc])
  end

  #puts objs_to_process.inspect
  objs_to_process    
end

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
end

#puts traffic_lexical("教育中路", "北向: 兴华路教育中路口->教育中路吉祥路口")
#puts traffic_lexical("教育中路", "南向: 兴华路教育中路口->教育中路联想大厦")
#puts duration_lexical("201秒")
#puts duration_lexical("1m21s")
#puts duration_lexical("1分21s")
#puts duration_lexical("1分钟21s")
#puts duration_lexical("66m21秒")
#puts duration_lexical("1时7分21s")

#v2 test cases
#puts traffic_lexical("上步路", " 北向: 红荔路口->笋岗西路路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical("福田南路", " 北向: 百合路福田南路口->皇岗海关\r\n\t\t\t\t\t  ")
#puts traffic_lexical("北环大道", " 南山方向: 松岗收费站->沙江路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical("布澜路", " 西向: 布澜路扳雪岗大道路口->布澜路冲之大道路口\r\n\t\t\t\t\t  ")
#puts traffic_lexical("布澜路", " 西向: 扳雪岗大道布澜路口->冲之大道布澜路口\r\n\t\t\t\t\t  ")


