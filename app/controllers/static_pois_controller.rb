class StaticPoisController < ApplicationController
  def create
    @road = StaticRoad.find(params[:static_road_id])
    puts params[:ref]
    @poi = @road.static_pois.find_or_create_by(:ref => params[:ref]).update_attributes(:lat => params[:lat], :lng => params[:lng])
    redirect_to @road, :notice => "poi created!"
  end
  
  def update
    @road = StaticRoad.find(params[:static_road_id])
    @poi = @road.static_pois.find_or_create_by(:ref => params[:ref]).update_attributes(:lat => params[:lat], :lng => params[:lng], :fixed_at => Time.now)
    respond_to do |format|
      format.html # fix.html.erb
      format.json { render json: @road }
    end
  end
end
