require "flyover_comments/commentable"
require "flyover_comments/authorization"

module FlyoverComments
  class Engine < ::Rails::Engine
    isolate_namespace FlyoverComments

    config.generators do |g|
      g.test_framework :rspec
    end
    
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer "flyover_comments.active_record" do
      ActiveSupport.on_load(:active_record) do
        extend FlyoverComments::Commentable
      end
    end

    initializer 'flyover_comments.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper FlyoverComments::CommentsHelper
        helper FlyoverComments::Authorization
      end
    end

  end
end
