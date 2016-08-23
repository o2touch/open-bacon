class GoalChecklist
  def initialize()
    @items = {}
  end

  def add_item(item)
    raise ArgumentError unless item.class < GoalCheckListItem

    @items[item.key] = item unless @items.has_key?(item.key)
  end

  def get_item(key)
    @items[key]
  end

  def get_items
    @items
  end

  def notify
    @items.each do |key, goal_checklist_item|
      goal_checklist_item.notify
    end
  end
end
