class StaticPoisController < ApplicationController
  def create
    @road = StaticRoad.find(params[:road_id])
    puts params[:ref]
    @poi = @road.static_pois.find_or_create_by(:ref => params[:ref]).update_attributes(:lat => params[:lat], :lng => params[:lng])
    redirect_to @road, :notice => "poi created!"
  end
end
