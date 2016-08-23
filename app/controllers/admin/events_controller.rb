class Admin::EventsController < Admin::AdminController

  def index
    @events = Event.all;
  end
  
  
  def destroy
    event = Event.find(params[:id])
    event.delete
    
    redirect_to admin_index_index_path, :notice => "Event deleted successfully"
  end
  
end