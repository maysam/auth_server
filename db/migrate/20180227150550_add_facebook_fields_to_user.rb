class AddFacebookFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :facebook_id, :string
    add_index :users, :facebook_id
    add_column :users, :facebook_token, :string
    add_index :users, :facebook_token
  end
end
