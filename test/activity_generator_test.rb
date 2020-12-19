require 'minitest/autorun'
require './src/activity_generator'

class ActivityGeneratorTest < Minitest::Test
  def setup
    @activity_generator = ActivityGenerator.new
  end

  def teardown
    if @activity_log_file_path != nil
      File.delete(@activity_log_file_path) if File.exist?(@activity_log_file_path)
    end
  end

  def test_execute_process
    @activity_log_file_path = @activity_generator.run('./test/config_execute.json')
    activity_log_file = File.open(@activity_log_file_path)
    activity_log = JSON.load(activity_log_file)[0]

    assert activity_log['process_id'].is_a? Integer
    assert activity_log['user'].is_a? String
    assert activity_log['start_time'].is_a? Integer
    assert activity_log['process_name'].is_a? String
    assert_equal 'ls -a', activity_log['process_command_line'] # This is sometimes nil... Need to figure out why.
  end

  # This could be 3 different tests, but grouping them together means it cleans up after itself.
  def test_execute_file_process
    @activity_log_file_path = @activity_generator.run('./test/config_execute_file.json')
    activity_log_file = File.open(@activity_log_file_path)
    activity_log = JSON.load(activity_log_file)
    activity_log_1 = activity_log[0]
    activity_log_2 = activity_log[1]
    activity_log_3 = activity_log[2]

    assert activity_log_1['process_id'].is_a? Integer
    assert activity_log_1['user'].is_a? String
    assert activity_log_1['start_time'].is_a? Integer
    assert activity_log_1['path_to_file'].is_a? String
    assert activity_log_1['process_name'].is_a? String
    assert_equal 'touch test_foo.txt', activity_log_1['process_command_line']
    assert_equal 'create_file', activity_log_1['activity_type']

    assert activity_log_2['process_id'].is_a? Integer
    assert activity_log_2['user'].is_a? String
    assert activity_log_2['start_time'].is_a? Integer
    assert activity_log_2['path_to_file'].is_a? String
    assert activity_log_2['process_name'].is_a? String
    assert_equal 'sh -c echo "hello world" >> test_foo.txt', activity_log_2['process_command_line']
    assert_equal 'modify_file', activity_log_2['activity_type']

    assert activity_log_3['process_id'].is_a? Integer
    assert activity_log_3['user'].is_a? String
    assert activity_log_3['start_time'].is_a? Integer
    assert activity_log_3['path_to_file'].is_a? String
    assert activity_log_3['process_name'].is_a? String
    assert_equal 'rm test_foo.txt', activity_log_3['process_command_line']
    assert_equal 'remove_file', activity_log_3['activity_type']
  end
end
