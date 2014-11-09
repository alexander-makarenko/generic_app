require 'rails_helper'

describe UsersController, type: :controller do
  describe "routing", type: :routing do
    specify { expect(get    '/users').to_not be_routable }
    specify { expect(post   '/users').to route_to('users#create') }
    specify { expect(get    '/users/new').to_not be_routable }
    specify { expect(get    '/signup').to route_to('users#new') }
    specify { expect(get    '/users/42/edit').to_not be_routable }
    specify { expect(get    '/users/42/settings').to route_to('users#edit', id: '42') }
    specify { expect(get    '/users/42').to_not be_routable }
    specify { expect(put    '/users/42').to route_to('users#update', id: '42') }
    specify { expect(patch  '/users/42').to route_to('users#update', id: '42') }
    specify { expect(delete '/users/42').to_not be_routable }
  end

  # describe "GET index" do
  #   it "returns http success" do
  #     get :index
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end