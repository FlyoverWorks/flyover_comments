module FlyoverComments
  module CommentsHelper

    def flyover_comment_content(comment)
      if comment.deleted_at.nil?
        comment.content
      else
        "Commented deleted on #{comment.deleted_at.to_s(:normal)}"
      end
    end

    def flyover_comment_form(commentable, comment = nil,  parent: nil, form: {})
      comment ||= FlyoverComments::Comment.new({
        commentable_id: commentable.id,
        commentable_type: commentable.class.to_s,
        parent: parent
      })

      render "flyover_comments/comments/form", comment: comment, form_opts: form
    end

    def flyover_comments_list(commentable, comments: commentable.comments.top_level.newest_first, page: 1, per_page: 10)
      render "flyover_comments/comments/comments", commentable: commentable, comments: comments.page(page).per(per_page)
    end

    def flyover_comment_replies(comment, collapsed: true)
      render "flyover_comments/comments/replies", comment: comment, collapsed: collapsed
    end

    def edit_flyover_comment_link(comment, content = I18n.t('flyover_comments.comments.edit_link_text'), opt_overrides = {})
      return unless comment && can_update_flyover_comment?(comment, send(FlyoverComments.current_user_method.to_sym))

      opts = {
        id: "edit_flyover_comment_#{comment.id}",
        class: "edit-flyover-comment-link",
        data: {
          flyover_comment_id: comment.id,
          url: flyover_comments.comment_path(comment)
        },
      }.merge(opt_overrides)

      link_to content, flyover_comments.comment_path(comment), opts
    end

    def soft_delete_flyover_comment_link(comment, content = I18n.t('flyover_comments.comments.delete_link_text'), opt_overrides = {})
      return unless comment && can_soft_delete_flyover_comment?(comment, send(FlyoverComments.current_user_method.to_sym)) && comment.deleted_at.nil?

      opts = {
        id: "delete_flyover_comment_#{comment.id}",
        class: "delete-flyover-comment-button",
        data: {
          type: "script",
          confirm: I18n.t('flyover_comments.comments.delete_confirmation'),
          flyover_comment_id: comment.id
        },
        method: :delete,
        remote: true
      }.merge(opt_overrides)

      link_to content, flyover_comments.comment_path(comment, hide_after_deletion: opt_overrides[:hide_after_deletion]), opts
    end

    def hard_delete_flyover_comment_link(comment, content = I18n.t('flyover_comments.comments.delete_link_text'), opt_overrides = {})
      #return unless comment && can_hard_delete_flyover_comment?(comment, send(FlyoverComments.current_user_method.to_sym))

      opts = {
        id: "delete_flyover_comment_#{comment.id}",
        class: "delete-flyover-comment-button",
        data: {
          type: "script",
          confirm: I18n.t('flyover_comments.comments.delete_confirmation'),
          flyover_comment_id: comment.id
        },
        method: :delete,
        remote: true
      }.merge(opt_overrides)

      link_to content, flyover_comments.comment_path(comment, hard_delete: true), opts
    end

    def flag_flyover_comment_link(comment, content = I18n.t('flyover_comments.comments.flag_link_text'), opt_overrides = {})
      user = send(FlyoverComments.current_user_method.to_sym)
      return unless comment && can_flag_flyover_comment?(comment, user)

      opts = {
        id: "flag_flyover_comment_#{comment.id}",
        class: "flag-flyover-comment-button",
        data: {
          confirm: I18n.t('flyover_comments.comments.flag_confirmation'),
          flyover_comment_id: comment.id
        },
        method: :post,
        remote: true,
        form: { data: { type: "script" } },
        params: { "flag[reason]" =>  nil }
      }.merge(opt_overrides)

      if user_already_flagged_comment?(comment, user)
        opts[:disabled] = 'disabled'
        content = t('flyover_comments.flags.flagged')
      end

      button_to content, flyover_comments.comment_flags_path(comment), opts
    end

    def flag_flyover_comment_modal
      render "flyover_comments/flags/modal"
    end

    def user_already_flagged_comment?(comment, user = send(FlyoverComments.current_user_method.to_sym))
      FlyoverComments::Flag.where(:comment => comment, FlyoverComments.user_class_symbol => user).exists?
    end

    def flag_flyover_comment_modal_link(comment, content = I18n.t('flyover_comments.comments.flag_link_text'), opt_overrides = {})
      user = send(FlyoverComments.current_user_method.to_sym)
      return unless comment && can_flag_flyover_comment?(comment, user)

      opts = {
        id: "flag_flyover_comment_#{comment.id}_modal_link",
        class: "flag-flyover-comment-modal-link"
      }.merge(opt_overrides)
      if user_already_flagged_comment?(comment)
        opts[:disabled] = 'disabled'
        content = t('flyover_comments.flags.flagged')
      else
        opts[:data] = {
          toggle: "modal",
          target: "#flyover-comment-flag-modal",
          url: flyover_comments.comment_flags_path(comment)
        }
      end

      link_to content, "#flyover-comment-#{comment.id}-flag-modal", opts
    end

    def mark_flyover_comment_flags_reviewed_link(comment, content = I18n.t('flyover_comments.comments.approve_link_text'), opt_overrides = {})

      opts = {
        id: "approve_flyover_comment_#{comment.id}",
        class: "approve-flyover-comment-button",
        data: {
          confirm: I18n.t('flyover_comments.comments.approve_confirmation'),
          flyover_comment_id: comment.id
        },
        params: {
          "comment[all_flags_reviewed]" => true
        },
        method: :patch,
        remote: true,
        form: { data: { type: "script" } }
      }.merge(opt_overrides)

      button_to content, flyover_comments.comment_path(comment), opts
    end
  end
end
