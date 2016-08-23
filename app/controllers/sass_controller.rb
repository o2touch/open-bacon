class SassController < ApplicationController
  @@theme = 'app/assets/stylesheets/theme/default-theme'
  
  def show_user
    @user = User.find(params[:id])
    tenant = LandLord.new(@user).tenant
    variables = {
      :colour1 => '222222', 
      :colour2 => '222222',
      :import => 'user-theme'
    }
    render_sass(variables, tenant, @@theme)
  end

  def show_default
    tenant = LandLord.default_tenant
    variables = {
      :colour1 => '222222', 
      :colour2 => '222222',
      :import => nil
    }
    render_sass(variables, tenant, @@theme)
  end

  def show_event
    @event = Event.find(params[:id])
    @team = Team.find(@event.team_id)
    tenant = LandLord.new(@event).tenant
    variables = {
      :colour1 => @team.profile.colour1 || DefaultColourEnum::FAFT_DEFAULT_1, 
      :colour2 => @team.profile.colour2 || DefaultColourEnum::FAFT_DEFAULT_1, 
      :import => 'event-theme'
    }
    render_sass(variables, tenant, @@theme)
  end

  def show_club
    @club = Club.find(params[:id])
    tenant = LandLord.new(@club).tenant
    variables = {
      :colour1 => @club.profile.colour1 || DefaultColourEnum::FAFT_DEFAULT_1, 
      :colour2 => @club.profile.colour2 || DefaultColourEnum::FAFT_DEFAULT_2, 
      :import => 'club-theme'
    }
    render_sass(variables, tenant, @@theme)
  end

  def show_division
    # @division = DivisonSeason.find(params[:id])
    # tenant = LandLord.new(@division)
    tenant = LandLord.default_tenant
    variables = {
      :colour1 => '222222', 
      :colour2 => '222222',
      :import => 'division-theme'
    }
    render_sass(variables, tenant, @@theme)
  end

  def show_league
    @league = League.find(params[:id])
    tenant = LandLord.new(@league).tenant
    variables = {
      :colour1 => @league.colour1 || DefaultColourEnum::FAFT_DEFAULT_1, 
      :colour2 => @league.colour2 || DefaultColourEnum::FAFT_DEFAULT_2,
      :cover_image => @league.cover_image_url,
      :logo => @league.logo_large_url,
      :import => 'league-theme'
    }
    render_sass(variables, tenant, @@theme)
  end

  private
  
  # sass & scss read/compile function   
  def render_sass(variables, tenant, file)

    variables[:tenant] = tenant

    # With the Rendered ERB file, create a new Sass instance     
    sass_engine = Sass::Engine.new(render_to_string(
      :file => file,
      :handlers => [:erb], 
      :formats => [:scss],
      :layout => false,
      :locals => variables
    ), {
      :syntax => :scss,
      :style => :expanded,
      :load_paths => ['./app/assets/stylesheets'],
    })
    
    # render & send back the Sass instance
    headers["Content-Type"] = "text/css"  
    render text: sass_engine.render , :content_type => Mime::CSS
    
  end
  
end