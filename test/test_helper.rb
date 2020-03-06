# Add simplecov
require 'simplecov'
SimpleCov.start do
  add_filter 'test/' # Tests should not be checked for coverage.
end

require 'Date'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/pride'
require 'minitest/skip_dsl'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# require_relative your lib files here!

require_relative "../lib/hotel_controller.rb"
require_relative "../lib/date_range.rb"
require_relative "../lib/reservation.rb"
require_relative "../lib/room.rb"
require_relative "../lib/block.rb"

include Hotel