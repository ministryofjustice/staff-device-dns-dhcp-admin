# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Reservation
    can :read, GlobalOption
    can :read, Option
    can :read, Site
    can :read, Subnet
    can :read, Zone

    if user.editor?
      can :manage, Reservation
      can :manage, GlobalOption
      can :manage, Option
      can :manage, Site
      can :manage, Subnet
      can :manage, Zone
    end
  end
end
