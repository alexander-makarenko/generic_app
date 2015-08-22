class AddUniqueConstraintToIndexOnUsersAuthDigest < ActiveRecord::Migration
  def change
    remove_index :users, :auth_digest
    add_index :users, :auth_digest, unique: true
  end
end