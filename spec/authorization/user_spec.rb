# frozen_string_literal: true

RSpec.describe Authorization::User do
  subject(:user) { described_class.new(**user_record) }

  let(:user_record) { { username: 'example-username', password: 'example-password', role: 'example-role' } }

  describe '#authenticated?(password:)' do
    subject(:authenticated?) { user.authenticated?(password: provided_password) }

    context 'blank password provided' do
      let(:provided_password) { '' }
      it { is_expected.to eql false }
    end

    context 'incorrect password provided' do
      let(:provided_password) { 'wrong-password' }
      it { is_expected.to eql false }
    end

    context 'correct password provided' do
      let(:provided_password) { 'example-password' }
      it { is_expected.to eql true }
    end
  end

  describe '#authenticated?(api_key:)' do
    subject(:authenticated?) { user.authenticated?(api_key: provided_api_key) }

    context 'blank api_key provided' do
      let(:provided_api_key) { '' }
      it { is_expected.to eql false }
    end

    context 'incorrect api_key provided' do
      let(:provided_api_key) { 'wrong-api-key' }
      it { is_expected.to eql false }
    end

    context 'correct api_key provided' do
      let(:provided_api_key) { 'example-api-key' }
      let(:user_record) do
        { username: 'example-username', password: 'example-password', role: 'example-role', api_key: 'example-api-key' }
      end
      it { is_expected.to eql true }
    end
  end

  describe '#authorized?' do
    subject(:authorized?) { user.authorized?(action) }

    let(:user_record) { { username: 'example-username', password: 'example-password', role: role } }

    context 'admin role' do
      let(:role) { :admin }

      context 'authorized action' do
        let(:action) { :yank }
        it { is_expected.to eql true }
      end

      context 'authorized action' do
        let(:action) { :upload }
        it { is_expected.to eql true }
      end

      context 'authorized action' do
        let(:action) { :default }
        it { is_expected.to eql true }
      end
    end

    context 'developer role' do
      let(:role) { :developer }

      context 'authorized action' do
        let(:action) { :yank }
        it { is_expected.to eql false }
      end

      context 'authorized action' do
        let(:action) { :upload }
        it { is_expected.to eql false }
      end

      context 'authorized action' do
        let(:action) { :default }
        it { is_expected.to eql true }
      end
    end
  end
end
