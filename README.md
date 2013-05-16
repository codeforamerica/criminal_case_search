## Datashare Filter

Prototype app for filtering NYC Arrest/Arraignment data based on
flexible criteria.

## Setup

### Building pre-requisites
```bash
brew install mongodb
bundle #install required gems
```

### Deploying the web server
```bash
bundle exec rackup
```

Alternatively, use Guard for auto-restart during development:
```bash
bundle exec guard
```

## Development

### Loading example Datashare data from XML files
(must end with .xml extensions)
```bash
thor data:load_arrest_reports /path-to-encrypted-data/NYPD
thor data:load_rap_sheets /path-to-encrypted-data/DCJS
```

### Debugging
You can also use `pry` from the application root directory for an interactive
console.
