module Admin
  module Manage
    class UsersController < Admin::Manage::ApplicationController
      def find_resource(param)
        resource_class.find(param)
      end
    end
  end
end
