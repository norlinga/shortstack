# frozen_string_literal: true

require 'securerandom'

# = Todo
#
# The `Todo` class is a model interacting with Redis.
#
# == Class Methods
#
# - {.create(name:)}::
#   Creates a new todo item with the given `name`.
#
# - {.toggle(id:)}::
#   Toggles the completion status of the todo item by `id`.
#
# - {.all}::
#   Retrieves an array of hashes representing all todo items.
#
# - {.destroy_completed}::
#   Deletes all completed todo items.
#
# - {.counts}::
#   Returns hash of complete and incomplete todo items.
#
class Todo
  TODO_KEY_PREFIX = 'todos-app:todo:'
  INCOMPLETE_TODOS_KEY = 'todos-app:incomplete-todos'
  COMPLETE_TODOS_KEY = 'todos-app:complete-todos'

  class << self
    def create(name:)
      uuid = SecureRandom.uuid
      DB.multi do
        DB.hmset("#{TODO_KEY_PREFIX}#{uuid}", 'name', name, 'complete', 'false')
        DB.sadd?(INCOMPLETE_TODOS_KEY, uuid)
      end
      uuid
    end

    def all
      todos = []
      DB.sunion(INCOMPLETE_TODOS_KEY, COMPLETE_TODOS_KEY).each do |todo_id|
        todo = DB.hgetall("#{TODO_KEY_PREFIX}#{todo_id}")
        todo['id'] = todo_id
        todos << todo
      end
      todos
    end

    # rubocop:disable Metrics/MethodLength
    def toggle(id:)
      todo_key = "#{TODO_KEY_PREFIX}#{id}"
      if DB.hget(todo_key, 'complete') == 'true'
        DB.multi do
          DB.hset(todo_key, 'complete', 'false')
          DB.smove(COMPLETE_TODOS_KEY, INCOMPLETE_TODOS_KEY, id)
        end
      else
        DB.multi do
          DB.hset(todo_key, 'complete', 'true')
          DB.smove(INCOMPLETE_TODOS_KEY, COMPLETE_TODOS_KEY, id)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def destroy_completed
      todo_ids = DB.smembers(COMPLETE_TODOS_KEY)
      DB.multi do
        todo_ids.each do |todo_id|
          DB.del("#{TODO_KEY_PREFIX}#{todo_id}")
        end
        DB.del(COMPLETE_TODOS_KEY)
      end
    end

    def counts
      {
        complete: DB.scard(COMPLETE_TODOS_KEY),
        incomplete: DB.scard(INCOMPLETE_TODOS_KEY)
      }
    end
  end
end
