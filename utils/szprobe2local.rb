#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require "zmq"

#$last_checked = Time.now
$last_commit = Time.now
$interval_between_two_commit = 1*60

def last_three_snaps
	last_snaps = Snap.all.desc(:recorded).limit(3)
end

def last_traffic_snap(last_snap)
	$mylogger.info "last record:" + last_snap.recorded.to_s
	#return nil if ($last_checked-last_snap.recorded).abs < $interval_between_two_commit
	return nil if ($last_commit >= last_snap.recorded)
	if last_snap.summaries && last_snap.summaries.size > 5
		return nil if (last_snap.summaries.first.desc == nil && last_snap.summaries[4].desc == nil && last_snap.summaries[2].desc == nil)
	else
		return nil
	end
	#$last_checked = Time.now
	$last_commit = last_snap.recorded
	summaries = last_snap.summaries
	summaries.each do |summary|
		summary.scopes.each do |scope|
			objs_to_process = traffic_lexical(summary.name, scope.details)
			#objs_to_process = [{:desc=>from_ref, :poi => startPoi}, {:desc => to_ref, :poi => endPoi}]
			start_X_Y = getXY(summary.name, objs_to_process[0][:poi][:ref])
			scope.startX = start_X_Y[:X]
			scope.startY = start_X_Y[:Y]
			end_X_Y = getXY(summary.name, objs_to_process[1][:poi][:ref])
			scope.endX = end_X_Y[:X]
			scope.endY = end_X_Y[:Y]
		end
	end
	return last_snap
end

$mylogger = Logger.new File.expand_path("../../log/szprobe2local.log", __FILE__)

context = ZMQ::Context.new(1)
outbound = context.socket(ZMQ::PUB)
outbound.connect("tcp://localhost:6003")

loop do
	last_three_snaps.each do |last_snap|
		last_traffic = nil
		last_traffic = last_traffic_snap(last_snap)
		if last_traffic
			last_traffic_json = last_traffic.to_json
			#mylogger.debug last_traffic_json
			$mylogger.info "traffic to be sent to local"
			outbound.send last_traffic_json
		end
	end
	sleep $interval_between_two_commit
end
outbound.close