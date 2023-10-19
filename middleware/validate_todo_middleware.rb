# frozen_string_literal: true

# ValidateTodoMiddleware demostrates how a middleware can be used to interrupt a request
# and send back a HTMX-friendly payload.  Note that even though the Rack::Response is
# indicating a validation error, we have to give a 200 response code so that HTMX doesn't
# swallow the error.  hx-boost, given 4xx or 5xx responses, halts and render action.
class ValidateTodoMiddleware
  def initialize(app)
    @app = app
  end

  # rubocop:disable Metrics/MethodLength
  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /validate_todo/
      todo_name = request.params['todo-name']

      if todo_name && todo_name.length > 3 && todo_name.length <= 40
        @app.call(env)
      else
        response = Rack::Response.new('Invalid Todo name. It must be between 4 and 40 characters in length.', 200)
        response.finish
      end
    else
      @app.call(env)
    end
  end
  # rubocop:enable Metrics/MethodLength
end
