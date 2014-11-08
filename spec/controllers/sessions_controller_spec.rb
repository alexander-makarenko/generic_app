require 'rails_helper'

describe SessionsController, :type => :controller do
  describe "routing", type: :routing do
    specify { expect(get    '/signin').to   route_to('sessions#new') }
    specify { expect(post   '/sessions').to route_to('sessions#create') }
    specify { expect(delete '/signout').to  route_to('sessions#destroy') }
  end  
end
