# frozen_string_literal: true

$LOAD_PATH << File.join(File.expand_path('..', __dir__), 'lib')

require 'bundler/setup'
require 'authorization'

require 'devpack'
require 'rspec/file_fixtures'

ENV['GEMINABOX_USERS'] = File.join(__dir__, 'fixtures', 'users.yml')

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
