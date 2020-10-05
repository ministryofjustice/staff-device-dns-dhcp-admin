# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Option
    can :read, Site
    can :read, Subnet
    can :read, Zone

    if user.editor?
      can :manage, Option
      can :manage, Site
      can :manage, Subnet
      can :manage, Zone
    end
  end
end
