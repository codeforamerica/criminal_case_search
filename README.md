# Criminal Case Search

This is a prototype app for filtering NYC Arrest/Arraignment data based on
a flexible set of criteria.

## Setup

This application relies on Ruby version 2.0.0-p0, Bundler and MongoDB. Systems vary widely and we'll defer
to setup instructions for your platform.

### Install Gems
```bash
bundle
```

### Seed Demo Data
```bash
foreman run bundle exec thor data
```

### Deploying the web server
```bash
foreman run bundle exec guard
```

Alternatively, use Guard for auto-restart during development:
```bash
bundle exec guard
```

## Development

### Loading example Datashare data from XML files
(must end with .xml extensions)
```bash
thor data:load_arrest_reports /Volumes/Datashare/NYPD
thor data:load_rap_sheets /Volumes/Datashare/DCJS
thor data:load_complaints /Volumes/Datashare/DANY
thor data:load_complaints /Volumes/Datashare/KCDA
thor data:load_ror_reports /Volumes/Datashare/CJA
```

### Debugging
You can also use `pry` from the application root directory for an interactive
console.
