class ThemeCommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < ApplicationPolicy::Scope
  end
end
