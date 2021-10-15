# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, ClientClass
    can :read, Reservation
    can :read, GlobalOption
    can :read, Option
    can :read, Site
    can :read, Subnet
    can :read, Exclusion
    can :read, Zone
    can :read, ReservationOption

    if user.editor?
      can :manage, ClientClass
      can :manage, Reservation
      can :manage, GlobalOption
      can :manage, Option
      can :manage, Site
      can :manage, Subnet
      can :manage, Exclusion
      can :manage, Zone
      can :manage, ReservationOption
      can :manage, Lease
      can :manage, :import
    end
  end
end
