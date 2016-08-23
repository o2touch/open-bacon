module ControllerMockMacros
  # stubbed shit... there is no user
  def signed_out
    request.env['warden'].stub(:authenticate!).and_throw(:warden, {:scope => :user})
    controller.stub :current_user => nil
  end

  def signed_in(user=double("user"))
    request.env['warden'].stub :authenticate! => user
    controller.stub :current_user => user
  end

  # stub the fuck out of ability so everyone is always hap
  # Use this one to not have to worry about perms
  def fake_ability
    @ability ||= double("fake_ability")
    @ability.stub(authorize!: true)
    controller.stub(current_ability: @ability)
  end

  # actually use Ability, but only set the perm we care about, and mock it
  # to ensure the call is made.
  # Use this one to actually test the correct perms check is made
  def mock_ability(perms={})
    mock = false
    mock = true unless perms.has_key? :mock && perms[:mock] == false

    ability = Object.new
    ability.extend(CanCan::Ability)
    perms.each do |k, v|
      ability.can k, :all if v == :pass
      # commented as a work around... if manage comes in with :fail, and another perm
      # it will also cause that other perm to fail, even if it shouldn't. This way ability
      # still expects it, we just don't explicity disasslow it, as there isn't really any 
      # need (unless shit get very complex, which it isn't yet) as by default you cannot do
      # and ting. TS
      #ability.cannot k, :all if v == :fail
      ability.should_receive(:authorize!).at_least(1).times.with(k, anything).and_call_original if mock
    end
    controller.stub(current_ability: ability)
    ability
  end
end