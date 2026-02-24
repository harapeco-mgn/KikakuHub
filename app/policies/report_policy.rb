class ReportPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def index?
    admin?
  end

  def review?
    admin?
  end

  def dismiss?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      admin? ? scope.all : scope.none
    end

    private

    def admin?
      user&.admin?
    end
  end
end
