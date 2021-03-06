# imbox-fluentd-transformer
Transforms JSON-logs to a normalized format before inserting into elasticsearch

Expects this fields:
* name - name of service
* level - log level using int or string, ints will be converted to string using this table:
  - 10 => 'trace'
  - 20 => 'debug'
  - 30 => 'info'
  - 40 => 'warn'
  - 50 => 'error'
  - 60 => 'fatal'
* message or msg

If log is not JSON the data will be inserted into message field which is fine but then information about service name will be missing. To be able to distinguish services use of docker labels is supported. Labels will be merged into base structure. Example configuration in AWS ECS Task Definition:
```json
"logConfiguration": {
  "logDriver": "json-file",
  "options": {
    "labels": "name"
  }
},
"dockerLabels": {
  "name": "name of service"
}
```

# Setup
Requires ruby and bundler.

To install dependencies:
```bash
$ bundle install --path=vendor/gems
```

Run tests:
```bash
$ bundle exec rake test
```
