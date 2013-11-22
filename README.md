# Criminal Case Search

This is a prototype app for filtering NYC Arrest/Arraignment data based on
a flexible set of criteria.

## App Setup

This application relies on Ruby version 2.0.0-p0, Bundler and MongoDB. Systems vary widely and we'll defer
to setup instructions for your platform.

### Configure Your Environment

Application configuration happens largely through the use of a few different environment variables. We provide
a `sample.env` file that you can fill out with your own settings.
```bash
cp sample.env .env
$EDITOR .env
```

### Install Gems

We use bundler to track application dependencies, the usual command will get everything set up.
```bash
bundle
```

### Load Data

If you have a set of sample data that you are able to use you can load it in with the following command.
```bash
foreman run bundle exec thor data:load /Your/Path/Here
```

For people without the data set you can generate a sample set that fills things out enough for users to
see how the application works.
```bash
foreman run bundle exec thor data:generate_samples 500
```

## Run the Web Server

The simplest way is to use Rack's built in server.
```bash
foreman run bundle exec rackup
```

Alternatively, you can use Guard for auto-restart during development. The server gets restarted every time a file changes:
```bash
bundle exec guard
```

### Debugging
You can also use `pry` from the application root directory for an interactive console.
