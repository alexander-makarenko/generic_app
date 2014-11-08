class RenameAuthTokenColumnAndIndexInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :auth_token, :auth_digest
  end
end