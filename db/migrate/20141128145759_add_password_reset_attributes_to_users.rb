class AddPasswordResetAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_digest, :string
    add_column :users, :password_reset_email_sent_at, :datetime
  end
end
