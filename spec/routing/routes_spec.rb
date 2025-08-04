require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'authentication routes' do
    it 'routes GET /signup to users#new' do
      expect(get: '/signup').to route_to('users#new')
    end

    it 'routes POST /signup to users#create' do
      expect(post: '/signup').to route_to('users#create')
    end

    it 'routes GET /login to sessions#new' do
      expect(get: '/login').to route_to('sessions#new')
    end

    it 'routes POST /login to sessions#create' do
      expect(post: '/login').to route_to('sessions#create')
    end

    it 'routes DELETE /logout to sessions#destroy' do
      expect(delete: '/logout').to route_to('sessions#destroy')
    end
  end

  describe 'user resource routes' do
    it 'routes GET /users/new to users#new' do
      expect(get: '/users/new').to route_to('users#new')
    end

    it 'routes POST /users to users#create' do
      expect(post: '/users').to route_to('users#create')
    end

    it 'routes GET /users/:id to users#show' do
      expect(get: '/users/1').to route_to('users#show', id: '1')
    end

    it 'does not route PUT /users/:id (update not allowed)' do
      expect(put: '/users/1').not_to be_routable
    end

    it 'does not route DELETE /users/:id (destroy not allowed)' do
      expect(delete: '/users/1').not_to be_routable
    end

    it 'does not route GET /users (index not allowed)' do
      expect(get: '/users').not_to be_routable
    end
  end

  describe 'health check route' do
    it 'routes GET /up to rails/health#show' do
      expect(get: '/up').to route_to('rails/health#show')
    end
  end
end
