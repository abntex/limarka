require './spec/spec_helper'
require 'cucumber/rspec/doubles'


@@HOME = Dir.pwd

FileUtils.rm_rf File.join(@@HOME, 'tmp', 'cucumber')
