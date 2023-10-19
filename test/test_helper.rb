ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!

require_relative '../app'

class Minitest::Test
  def setup
    # Initialize test $redis to use a different Redis database
    $redis = Redis.new(url: 'redis://localhost:6379/1')
    
    $redis.flushdb
  end

  def teardown
    $redis.flushdb
  end
end

Dir[File.expand_path('../models/*.rb', __FILE__)].each { |file| require file }
