require 'json'
require 'sys/proctable'
include Sys

class ActivityGenerator

  USER = 'USER'
  TASK_TYPE_EXECUTE = 'execute'
  TASK_TYPE_CREATE_FILE = 'create_file'
  TASK_TYPE_MODIFY_FILE = 'modify_file'
  TASK_TYPE_REMOVE_FILE = 'remove_file'
  EXECUTE_CMDLINE = 'cmdline'
  PATH_TO_FILE = 'path_to_file'
  COMMAND_TOUCH = 'touch %{path_to_file}'
  COMMAND_ECHO = 'echo "hello world" >> %{path_to_file}'
  COMMAND_REMOVE = 'rm %{path_to_file}'

  def run(path_to_config)
    @output = []
    file = File.open(path_to_config)
    config = JSON.load(file)

    config['tasks'].each do |task|
      case task['type']
      when TASK_TYPE_EXECUTE
        execute_task(task[EXECUTE_CMDLINE])
      when TASK_TYPE_CREATE_FILE
        execute_file_task(TASK_TYPE_CREATE_FILE, COMMAND_TOUCH, task[PATH_TO_FILE])
      when TASK_TYPE_MODIFY_FILE
        execute_file_task(TASK_TYPE_MODIFY_FILE, COMMAND_ECHO, task[PATH_TO_FILE])
      when TASK_TYPE_REMOVE_FILE
        execute_file_task(TASK_TYPE_REMOVE_FILE, COMMAND_REMOVE, task[PATH_TO_FILE])
      else
        p "UNKNOWN TASK TYPE - #{task['type']}"
      end
    end

    filename = "./log/activity_log_#{Time.now.to_i}.json"
    File.open(filename, 'a') do |f|
      f << @output.to_json
    end

    p "Activity log created - #{filename}"
    filename
  end

  def execute_task(cmdline, context = {})
    pid = spawn(cmdline)
    # We don't care about the termination status, so we detach to avoid zombie processes.
    log_task(pid, context)
    Process.detach(pid)

  end

  def execute_file_task(type, command, path_to_file)
    cmdline = command % { path_to_file: path_to_file }
    context = {
      activity_type: type,
      path_to_file: File.expand_path(path_to_file)
    }
    execute_task(cmdline, context)
  end

  def log_task(pid, context = {})
    process = ProcTable.ps(pid: pid)

    @output << {
      process_id: pid,
      process_name: process.name,
      process_command_line: process.cmdline,
      user: ENV[USER],
      start_time: process.start_tvsec
    }.merge(context)
  end
end
