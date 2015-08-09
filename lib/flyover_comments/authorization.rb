module FlyoverComments
  module Authorization

    def can_delete_flyover_comment?(comment, user)
      if Object.const_defined?("Pundit") && policy = Pundit.policy(user, comment)
        policy.destroy?
      elsif user.respond_to?(:can_delete_flyover_comment?)
        user.can_delete_flyover_comment?(comment)
      else
        comment.user == user
      end
    end

    def can_create_flyover_comment?(comment, user)
      if Object.const_defined?("Pundit") && policy = Pundit.policy(user, comment)
        policy.create?
      elsif user.respond_to?(:can_create_flyover_comment?)
        user.can_create_flyover_comment?(comment)
      else
        comment.user == user
      end
    end

    def can_flag_flyover_comment?(comment, user)
      if Object.const_defined?("Pundit") && policy = Pundit.policy(user, FlyoverComments::Flag.new(comment: comment, user: user))
        policy.create?
      elsif user.respond_to?(:can_flag_flyover_comment?)
        user.can_flag_flyover_comment?(comment)
      else
        !user.nil?
      end
    end

  end
end
