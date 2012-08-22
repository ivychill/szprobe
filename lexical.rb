#encoding: utf-8

$reg_whitespace = /\s*/ #tab, return, space
$reg_direction = /^.+向:/
$reg_cross = /(道|路)?路口$/

def traffic_lexical(roadname, traffic_desc)
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

puts traffic_lexical("上步路", " 北向: 红荔路口->笋岗西路路口\r\n\t\t\t\t\t  ")
puts traffic_lexical("福田南路", " 北向: 百合路福田南路口->皇岗海关\r\n\t\t\t\t\t  ")
puts traffic_lexical("北环大道", " 南山方向: 松岗收费站->沙江路口\r\n\t\t\t\t\t  ")
puts traffic_lexical("布澜路", " 西向: 布澜路扳雪岗大道路口->布澜路冲之大道路口\r\n\t\t\t\t\t  ")
puts traffic_lexical("布澜路", " 西向: 扳雪岗大道布澜路口->冲之大道布澜路口\r\n\t\t\t\t\t  ")

