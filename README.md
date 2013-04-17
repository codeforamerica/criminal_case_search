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
RACK_ENV=development
export RACK_ENV
bundle exec rackup
```

Alternatively, use Guard:
```bash
bundle exec guard
```

### Loading NYPD arrest reports
```bash
thor data:load_from_xml /path-to-encrypted-data
```
