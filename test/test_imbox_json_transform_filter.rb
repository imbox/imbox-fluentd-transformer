require 'fluent/test'
require 'fluent/plugin/filter_imbox_json_transform'

Fluent::Test.setup

class JsonMergeTest < Test::Unit::TestCase
  setup do
    @tag = 'docker.container'
  end

  def create_driver(conf, use_v1_config = true)
    Fluent::Test::OutputTestDriver.new(Fluent::ImBoxJsonTransformerFilter, @tag).configure(conf, use_v1_config)
  end

  sub_test_case 'configure' do
    test 'check_default' do
      d = create_driver('')

      assert_equal 'log', d.instance.key
      assert_true d.instance.remove
    end

    test 'override_key' do
      d = create_driver(%[key not_log])

      assert_equal 'not_log', d.instance.key
      assert_true d.instance.remove
    end

    test 'override_remove' do
      d = create_driver(%[remove false])

      assert_equal 'log', d.instance.key
      assert_false d.instance.remove
    end

    test 'override_both' do
      d = create_driver(%[
                        key random
                        remove false
      ])

      assert_equal 'random', d.instance.key
      assert_false d.instance.remove
    end
  end

  sub_test_case 'filter' do

    test 'happy path' do
      record = { 'key' => 'value',
        'log' => '
        {"name":"agents-mobile-server",
          "hostname":"42e311aa6eb7",
          "pid":14,
          "level":30,
          "msg":"Rabbitmq connection opened",
          "time":"2016-12-06T08:52:31.954Z",
          "v":0}
        '}
      expected = {
        "key" => "value",
        "name" => "agents-mobile-server",
        "hostname" => "42e311aa6eb7",
        "pid" => 14,
        "level" => "info",
        "v" => 0,
        "@timestamp" => "2016-12-06T08:52:31.954Z",
        "message" => "Rabbitmq connection opened"
      }

      d = create_driver('')
      result = d.instance.filter('tag', 'time', record)

      assert_equal expected, result
    end

    test 'merge attrs' do
      record = {
        'key' => 'value',
        'attrs' => {
          'name' => 'this is my name'
        },
        'log' => '
        {"name":"agents-mobile-server",
          "hostname":"42e311aa6eb7",
          "pid":14,
          "level":30,
          "msg":"Rabbitmq connection opened",
          "time":"2016-12-06T08:52:31.954Z",
          "v":0}
        '
      }
      expected = {
        "key" => "value",
        "name" => "this is my name",
        "hostname" => "42e311aa6eb7",
        "pid" => 14,
        "level" => "info",
        "v" => 0,
        "@timestamp" => "2016-12-06T08:52:31.954Z",
        "message" => "Rabbitmq connection opened"
      }

      d = create_driver('')
      result = d.instance.filter('tag', 'time', record)

      assert_equal expected, result
    end

    test 'missing keys' do
      record = { 
        'key' => 'value',
        'log' => '
          {"name":"agents-mobile-server",
            "hostname":"42e311aa6eb7",
            "pid":14,
            "msg":"Rabbitmq connection opened",
            "v":0}
        '}
      expected = {
        'key' => 'value',
        'name' => 'agents-mobile-server',
        'hostname' => '42e311aa6eb7',
        'pid' => 14,
        'message' => 'Rabbitmq connection opened',
        'v' => 0
      }

      d = create_driver('')
      result = d.instance.filter('tag', 'time', record)

      assert_equal expected, result
    end

    test 'non JSON should be passed along' do
      record = {
        'key' => 'value',
        'log' => 'NonJSON'
      }
      expected = {
        'key' => 'value',
        'message' => 'NonJSON'
      }

      d = create_driver('')
      result = d.instance.filter('tag', 'time', record)

      assert_equal expected, result
    end

    test 'stderr should set level to error' do
      record = { 'key' => 'value',
        'stream' => 'stderr',
        'log' => 'This is a line',
        'attrs' => {
          'name' => 'this is my name'
        }
      }
      expected = {
        "key" => "value",
        "level" => "error",
        "message" => 'This is a line',
        "stream" => "stderr",
        "name" => "this is my name"
      }

      d = create_driver('')
      result = d.instance.filter('tag', 'time', record)

      assert_equal expected, result
    end
  end
end
