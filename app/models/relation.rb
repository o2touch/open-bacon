class Relation < ActiveRecord::Base
  #validation to prevent same relation being created.
  belongs_to :start_v, polymorphic: true
  belongs_to :end_v, polymorphic: true
end
