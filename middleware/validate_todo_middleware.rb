class ValidateTodoMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    if request.path =~ /validate\_todo/
      todo_name = request.params['todo-name']
      
      if todo_name && todo_name.length > 3 && todo_name.length <= 40
        @app.call(env)
      else
        response = Rack::Response.new("Invalid Todo name. It must be between 4 and 40 characters in length.", 200)
        response.finish
      end
    else
      @app.call(env)
    end
  end
end