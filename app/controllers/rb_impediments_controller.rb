include RbCommonHelper

class RbImpedimentsController < RbApplicationController
  unloadable

  def create
    @settings = Backlogs.settings
    begin
      @impediment = RbTask.create_with_relationships(params, User.current.id, @project.id, true)
    rescue => e
      render :text => e.message.blank? ? e.to_s : e.message, :status => 400
      return
    end

    result = @impediment.errors.size
    status = (result == 0 ? 200 : 400)
    @include_meta = true

    respond_to do |format|
      format.html { render :partial => "impediment", :object => @impediment, :status => status }
    end
  end

  def update
    puts "update1"
    @impediment = RbTask.where(id: params[:id]).first
    @settings = Backlogs.settings
    puts "update2"
    begin
      result = @impediment.update_with_relationships(params)
    rescue => e
      render :text => e.message.blank? ? e.to_s : e.message, :status => 400
      return
    end
    puts "update3"
    status = (result ? 200 : 400)
    @include_meta = true
    puts "update4"
    respond_to do |format|
      format.html { render :partial => "impediment", :object => @impediment, :status => status }
    end
  end

end
