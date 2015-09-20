class AddEmailChangeAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :old_email, :string
    add_column :users, :old_email_confirmed, :boolean, default: false
    add_column :users, :old_email_confirmed_at, :datetime
  end
end