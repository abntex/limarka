# https://cucumber.io/docs/cucumber/api/


Before do
  @inicio = Dir.pwd
end
After do
  Dir.chdir(@inicio)
end
