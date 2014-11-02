require 'rails_helper'

describe UsersController, type: :controller do
  describe "routing", type: :routing do
    specify { expect(get    '/users').to_not be_routable }
    specify { expect(post   '/users').to route_to('users#create') }
    specify { expect(get    '/users/new').to_not be_routable }
    specify { expect(get    '/signup').to route_to('users#new') }
    specify { expect(get    '/users/:id/edit').to_not be_routable }
    specify { expect(get    '/users/:id').to_not be_routable }
    specify { expect(put    '/users/:id').to_not be_routable }
    specify { expect(patch  '/users/:id').to_not be_routable }
    specify { expect(delete '/users/:id').to_not be_routable }
  end

  # describe "GET index" do
  #   it "returns http success" do
  #     get :index
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end