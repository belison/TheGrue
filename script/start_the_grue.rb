#!/usr/bin/env ruby
require File.expand_path('config/application')

Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}
require Rails.root.join('app','models','room')
gc = GameManager.new
gc.begin_input_loop