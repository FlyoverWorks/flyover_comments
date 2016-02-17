module FlyoverComments
  module Concerns
    module CommentFiltering

      def load_filtered_comments_list(commentable)
        @comments = commentable.comments.with_includes.top_level.page(params[:page]).per(10)
        @comments = @comments.highest_net_votes if params[:sort].present? && params[:sort] == "top" #need this first because of sql ordering or orders
        @comments = @comments.newest_first
        @comments = @comments.with_links if params[:with_links].present? && params[:with_links] != "false"
        @comments = @comments.not_blank if params[:exclude_blank].present? && params[:exclude_blank] != "false"

        if params[:filter] == "current_user"
          user = _flyover_comments_current_user
          if user.respond_to?(:filter_flyover_comments)
            @comments = user.filter_flyover_comments(@comments)
          end
        end
      end

    end
  end
end
