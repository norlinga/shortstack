require 'sinatra'
require 'sinatra/reloader' if development?

require_relative './models/todo'
require_relative './middleware/validate_todo_middleware'

use Rack::MethodOverride
use ValidateTodoMiddleware

$redis = Redis.new

get '/' do
  @todo_counts = Todo.counts
  @todos = Todo.all
  erb :index
end

post '/todo' do
  Todo.create(name: params['todo-name'])
  redirect '/'
end

put '/todo' do
  Todo.toggle(id: params['id'])
  redirect '/'
end

delete '/todo' do
  Todo.destroy_completed
  redirect '/'
end

post '/validate_todo' do
  # maybe some uniqueness validations run here...
  # in the mean time, update #errors to show we got here
  rand(1000).to_s
end