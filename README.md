An accept header parser and API. Contains nothing Scorched specific, it's only named such because every other obvious
name has been used by the other libraries already in existence, none of which actually parse the accept header
correctly, or implement proper prioritisation of media ranges.

Example
-------
```ruby
accept_header = AcceptHeader.new('text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
accept_header.best_of('application/json', 'video/mp4')
```

Refer to specs and API documentation for more information.

Tests
-----
```bash
mtest spec
```
