#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'httparty'
require 'nokogiri'

#0928 Wap版本 有路况
#<div class="detail">
#<hh>
#泰然九路目前拥堵路段
#<br>
#</hh>
#<hh>
#速度：10km/h
#<br>
#通行时间：1分钟41秒
#<br>
#<hh>
#速度：3km/h
#<br>
#通行时间：5分钟26秒
#<br>
#<hh>
#速度：8km/h
#<br>
#通行时间：1分钟24秒
#<br>

#无路况
#<div class="detail">
#<img src="/m/16OXwdnqOB5zXE5ymBZH5ovNAe4KeN60wbG9NKNFiRccH-_DcJg-kdYpkSPFhbz60gTfRzJETj2UHr43wwWd_xb_aKW2oMUhbf--fGJucW6uQyU=.html">
#<br>
#<img src="/m/16OXKu9J-43ZhJDnLzmq0vowvjtY1EJLkLHsaRBv6EcfHRevMKvWDDiDwg==.html">
#<br>
#16:30发布，目前爱国路双向行驶无堵塞路段，请您保持车速，小心驾驶。
#</div>

$mylogger = Logger.new File.expand_path("../../log/wap_crawlers.log", __FILE__)
$worker_name = File.basename __FILE__, ".rb"
#$worker_name.match /(.*)(\d*)$/
#$worker_id = $2

context = ZMQ::Context.new(1)
$outbound2local = context.socket(ZMQ::PUB)
$outbound2local.connect("tcp://localhost:6003")
#$outbound2rc = context.socket(ZMQ::PUB)
#$outbound2rc.connect("tcp://roadclouding.com:6003")
$new_outbound2local = context.socket(ZMQ::PUB)
$new_outbound2local.connect("tcp://localhost:7003")
#$new_outbound2rc = context.socket(ZMQ::PUB)
#$new_outbound2rc.connect("tcp://roadclouding.com:7003")

def getAssignedTasks
	assignedTasks = CrawlerTask.where(:carrier => $worker_name, :status => 0)
end

class Rep
  include HTTParty
  format :html
  http_proxy '127.0.0.1', 8087
end

$wap_city_homepage = "http://wap.szicity.com/index.php/city_xuan/city_short/"
#通过首页分析出交通路况的链接如下：
#http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cIEv2r7VeC9s65gQ2EId7RDYZmx7fR_k6slm6_6h6X9M3XKiwrKh4j9VNq3yO5Teyp.html
$wap_links_url = "http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5BPdfsCz1htEKbL6RWJSxqkVL065nEu2E=.html"
$retrieving_counts = 0

#有路况的内容：
#泰然九路目前拥堵路段北向：泰然九路泰然四路口->时代科技大厦 速度：10km/h通行时间：1分钟40秒北向：泰然九路泰然六路口->泰然九路泰然四路口 速度：9km/h通行时间：1分钟16秒
def fetchTrafficAndSave(task)
	#$mylogger.info task.to_json
	#puts task.to_json
	begin
		timeStamp = Time.now
		puts "links="+task.crawler_links.to_s
		task.crawler_links.each do |road|
      road_traffics = []
		  #$mylogger.info road.wap_url
		  respHtml = Rep.get(road.wap_url)
			doc = Nokogiri::HTML(respHtml)
			road_traffic = nil
		  #puts doc
			doc.css("div.detail").each do |link|
				  puts link
				  traffic_desc = link.css("hh")
				  raw_content = link.content
				  puts raw_content
				  next if !traffic_desc || traffic_desc.size == 0
				  title_or_segments = []
				  traffic_desc.each do |title_or_segment|
				  	title_or_segments.push title_or_segment.content
				  end
				  #得到分析后的结果hash: [{speed=>9, direction=>"北向", duration=>160, desc=>"" ...}, ..]
				  segment_traffics = traffic_lexical_wap_v1 raw_content, title_or_segments
				  #puts segment_traffics
				  segment_traffics.each do |seg_desc|
					  road_traffic = RoadTraffic.find_or_create_by :rn => road.rn, :rid => road.href, :crawler_id => $worker_name, :ts => timeStamp, :ts_in_sec => timeStamp.to_i
					  segment = genSegment_wap_v1 road_traffic, seg_desc
				  end
			end
      road_traffic.save if road_traffic != nil
      road_traffics.push road_traffic if road_traffic != nil
      #road_traffics = RoadTraffic.where(:crawler_id => $worker_name, :ts => timeStamp)
      $mylogger.info "done one snap! "+task.snap_ts.to_s
      $mylogger.info "one traffic generated for "+road_traffics.to_json
      #puts road_traffics.to_json
      $outbound2local.send_string road_traffics.to_json if road_traffics.size>0
      #$outbound2rc.send_string road_traffics.to_json if road_traffics.size>0
      $new_outbound2local.send_string road_traffics.to_json if road_traffics.size>0
      #$new_outbound2rc.send_string road_traffics.to_json if road_traffics.size>0
		end
	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		return
	end
end

loop do
	$mylogger.debug "in loop "+$worker_name
	msg = ""
	task_list = getAssignedTasks
	$mylogger.debug task_list.to_json if task_list
	task_list.each do |task|
		fetchTrafficAndSave(task)
		task.status = 1
		task.save
	end
	sleep 60
end
exit

