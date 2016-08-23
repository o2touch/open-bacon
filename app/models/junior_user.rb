class JuniorUser < User
  has_many  :child_parent_relations,
            :class_name    => ParentChild.name,
            :foreign_key   => ParentChild::CHILD_KEY,
            :conditions    => ParentChild::CONDITIONS,
            :dependent     => :destroy

  has_many  :parents,
            :class_name    => User.name,
            :through       => :child_parent_relations,
            :source        => ParentChild::PARENT_FIELD,
            :source_type   => User.name

	after_create :set_roles

  # Enable Configurable Settings
  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent

  def associate_parent(parent)
    return parent if parents.include?(parent)

    relation = ParentChild.new
    relation.parent = parent
    relation.child = self
    relation.save!

    self.parent_child_relations << relation
    self.parents(true)
    parent
  end

  def unassociate_parent(parent)
    self.child_parent_relations.where(ParentChild::PARENT_KEY => parent).first.destroy
    self.parents(true)
  end

	def set_roles
		self.add_role RoleEnum::NO_LOGIN
		self.add_role RoleEnum::JUNIOR
	end

  def children
    []
  end

  def parent_child_relations
    []
  end

	def junior?
		true
	end

  def should_never_notify?
    true
  end

  def should_send_push_notifications?
    false
  end

	def contact_information_is_valid?
    unless self.mobile_number.blank? && self.email.blank?
      self.errors[:base] << "Contact information for junior users should be blank" 
    end
  end
end
