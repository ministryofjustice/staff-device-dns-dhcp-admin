# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Subnet

    if user.editor?
      can :manage, Subnet
    end
  end
end
