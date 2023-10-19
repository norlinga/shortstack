require 'redis'
require 'securerandom'

class Todo
  TODO_KEY_PREFIX = 'todos-app:todo:'.freeze
  INCOMPLETE_TODOS_KEY = 'todos-app:incomplete-todos'.freeze
  COMPLETE_TODOS_KEY = 'todos-app:complete-todos'.freeze

  class << self
    def create(name:)
      uuid = SecureRandom::uuid
      $redis.multi do
        $redis.hmset("#{TODO_KEY_PREFIX}#{uuid}", 'name', name, 'complete', 'false')
        $redis.sadd?(INCOMPLETE_TODOS_KEY, uuid)
      end
      uuid
    end

    def all
      todos = []
      $redis.sunion(INCOMPLETE_TODOS_KEY, COMPLETE_TODOS_KEY).each do |todo_id|
        todo = $redis.hgetall("#{TODO_KEY_PREFIX}#{todo_id}")
        todo['id'] = todo_id
        todos << todo
      end
      todos
    end

    def toggle(id:)
      todo_key = "#{TODO_KEY_PREFIX}#{id}"
      todo_status = $redis.hget(todo_key, 'complete')
      if todo_status == 'true'
        $redis.multi do
          $redis.hset(todo_key, 'complete', 'false')
          $redis.smove(COMPLETE_TODOS_KEY, INCOMPLETE_TODOS_KEY, id)
        end
      else
        $redis.multi do
          $redis.hset(todo_key, 'complete', 'true')
          $redis.smove(INCOMPLETE_TODOS_KEY, COMPLETE_TODOS_KEY, id)
        end
      end
    end

    def destroy_completed
      todo_ids = $redis.smembers(COMPLETE_TODOS_KEY)
      $redis.multi do
        todo_ids.each do |todo_id|
          $redis.del("#{TODO_KEY_PREFIX}#{todo_id}")
        end
        $redis.del(COMPLETE_TODOS_KEY)
      end
    end

    def counts
      {
        complete: $redis.scard(COMPLETE_TODOS_KEY),
        incomplete: $redis.scard(INCOMPLETE_TODOS_KEY)
      }
    end
  end
end
