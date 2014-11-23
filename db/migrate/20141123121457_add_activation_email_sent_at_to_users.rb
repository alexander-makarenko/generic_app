class AddActivationEmailSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activation_email_sent_at, :datetime
  end
end
