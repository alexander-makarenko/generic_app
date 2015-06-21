class NameChange
  include ActiveModel::Model

  attr_accessor :new_first_name, :new_last_name

  validates :new_first_name, presence: true, length: { maximum: 30 }
  validates :new_last_name,  presence: true, length: { maximum: 30 }
end