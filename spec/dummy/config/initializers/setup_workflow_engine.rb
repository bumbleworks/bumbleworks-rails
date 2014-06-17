Bumbleworks.configure do |c|
  c.storage = {}
  c.store_history = false
end

Bumbleworks.bootstrap!
Bumbleworks.initialize!
Bumbleworks.start_worker!

Bumbleworks.launch!('dummy_process')