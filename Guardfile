# frozen_string_literal: true

guard :minitest, spring: false, all_on_start: true do
  watch(%r{^test/(.*)/.*_test\.rb$})
  watch(%r{^models/(.*)\.rb$}) { |m| "test/unit/#{m[1]}_test.rb" }
  watch(/^app.rb$/) { 'test' }
end
