#encoding: utf-8
class StaticRoadsController < ApplicationController
  def index
    @roads = StaticRoad.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roads }
    end
  end

  def new
    @road = StaticRoad.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @road }
    end
  end

  def show
    @road = StaticRoad.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @road }
    end
  end

  # POST /road
  # POST /road.json
  def create
    @road = StaticRoad.new(params[:static_road])
    xxRoad = StaticRoad.find_or_create_by(:name=>@road.name)
    @road.static_pois.each do |poi|
	xxRoad.static_pois.find_or_create_by(:ref => poi.ref, :ref_type => poi.ref_type)
    end
    respond_to do |format|
        format.html { redirect_to xxRoad, notice: 'road was successfully created.' }
        format.json { render json: xxRoad}
    end
    		
#    respond_to do |format|
#      if @road.save
#        format.html { redirect_to @road, notice: 'road was successfully created.' }
#        format.json { render json: {:result=>"succeeded!"}, status: :created, location: @road }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @road.errors, status: :unprocessable_entity }
#      end
#    end
  end

  def fetch_null_latlng
    static_roads = []
    StaticRoad.all.each do |static_road|
    	next unless static_road.static_pois
    	static_road.static_pois.each do |static_poi|
    	  next if static_poi.lat && static_poi.lng
    	  static_roads.push static_road
    	  break
    	end
    end
    static_roads
  end
  
  def fetch_hotroads
    hotroads = ["北环大道", "梅观高速", "南海大道", "滨海路", "滨河大道", "皇岗路", "新洲路", "月亮湾大道", #"叶",
    		"沙河西路", "红荔路", "南坪快速", "福龙路", "香蜜湖路", "彩田路", "后海大道", #"陈",
    		"南山创业路", "宝安创业路", "南山大道", "留仙大道", "广深公路", "金田路", "扳雪岗大道", "布龙公路"]#, "蔡"
    static_roads = []
    static_roads = StaticRoad.any_in(name: hotroads)
  end
  
  def fix
    #@static_roads = StaticRoad.all.paginate :page => params[:page], :per_page => 11
    #@static_roads = fetch_null_latlng.paginate :page => params[:page], :per_page => 11
    @static_roads = fetch_hotroads.paginate :page => params[:page], :per_page => 11
    #puts @static_roads.to_json
    @static_pois = [] #@static_roads.first.static_pois
    
    respond_to do |format|
      format.html # fix.html.erb
      format.json { render json: @static_roads }
    end
  end

end
