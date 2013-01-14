#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'httparty'
require 'nokogiri'

#0928 Wap版本 路况
#<.detail> <img>图片
#<div.detail><hh>上步路目前拥堵路段</hh><hh><img>北向：南园路口->深南中路口</hh> 速度：9km/h<br>通行时间：1分钟33秒<br>

#拥堵路列表
#<div class="daolu">
#B
#<br>
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y2XqGuYgQEA5w==.html">宝安公园路</a>
#.
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y06bPZIMs2YLA==.html">宝安前进一路</a>
#.
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y35nX7l41ZELg==.html">宝安北路</a>
#.
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y310rk5PX4ftA==.html">布龙公路</a>
#.
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y3RZNnLBE5s9A==.html">宝民二路</a>
#.
#<a href="/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5-5iPYLGh8AMDyDJI6qi_arKynq4r93y3siO9NB2DwoA==.html">北斗路</a>
#.
#<br>
#</div>


$mylogger = Logger.new File.expand_path("../../log/wap_crawlers.log", __FILE__)
$worker_name = File.basename __FILE__, ".rb"
$global_snap_ts = Time.now

def assignTasks(road, wap_url, sequence)
  #assignedTasks = CrawlerTask.where(:carrier => $worker_name)
  task = CrawlerTask.find_or_create_by :carrier => "wap-traffic-crawler-worker-"+(sequence%10+1).to_s, :status => 0
  if !task.snap_ts 
    task.snap_ts = $global_snap_ts
  else
    if ($global_snap_ts-task.snap_ts).abs >= 300000
      task = CrawlerTask.find_or_create_by :carrier => "wap-traffic-crawler-worker-"+(sequence%10+1).to_s, :status => 0, :snap_ts => $global_snap_ts 
    end
  end
  static_road = StaticRoad.where(:name=>road).first
  href = ""
  if !static_road 
    $mylogger.error road+" is not in database!"
  else
    href = static_road.href
  end
  task.snap_ts = Time.now
  task.crawler_links.new :rn => road, :wap_url => wap_url, :href => href
  task.save
end

class Rep
  include HTTParty
  format :html
  http_proxy '127.0.0.1', 8087
end

#$url_fixedpart = "http://wap.szicity.com/cm/jiaotong/szwxcsTrafficTouch/wap/roadInfo.do?roadid="
$wap_city_homepage = "http://wap.szicity.com/index.php/city_xuan/city_short/"
#通过首页分析出交通路况的链接如下：
#http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cIEv2r7VeC9s65gQ2EId7RDYZmx7fR_k6slm6_6h6X9M3XKiwrKh4j9VNq3yO5Teyp.html
$wap_links_url = "http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie5BPdfsCz1htEKbL6RWJSxqkVL065nEu2E=.html"
$retrieving_counts = 0

#127.0.0.1:52354 - - [Sep 28 22:23:58] "GET http://wap.szicity.com/index.php/city_xuan/city_short/ HTTP/1.1" 200 -
#首页
#127.0.0.1:52359 - - [Sep 28 22:24:00] "GET http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cIEv2r7VeC9s7Juscp5KyGG5NUHCkhqvLikXW5Nui7b0FHd7XGDpnRFV__AFuoo86Q.html HTTP/1.1" 200 -
#进入到交通链接
#127.0.0.1:52364 - - [Sep 28 22:24:01] "GET http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvuihAEpXEJQwmrr7BYEQqYxaQs6Xw4CAFogrblrSPYKknc28tbWs6GiXcOw9GEBx94WajM2wYwIK.html HTTP/1.1" 200 -
#可能是直接有更多路况
#127.0.0.1:52369 - - [Sep 28 22:24:02] "GET http://wap.szicity.com/m/16OXKu9J-43ZhJDnLzmq0vowvt_KgFtvZ9cI7noT8c78ie64PbXYyns2VRbVXEFzN2efLz7M4af23xw=.html HTTP/1.1" 200 -
#也有可能是网上交警

def fetch_url_of_all_roads
  if $retrieving_counts % 20 != 0
    return
  end
  begin
    respHtml = Rep.get($wap_city_homepage)
    doc = Nokogiri::HTML(respHtml)
    doc.css("div.nav a").each do |link|
      if link.content == "交通"
        entry_url = link['href']
        newRespHtml = Rep.get(entry_url)
        road_doc = Nokogiri::HTML(newRespHtml)
        road_doc.css("table.nav a").each do |nav|
          if nav.content == "路况"
            traffic_url = nav['href']
            traffic_html = Rep.get "http://wap.szicity.com"+traffic_url
            traffic_doc = Nokogiri::HTML(newRespHtml)
            traffic_doc.css("h2 div.more a").each do |newlink|
              if newlink.content == "更多"
                $wap_links_url = newlink['href']
                $mylogger.info "updated entry links: "+$wap_links_url
                return
              end
            end
          end
        end
      end
    end
  rescue
    $mylogger.error "wap-links-crawler, some errors happened:" + $!.to_s
    return
  end
end

def fetch_links
  all_links = $wap_links_url
  if !$wap_links_url.match(/http/)
    all_links = "http://wap.szicity.com"+$wap_links_url
  end
  begin
    respHtml = Rep.get(all_links)
    doc = Nokogiri::HTML(respHtml)
    seq = 0
    doc.css("div.daolu a").each do |link|
      #puts link
      assignTasks link.content, "http://wap.szicity.com"+link['href'], seq
      seq = seq + 1
    end
  rescue
    $mylogger.error "some errors happened:" + $!.to_s
    return
  end
  #puts seq.to_s+" roads in traffic jam"
end

loop do
  $mylogger.debug "link-crawler in loop "
  $global_snap_ts = Time.now
  #puts $global_snap_ts
  #puts $wap_links_url
  fetch_url_of_all_roads
  $mylogger.debug "link-crawler "+$wap_links_url
  #puts $wap_links_url
  if $global_snap_ts.hour < 22 && $global_snap_ts.hour >= 6
    fetch_links
  end
  
  $retrieving_counts = $retrieving_counts+1
  #puts $retrieving_counts
  
  sleep 180
end
exit

