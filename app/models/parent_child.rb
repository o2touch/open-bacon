class ParentChild < Relation
  PARENT_KEY = :start_v_id
  CHILD_KEY = :end_v_id
  PARENT_FIELD = :start_v
  CHILD_FIELD = :end_v
  CONDITIONS = ['end_v_type = ? and start_v_type = ?', User.name, User.name]

  validates :start_v, :end_v, presence: true
  validates :start_v_type, :end_v_type, :inclusion => { :in => [ User.name ] }
  validate :parent_cannot_be_a_junior_user, :child_cannot_be_an_adult_user

  before_save :update_parent_child_counters

  def parent
    self.start_v
  end

  def parent=(user)
    self.start_v = user
  end

  def child
    self.end_v
  end

  def child=(user)
    self.end_v = user
  end

private 
  def update_parent_child_counters
    User.decrement_counter(:children_count, self.start_v_id_was) if self.start_v_id_was
    User.increment_counter(:children_count, self.start_v_id)
  end

  def parent_cannot_be_a_junior_user
    if parent.present? && parent.junior?
      errors.add(:start_v, "can't be a junior user")
    end
  end

  def child_cannot_be_an_adult_user
    if child.present? && !child.junior?
      errors.add(:end_v, "can't be a adult user")
    end
  end
end
