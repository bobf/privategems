# frozen_string_literal: true

RSpec.describe Authorization::Request do
  subject(:request) { described_class.new(users: users, **credentials) }

  let(:credentials) { { username: username, password: password, api_key: api_key } }
  let(:username) { 'example-username' }
  let(:password) { 'example-password' }
  let(:api_key) { nil }
  let(:users) { fixture('users.yml').yml(false)['users'] }

  describe '#create_api_key' do
    subject(:create_api_key) { request.create_api_key }

    let(:username) { 'alex' }
    let(:password) { 'alexiscool' }

    it 'updates user api key' do
      expect { create_api_key }.to(change { request.user.api_key })
    end

    it 'updates user data' do
      expect { create_api_key }.to(change { users })
    end

    it 'does not overwrite existing key' do
      request.create_api_key
      expect { request.create_api_key }.to_not(change { request.user.api_key })
    end
  end

  describe '#authorized?' do
    subject(:authorized?) { request.authorized?(action) }

    context 'invalid credentials' do
      let(:username) { 'alex' }
      let(:password) { 'alexisnotcool' }

      context 'upload action' do
        let(:action) { :upload }

        it { is_expected.to eql false }
      end

      context 'default action' do
        let(:action) { :default }

        it { is_expected.to eql false }
      end
    end

    context 'valid credentials' do
      let(:username) { 'alex' }
      let(:password) { 'alexiscool' }

      context 'default action' do
        let(:action) { :default }

        it { is_expected.to eql true }
      end
    end

    context 'valid api key' do
      let(:username) { nil }
      let(:password) { nil }
      let(:api_key) { 'jenkins-api-key' }
      let(:action) { :upload }

      it { is_expected.to eql true }
    end

    context 'admin user' do
      let(:username) { 'chris' }
      let(:password) { 'alexsucks' }

      context 'default action' do
        let(:action) { :default }

        it { is_expected.to eql true }
      end

      context 'upload action' do
        let(:action) { :default }

        it { is_expected.to eql true }
      end
    end
  end
end
