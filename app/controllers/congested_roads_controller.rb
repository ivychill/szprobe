class CongestedRoadsController < ApplicationController
  def create
    @snap = Snap.find(params[:snap_id])
    @congested_road = @snap.congested_roads.create!(params[:congested_road])
    redirect_to @snap, :notice => "congested road created!"
  end
end
