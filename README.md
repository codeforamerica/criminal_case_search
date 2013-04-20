## Datashare Filter

Prototype app for filtering NYC Arrest/Arraignment data based on
flexible criteria.

## Usage

### Setup

```bash
brew install mongodb
bundle #install required gems
```

### Starting the web server
```bash
bundle exec rackup
```

Alternatively, use Guard for auto-restart during development:
```bash
bundle exec guard
```

### Development

### Loading NYPD arrest reports
```bash
thor data:load_from_xml /path-to-encrypted-data
```

You can use `pry` from the application root directory for an interactive
console.
