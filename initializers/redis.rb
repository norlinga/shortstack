# frozen_string_literal: true

require 'redis'

DB = if test?
       Redis.new(url: 'redis://localhost:6379/1')
     else
       Redis.new
     end
