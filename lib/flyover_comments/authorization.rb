module FlyoverComments
  module Authorization
    
    def can_delete_flyover_comment?(comment, user)
      if user.respond_to?(:can_delete_flyover_comment?)
        user.can_delete_flyover_comment?(comment)
      else
        comment.user == user
      end
    end

    def can_create_flyover_comment?(comment, user)
      if user.respond_to?(:can_create_flyover_comment?)
        user.can_create_flyover_comment?(comment)
      else
        comment.user == user
      end
    end

  end
end