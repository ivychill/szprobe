#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'tss.pb'

$mylogger = Logger.new File.expand_path("../../log/traffic_report.log", __FILE__)

context = ZMQ::Context.new(1)
$router = context.socket(ZMQ::DEALER)
$router.setsockopt ZMQ::IDENTITY, "traffic_collector"
$router.connect("tcp://localhost:7002")

$source = ""
$raw_points = ""

def get_msgs
  $source = ""
  $raw_points = ""
  
  $router.recv_string($source)
  $router.recv_string($raw_points)
  # messages is an array of ZMQ::Message objects
end

def handle_msgs
  traffic_stream = TrafficStream.new :source => $source, :received_at => Time.now
  traffic_report = Com::Luyun::Whereareyou::Shared::LYTrafficReport.new
  traffic_report.parse_from_string $raw_points
  #traffic_report.
  
  $messages
end

loop do
  get_msgs
  if $messages.size != 2
    $mylogger.error "wrong message"
  end
  handle_msgs
end
exit

