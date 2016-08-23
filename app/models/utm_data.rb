class UtmData < ActiveRecord::Base
	belongs_to :user

	attr_accessible :referer, :source, :medium, :term, :content, :campaign

	validates :referer, presence: true
end