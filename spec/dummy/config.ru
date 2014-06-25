# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Initialize our fake database
FAKE_DATABASE = {}

# Bootstrap Bumbleworks (loads process definitions & registers paricipants)
Bumbleworks.bootstrap!

# Start an in-memory worker (Hash storage)
Bumbleworks.start_worker!

# Launch four processes, two for each entity type
Bumbleworks.launch!('dummy_process', :entity => Fridget.new(1))
Bumbleworks.launch!('dummy_process', :entity => Fridget.new(2))

Bumbleworks.launch!('dummy_process', :entity => SilvoBloom.new(1))
Bumbleworks.launch!('dummy_process', :entity => SilvoBloom.new(2))

run Rails.application
