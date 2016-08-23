class LeaguePresenter < Draper::Decorator

  delegate_all

  AGE_GROUPS = [:boys, :girls]

  AGE_GROUPS.each do |group|
    define_method "#{group}_age_groups" do
      object.settings[:"#{group}_age_groups"].nil? || object.settings[:"#{group}_age_groups"].empty? ? nil : object.settings[:"#{group}_age_groups"]
    end
  end

  def has_adult_divisions?
    (!object.settings[:adult_division_count].nil? && !object.settings[:adult_division_count].empty?)
  end

  # Used to decide whether to show claim actions
  def display_claim_actions?
    !object.claimed? && (!object.config.league_claimable.nil? && object.config.league_claimable == true)
  end
  alias_method :is_claimable?, :display_claim_actions?

  # Display Details
  def display_details?
    !self.boys_age_groups.nil? || !self.girls_age_groups.nil? || self.has_adult_divisions?
  end

  def get_country
    (!object.location.nil? && !object.location.country.nil?) ? object.location.country : 'None'
  end

end