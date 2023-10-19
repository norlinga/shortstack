guard :minitest, spring: false, all_on_start: true do
  watch(%r{^test/(.*)/.*_test\.rb$})
  watch(%r{^models/(.*)\.rb$})     { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app.rb$})              { 'test' }
end