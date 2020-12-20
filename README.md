## About

This project is used to generate endpoint activity for the purpose of testing EDR agents. It is capable of:

* Process creation
* File creation, modification and deletion
* Transmitting data over a network connection

A log file is generated each time the program is run. This file is in json format and contains information about the generated activity.

## Setup

In addition to ruby, you will need to install a couple of dependencies.

* [sys-proctable](https://github.com/djberg96/sys-proctable) is used to easily find information about a running process.

* [minitest](https://github.com/seattlerb/minitest) is used for very lightweight testing.

First you will need [bundler](https://bundler.io/). I recommend installing with homebrew:

```
brew install bundler
```
From there you can:
```
bundle install
```

After bundling you can make sure that everything is setup correctly by running the tests. From the root of the project:

```
ruby test/activity_generator_test.rb
```

## Running the project

The `config.json` file contains a sort of "playbook" that describes the activity to be generated. There are 5 types of activity:

* `execute`
* `create_file`
* `modify_file`
* `remove_file`
* `network_activity`

After setting up the desired tasks in the config, you can run the program with:
```
ruby index.rb
```

#### execute

This task type requires an additional option: `cmdline`. This can contain a path to an executable and any optional command line arguments.

The program will spin up a new process to execute the command and will write the desired information to the log file:

```json
{"process_id":21946,"process_name":"ls","process_command_line":"ls -a","user":"joeystansfield","start_time":1608427595}
```

#### create_file, modify_file, remove_file

These tasks require the `path_to_file` option. Like `execute`, they will spin up new processes to perform the task and write to the log file.

```json
{"process_id":22142,"process_name":"touch","process_command_line":"touch foo.txt","user":"joeystansfield","start_time":1608428229,"activity_type":"create_file","path_to_file":"/Users/joeystansfield/activity_generator/foo.txt"},{"process_id":22143,"process_name":"touch","process_command_line":"touch bar.txt","user":"joeystansfield","start_time":1608428229,"activity_type":"create_file","path_to_file":"/Users/joeystansfield/activity_generator/bar.txt"},{"process_id":22144,"process_name":"sh","process_command_line":"sh -c echo \"hello world\" >> foo.txt","user":"joeystansfield","start_time":1608428229,"activity_type":"modify_file","path_to_file":"/Users/joeystansfield/activity_generator/foo.txt"},{"process_id":22145,"process_name":"ruby","process_command_line":"rm bar.txt","user":"joeystansfield","start_time":1608428229,"activity_type":"remove_file","path_to_file":"/Users/joeystansfield/activity_generator/bar.txt"}
```

#### network_activity

Unlike the other tasks, the `network_activity` runs in the same process as the main program. This task sets up a `TCPSocket` connection and sends a short message to google.com.

The log entry looks like this:
```json
{"process_id":22335,"process_name":"ruby","process_command_line":"ruby index.rb","user":"joeystansfield","start_time":1608429663,"activity_type":"network_connection","source_address":"192.168.0.12","source_port":61918,"destination_address":"172.217.2.14","destination_port":80,"bytes_sent":14,"protocol":"TCP/IP"}
```
