# frozen_string_literal: true

require 'authorization/request'

module Authorization
  # Authenticates user and authorizes requested actions according to user role type.
  class Request
    attr_reader :users

    def initialize(users:, username:, password:, api_key:)
      @users = users
      @username = username
      @password = password
      @api_key = api_key
    end

    def create_api_key
      user.api_key ||= SecureRandom.alphanumeric(32)
      user_record['api_key'] = @user.api_key
    end

    def authorized?(action)
      return false if user.nil?
      return false unless user.authenticated?(password: @password, api_key: @api_key)

      user.authorized?(action)
    end

    def user
      return nil if user_record.nil?

      @user ||= User.new(**user_record.transform_keys(&:to_sym))
    end

    private

    def user_record
      find_by_username || find_by_api_key
    end

    def find_by_username
      @users.find { |user| user['username'] == @username }
    end

    def find_by_api_key
      return nil if @api_key.nil?

      @users.reject { |user| user['api_key'].nil? }
            .find { |user| user['api_key'] == @api_key }
    end
  end
end
