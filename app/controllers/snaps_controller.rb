require 'ffi-rzmq'

class SnapsController < ApplicationController
  # GET /snaps
  # GET /snaps.json
  def index
    @snaps = Snap.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @snaps }
    end
  end

  # GET /snaps/1
  # GET /snaps/1.json
  def show
    @snap = Snap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @snap }
    end
  end

  # GET /snaps/new
  # GET /snaps/new.json
  def new
    @snap = Snap.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @snap }
    end
  end

  # GET /snaps/1/edit
  def edit
    @snap = Snap.find(params[:id])
  end

  # POST /snaps
  # POST /snaps.json
  def create
    @snap = Snap.new(params[:snap])
    @snap.ts = Time.now

    respond_to do |format|
      if @snap.save
        #assign tasks to traffic-crawler-worker
        total_links = @snap.congested_roads.size
        puts total_links
        slots = total_links < 10 ? total_links:10
        #init tasks
        arrayCrawlerTasks = Array.new slots
        for tsk in 0..(slots-1)
          arrayCrawlerTasks[tsk] = CrawlerTask.new
          arrayCrawlerTasks[tsk].snap_ts = @snap.ts
          arrayCrawlerTasks[tsk].carrier = "traffic-crawler-worker-"+(1+tsk).to_s
        end
        for idx in 0..(total_links-1)
          slot = idx%10
          crawler_link = arrayCrawlerTasks[slot].crawler_links.new
          crawler_link.href = @snap.congested_roads[idx].href
          crawler_link.rn = @snap.congested_roads[idx].rn
        end
        
        for tsk in 0..(slots-1)
          arrayCrawlerTasks[tsk].save
        end
        
        #inform_workers_by_zmq slots
          
        format.html { redirect_to @snap, notice: 'Snap was successfully created.' }
        format.json { render json: "succeeded!", status: :created, location: @snap }
      else
        format.html { render action: "new" }
        format.json { render json: @snap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /snaps/1
  # PUT /snaps/1.json
  def update
    @snap = Snap.find(params[:id])

    respond_to do |format|
      if @snap.update_attributes(params[:snap])
        format.html { redirect_to @snap, notice: 'Snap was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @snap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snaps/1
  # DELETE /snaps/1.json
  def destroy
    @snap = Snap.find(params[:id])
    @snap.destroy

    respond_to do |format|
      format.html { redirect_to snaps_url }
      format.json { head :no_content }
    end
  end
  
  def inform_workers_by_signal(slots)
    for slot in 1..slots
      worker_pid_file = "/tmp/szprobe/pids/traffic-crawler-worker-"+slot.to_s+".rb"
      pid = File.read(worker_pid_file)
      Process.kill "USR1", pid.to_i
    end
  end

  def inform_workers_by_zmq(slots)
       #context = ZMQ::Context.new(10)
       #outbound_sockets = []
          
        for tsk in 0..(slots-1)
          #notify them by zmq
          context = ZMQ::Context.new(1)
          #outbound = context.socket(ZMQ::DEALER)
          outbound = context.socket(ZMQ::DEALER)
          #outbound.connect("ipc://traffic.ipc-"+"traffic-crawler-worker-"+(1+tsk).to_s)
          outbound.connect("tcp://localhost:910"+(1+tsk).to_s)
          logger.debug "connected:"+"tcp://localhost:910"+tsk.to_s
          puts "connected:"+"tcp://localhost:910"+tsk.to_s
          outbound.send_string "wake up"
          #outbound_sockets.push outbound
          outbound.close
          context.terminate
        end
        
        puts "kkk"
       # outbound_sockets.each do |outbound|
       #   outbound.close
       # end
        puts "ffff"
        #context.terminate
        puts "dddd"

  end
end
