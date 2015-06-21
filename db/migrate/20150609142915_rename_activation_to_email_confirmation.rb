class RenameActivationToEmailConfirmation < ActiveRecord::Migration
  def change    
    rename_column :users, :activation_digest, :email_confirmation_digest
    rename_column :users, :activated, :email_confirmed
    rename_column :users, :activated_at, :email_confirmed_at
    rename_column :users, :activation_sent_at, :email_confirmation_sent_at
  end
end
