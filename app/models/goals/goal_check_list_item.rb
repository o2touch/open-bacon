class GoalCheckListItem

  def complete?
    true
  end

  def key
    self.class.name.underscore.to_sym
  end

  def to_json
    Rabl::Renderer.new('api/v1/goal_checklist_item/show', self, :view_path => 'app/views', :handler => :rabl, :format => 'hash').render
  end

  def notify 
    true
  end
end
