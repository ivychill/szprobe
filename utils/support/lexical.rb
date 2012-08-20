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

