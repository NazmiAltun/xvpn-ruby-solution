require 'rails_helper'

RSpec.describe 'Health check', type: :request do
  it 'works' do
    get '/healthcheck'
    expect(response).to have_http_status(:success)
  end
end
