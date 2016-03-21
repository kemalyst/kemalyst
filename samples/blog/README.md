# blog

This is a sample application that shows how to build a crud application.  This
also provides an example of securing specific pages and leveraging the session
to maintain authorization.

## Installation

Create a mysql database called `blog` and configure the `config/database.yml`
to provide the credentials to access the table.
Then:
```
shards update
crystal db/migrate.cr
```

## Usage

To run the sample blog:
```
crystal build src/app.cr
./app
```
username: admin
password: password

## Contributing

1. Fork it ( https://github.com/[your-github-name]/kemalyst-blog/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[drujensen]](https://github.com/[drujensen]) dru.jensen - creator, maintainer
