class NameChangesController < ApplicationController
  before_action { authorize :name_change }

  def new
    @name_change = NameChange.new
  end

  def create
    @name_change = NameChange.new(params[:name_change])
    
    if @name_change.valid?
      current_user.attributes = {
        first_name: @name_change.new_first_name,
        last_name: @name_change.new_last_name
      }
      current_user.save(validate: false)
      redirect_to account_path, success: t('c.name_changes.create.success')
    else
      render :new
    end
  end
end
