require_relative '../test_helper'
require_relative '../../models/todo'

class TodoTest < Minitest::Test
  def test_create_todo
    todo_id = Todo.create(name: 'Get Milk')
    todos = Todo.all
    assert_equal [{ 'name' => 'Get Milk', 'complete' => 'false', 'id' => todo_id }], todos
  end

  def test_toggle_todo
    todo_id = Todo.create(name: 'Get Milk')
    Todo.toggle(id: todo_id)
    todos = Todo.all
    assert_equal [{ 'name' => 'Get Milk', 'complete' => 'true', 'id' => todo_id }], todos
  end

  def test_destroy_completed_todos
    first_todo_id = Todo.create(name: 'Walk the dog')
    second_todo_id = Todo.create(name: 'Clean the house')
    Todo.toggle(id: first_todo_id)
    Todo.destroy_completed
    todos = Todo.all
    assert_equal [{ 'name' => 'Clean the house', 'complete' => 'false', 'id' => second_todo_id }], todos
  end

  def test_counts
    todo_id = Todo.create(name: 'Read a book')
    _todo_id = Todo.create(name: 'Lift heavy :P')
    Todo.toggle(id: todo_id)
    counts = Todo.counts
    assert_equal({ complete: 1, incomplete: 1 }, counts)
  end
end
