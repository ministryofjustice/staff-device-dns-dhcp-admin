# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Subnet
    can :read, Zone

    if user.editor?
      can :manage, Subnet
      can :manage, Zone
    end
  end
end
