```
<h1>Edit Demo</h1>

<% if demo %>
  <form action="/demos/<%= demo.id %>" method="post">
    <input type="hidden" name="_method" value="put"/>
    <div class="form-group">
      <input type="text" class="form-control" id="name" name="name"
    placeholder="Name"  value="<%= demo.name %>">
    </div>
    <button type="submit" class="btn btn-default">Submit</button>
  </form>
<% else %>
  <h1>Demo not found</h1>
<% end %>
<a href="/demos">back</a>
```
