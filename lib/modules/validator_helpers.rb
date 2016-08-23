module ValidationHelpers
  def validate_model_ids(ids, model_constant, valid_set=nil)
    begin
      models = ids.map { |x| model_constant.find(x) }
      return false if models.any? { |x| valid_set.include?(x) == false } 
    rescue
      false
    end
    true
  end
end