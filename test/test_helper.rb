# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!

require_relative '../app'

module Minitest
  class Test
    def setup
      DB.flushdb
    end

    def teardown
      DB.flushdb
    end
  end
end

Dir[File.expand_path('models/*.rb', __dir__)].each { |file| require file }
