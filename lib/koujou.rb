$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'active_record'
require 'faker'
require 'koujou/sequence'
require 'koujou/builder'
require 'koujou/data_generator'
require 'koujou/validation_reflection'
require 'koujou/custom_validation'

module Koujou
  VERSION = '0.1.1'
end

if ENV["RAILS_ENV"] == "test"
  ActiveRecord::Base.class_eval do
    include Koujou::ActiveRecordExtensions::ValidationReflection
    Koujou::ActiveRecordExtensions::ValidationReflection.install(self)
    include Koujou::ActiveRecordExtensions::Builder
  end
end
