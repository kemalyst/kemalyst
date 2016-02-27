# WIP (Work In Progress)

# Kemalyst

Kemalyst is a Rails like framework that is based on on super fast
[kemal](https://github.com/sdogruyol/kemal). The framework is based on
Handlers which are similar to Rack middleware.  The model is a simple ORM
mapping and supports MySQL, PG and SQLite. 

## Installation

1. Install Crystal

You can find instructions on how to install Crystal from [Crystal's
Website](http://crystal-lang.org).  I recommend using
[crenv](https://github.com/pine613/crenv) to manage your crystal versions.
Currently 0.11.0 is supported.

2. Create a Crystal App

```
crystal init app demo
cd demo
```
3. Add kemalyst dependency to your shard.yml
```
dependencies:
  kemalyst:
    github: drujensen/kemalyst
    branch: master

  # optional database
  mysql:
    github: waterlink/crystal-mysql
    branch: master  
```
and run `crystal deps`.  

To keep a similar structure to rails, 
rename the `src` directory to `app`.  Also create a `db`, `public`,
`logs` and `config` directory.

## Usage

1. Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` file and routes.cr here.

-- TO DO --

2. Create Controller

3. Create View

4. Create Model

5. Create Service

## Contributing

1. Fork it ( https://github.com/[your-github-name]/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[drujensen]](https://github.com/drujensen) drujensen - creator, maintainer
