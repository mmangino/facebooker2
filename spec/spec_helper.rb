require "rubygems"
require "active_support"
require "action_pack"
require "action_view"
require "action_controller"
require 'action_controller/test_process'
require 'action_controller/integration'
require 'active_support/test_case'
require 'spec/test/unit'


require "facebooker2"
gem "rspec-rails"

#required because view tests need a controller
class ApplicationController < ActionController::Base
end

#load just the files needed for helper tests so that we don't need a full rails stack
require "spec/rails/example/functional_example_group"
require "spec/rails/example/helper_example_group"
require 'spec/rails/interop/testcase'

Spec::Example::ExampleGroupFactory.default(ActiveSupport::TestCase)


