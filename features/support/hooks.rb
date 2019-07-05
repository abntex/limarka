# https://cucumber.io/docs/cucumber/api/


Before do
  FileUtils.rm_rf File.join('tmp', 'cucumber')
  @inicio = Dir.pwd
end
After do
  Dir.chdir(@inicio)
end
