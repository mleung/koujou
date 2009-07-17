$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'active_record'
require 'faker'
require 'kojo/sequence'
require 'kojo/builder'
require 'kojo/data_generator'
require 'kojo/validation_reflection'

module Kojo
  VERSION = '0.0.1'
end

ActiveRecord::Base.class_eval do
  include Kojo::ActiveRecordExtensions::ValidationReflection
  Kojo::ActiveRecordExtensions::ValidationReflection.install(self)
  include Kojo::ActiveRecordExtensions::Builder
end

