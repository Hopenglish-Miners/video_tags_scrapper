require 'rake/testtask'

Rake::TestTask.new :spec do |t|
  t.test_files = Dir['spec/*_spec.rb']
  t.warning = false
end

task :default => :spec
