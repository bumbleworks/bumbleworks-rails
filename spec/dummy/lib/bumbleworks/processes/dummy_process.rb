Bumbleworks.define_process do
  concurrence do
    beaver :task => 'make_a_dam'
    cop :task => 'chew_on_quandary'
    cop :task => 'try_on_scarf'
  end
end
