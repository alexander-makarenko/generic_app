class RenameSentAtAttributesInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :activation_email_sent_at,     :activation_sent_at
    rename_column :users, :password_reset_email_sent_at, :password_reset_sent_at
  end
end
