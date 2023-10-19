# Short Stack

Sinatra + HTMX + Ruby + Redis + Tailwind == Short Stack.  :P

This is a playground for experimenting with HTMX.
The structure of the playground is a simple todo app.
I know.

![App Screenshot](public/app.png "Todo App Interface")

## HTMX is fun

Making HTML active through tag attributes is a super cool approach.
Adding a Turbo-like capability to the application is as simple as:

```html
<body hx-boost='true'>
```

This will turn all GET- and POST-firing tags into AJAX requests which rewrite the document body only.
The responsibility of the backend service / app is to send back HTML payloads instead of JSON.

Consider this code:

```html
<input type="text" name="todo-name" placeholder="Enter New Todo Name"
  hx-trigger="keyup delay:500ms"
  hx-post="/validate_todo"
  hx-swap="innerHTML"
  hx-target="#errors"
  ... />
```

This breaks the 'boosting' described above and fires off a POST request to `/validate_todo`.
The form elements are the payload to the backend, and whatever's returned replaces the `innerHTML` of the element with the id '#errors'.
This all takes place on `keyup` in the `<input>` element, with a debounce.
The behavior of the wrapping form is unchanged when simply pressing enter on the keyboard or pressing the submit button in the form.

## Exploration

Working out design patterns from example code is hard, hence this playground.
I was interested to explore how middleware could be introduced into input validation, for example.
If the page is simply expecting a textual response (could be a string to insert into innerHTML), the response could be super terse and could come from anywhere in the stack.
Including request-interrupting middleware.
There's a middleware active that demonstrates basic validation on a request before sending the request on to the app.
Not sure that's useful as shown, but it was a fun thought experiment.

Doing targeted page updates with view partials was an interesting exercise.
The `swap-oob` feature is useful, as is polling.
Left as a true "single page app", `index.erb` handles the whole thing in the current form.

## Performance

Using Redis on the backend is cheating.
Responsiveness from the app is pretty astonishing as is, giving a very responsive feel:

```
[11/Oct/2023:11:50:47 -0700] "PUT /todo HTTP/1.1" 303 - 0.0010
[11/Oct/2023:11:50:47 -0700] "GET / HTTP/1.1" 200 4176 0.0019
```

Single-digit millisecond responses are fast enough.
That said, a Roda version was substantially faster.
Switching to JIT or Truffleruby didn't do anything really impactful to performance on this trivial app.