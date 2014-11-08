require 'rails_helper'

describe StaticPagesController, :type => :controller do
  describe "routing", type: :routing do
    specify { expect(get '/').to   route_to('static_pages#home') }
  end
end