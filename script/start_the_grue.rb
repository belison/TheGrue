#!/usr/bin/env ruby
require File.expand_path('config/application')

require Rails.root.join('lib','game_manager')
require Rails.root.join('app','models','room')
gc = GameManager.new