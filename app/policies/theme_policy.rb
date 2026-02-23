class ThemePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  def transition?
    owner_or_admin?
  end

  def archived?
    true
  end

  class Scope < ApplicationPolicy::Scope
  end
end
