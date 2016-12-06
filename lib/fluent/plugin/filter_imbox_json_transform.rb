require 'json'

module Fluent
  class ImBoxJsonTransformerFilter < Filter
    # Register this filter as "passthru"
    Fluent::Plugin.register_filter('imbox_json_transform', self)

    config_param :key, :string, :default => 'log'
    config_param :remove, :bool, :default => true

    @@levels = {
      10 => 'trace',
      20 => 'debug',
      30 => 'info',
      40 => 'warn',
      50 => 'error',
      60 => 'fatal'
    }


    def configure(conf)
      super
    end

    def start
      super
      # This is the first method to be called when it starts running
      # Use it to allocate resources, etc.
    end

    def shutdown
      super
      # This method is called when Fluentd is shutting down.
      # Use it to free up resources, etc.
    end

    def filter(tag, time, record)
      # This method implements the filtering logic for individual filters
      # It is internal to this class and called by filter_stream unless
      # the user overrides filter_stream.
      #
      # If returns nil, that record is ignored.
      if record.has_key? @key
        begin
          child = JSON.parse(record[@key])

          child['@timestamp'] = child['time'] if child.key?('time')
          child['level'] = @@levels[child['level']] if child.key?('level') && child['level'].is_a? Numeric
          child['message'] = child['msg']

          child.delete('time')
          child.delete('msg')

          record.merge!(child)
          record.delete(@key) if @remove
        rescue JSON::ParserError => e
          record['message'] = record[@key]
          record.delete(@key) if @remove
        end
      end

      return record
    end
  end
end

