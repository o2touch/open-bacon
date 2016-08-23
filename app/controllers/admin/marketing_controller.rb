class Admin::MarketingController < Admin::AdminController

  layout "admin_webarch"

  def clubs_to_tweet  
    
    results_from = params[:from].nil? ? Date.today : Date.parse(params[:from])

    q =  "SELECT DISTINCT t.id
          FROM clubs c, club_marketing_data cm, teams t
          WHERE c.club_marketing_data_id=cm.id AND t.club_id=c.id AND c.club_marketing_data_id=cm.id
          AND twitter IS NOT NULL"

    mysql_results = ActiveRecord::Base.connection.execute(q)
    teams_with_clubs_with_twitter = mysql_results.map { |r| r }.flatten

    # Select results containing teams whose clubs have a twitter handle
    all_fixtures = Fixture.where("created_at >= ? AND (home_team_id IN (#{teams_with_clubs_with_twitter.join(",")}) OR away_team_id IN (#{teams_with_clubs_with_twitter.join(",")}))", results_from.strftime("%Y-%m-%d"))

    @tweets = []

    all_fixtures.each do |r|

      tweet = {}

      tweet[:date] = r.created_at
      tweet[:result_type] = "WON"
      tweet[:league_name] = r.division.title

      if teams_with_clubs_with_twitter.include?(r.home_team_id) && !r.result.nil? && r.result.home_team_won?
        tweet[:team_name] = r.home_team.name
        tweet[:club_twitter] = r.home_team.club.marketing.twitter
        tweet[:against] = r.away_team.name
        tweet[:result] = r.result.home_final_score_str.to_s + " - " + r.result.away_final_score_str.to_s
        tweet[:team_url] = team_url(r.home_team)
        @tweets << tweet
      end
      if teams_with_clubs_with_twitter.include?(r.away_team_id) && !r.result.nil? && r.result.away_team_won?
        tweet[:team_name] = r.away_team.name
        tweet[:club_twitter] = r.away_team.club.marketing.twitter
        tweet[:against] = r.home_team.name
        tweet[:result] = r.result.away_final_score_str.to_s + " - " + r.result.home_final_score_str.to_s
        tweet[:team_url] = team_url(r.home_team)
        @tweets << tweet
      end

      
    end


    @csv = CSV.generate do |csv|
      return [] if @tweets.empty?
      # titles
      csv << @tweets.first.keys
    
      @tweets.each do |d|
        row = []
        d.each_value do |v|
          row << v
        end
        csv << row
      end
    end
  
    respond_to do |format|
      format.html { render }
      format.csv { render text: @csv, layout: false }
    end

  end

end