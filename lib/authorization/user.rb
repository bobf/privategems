# frozen_string_literal: true

module Authorization
  # A user of Geminabox GemCutter API/frent end.
  class User
    attr_accessor :api_key

    def initialize(username:, password:, role:, api_key: nil)
      @username = username
      @password = password
      @role = role.to_sym
      @api_key = api_key
    end

    def authorized?(action)
      { developer: %i[default], admin: %i[upload yank default] }.fetch(@role).include?(action)
    end

    def authenticated?(password: nil, api_key: nil)
      authenticated_password?(password) || authenticated_api_key?(api_key)
    end

    private

    def authenticated_api_key?(api_key)
      return false if api_key.nil?
      return false if api_key.empty?
      return false if @api_key.nil?

      SecureCompare.compare(@api_key, api_key)
    end

    def authenticated_password?(password)
      return false if password.nil?
      return false if password.empty?
      return false if @password.nil?

      SecureCompare.compare(@password, password)
    end
  end
end
