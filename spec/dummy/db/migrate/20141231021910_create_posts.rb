class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :ident_user, index: true
      t.string :title

      t.timestamps null: false
    end
    add_foreign_key :posts, :ident_user
  end
end
