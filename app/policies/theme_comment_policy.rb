class ThemeCommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    owner_or_editor_or_admin?
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
