require_dependency "flyover_comments/application_controller"
require_dependency "flyover_comments/authorization"

module FlyoverComments
  class CommentsController < ApplicationController
    include FlyoverComments::Authorization
    include FlyoverComments::Concerns::CommentFiltering

    before_action :load_parent, only: :create
    before_action :load_commentable, only: [:index, :create]

    respond_to :json, only: [:create, :update]
    respond_to :html, only: [:create]
    respond_to :js, only: [:destroy, :show, :update]

    def index
      authorize_flyover_comment_index!
      load_filtered_comments_list(@commentable)
      render partial: "flyover_comments/comments/comments", locals: { comments: @comments }
    end

    def create
      @comment = FlyoverComments::Comment.new(comment_params)
      @comment._user = send(FlyoverComments.current_user_method.to_sym)
      @comment.commentable = @commentable
      @comment.parent = @parent
      authorize_flyover_comment_creation!

      flash_key = @comment.save ? :success : :error
      respond_with @comment do |format|
        format.html{ redirect_to :back, :flash => { flash_key => t("flyover_comments.comments.flash.create.#{flash_key.to_s}") } }
        format.json{
          if @comment.errors.any?
            render json: { errors: @comment.errors }, status: :unprocessable_entity
          else
            render partial: "flyover_comments/comments/comment", locals: { comment: @comment }
          end
        }
      end
    end

    def show
      @comment = FlyoverComments::Comment.find(params[:id])
      authorize_flyover_comment_show!
    end

    def update
      @comment = FlyoverComments::Comment.find(params[:id])
      @comment.assign_attributes(comment_params)
      authorize_flyover_comment_update!
      @comment.save
      respond_with @comment do |format|
        format.json{
          if @comment.errors.any?
            render json: { errors: @comment.errors }, status: :unprocessable_entity
          else
            render partial: "flyover_comments/comments/comment", locals: { comment: @comment }
          end
        }
      end
    end

    def destroy
      @comment = FlyoverComments::Comment.find(params[:id])
      authorize_flyover_comment_deletion!
      @comment.destroy
      respond_with @comment
    end

  private

    def comment_params
      params.require(:comment).permit(:content, :all_flags_reviewed)
    end

    def load_parent
      if params[:comment][:parent_id].present?
        @parent = FlyoverComments::Comment.find(params[:comment].delete(:parent_id))
        @commentable = @parent.commentable
        params[:comment].delete(:commentable_type)
        params[:comment].delete(:commentable_id)
      end
    end

    def load_commentable
      if @commentable.nil?
        type_param = params[:commentable_type] || params[:comment].delete(:commentable_type)
        commentable_type = type_param.camelize.constantize
        raise "Invalid commentable type" if commentable_type.reflect_on_association(:comments).nil?
        id_param = params[:commentable_id] || params[:comment].delete(:commentable_id)
        @commentable = commentable_type.find(id_param)
      end
    end

    def authorize_flyover_comment_index!
      raise "User isn't allowed to index comments" unless can_index_flyover_comments?(params, send(FlyoverComments.current_user_method.to_sym))
    end

    def authorize_flyover_comment_show!
      raise "User isn't allowed to view comment" unless can_view_flyover_comment?(@comment, send(FlyoverComments.current_user_method.to_sym))
    end

    def authorize_flyover_comment_update!
      raise "User isn't allowed to update comment" unless can_update_flyover_comment?(@comment, send(FlyoverComments.current_user_method.to_sym))
    end

    def authorize_flyover_comment_creation!
      raise "User isn't allowed to create comment" unless can_create_flyover_comment?(@comment, send(FlyoverComments.current_user_method.to_sym))
    end

    def authorize_flyover_comment_deletion!
      raise "User isn't allowed to delete comment" unless can_delete_flyover_comment?(@comment, send(FlyoverComments.current_user_method.to_sym))
    end

  end
end
