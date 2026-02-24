class ThemePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    owner_or_editor_or_admin?
  end

  def destroy?
    owner_or_editor_or_admin?
  end

  def transition?
    owner_or_admin?
  end

  def archived?
    true
  end

  def hide?
    admin?
  end

  def unhide?
    admin?
  end

  def report?
    user.present? && !owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.visible
      end
    end
  end
end
