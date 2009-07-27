#--
# Copyright (c) 2006-2008, Michael Schuerig, michael@schuerig.de
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++


require 'active_record/reflection'
require 'ostruct'

# Based on code by Sebastian Kanthak
# See http://dev.rubyonrails.org/ticket/861
module Koujou # :nodoc:
  module ActiveRecordExtensions # :nodoc:
    module ValidationReflection # :nodoc:
      
      mattr_accessor :reflected_validations
      Koujou::ActiveRecordExtensions::ValidationReflection.reflected_validations = %w(
         validates_acceptance_of
         validates_associated
         validates_confirmation_of
         validates_exclusion_of
         validates_format_of
         validates_inclusion_of
         validates_length_of
         validates_size_of
         validates_numericality_of
         validates_presence_of
         validates_uniqueness_of
         validate
      )

      mattr_accessor :in_ignored_subvalidation
      Koujou::ActiveRecordExtensions::ValidationReflection.in_ignored_subvalidation = false
      
      def self.included(base)
        return if base.kind_of?(Koujou::ActiveRecordExtensions::ValidationReflection::ClassMethods)
        base.extend(ClassMethods)
      end

      def self.install(base)
        reflected_validations.freeze
        reflected_validations.each do |validation_type|
          next if base.respond_to?("#{validation_type}_with_reflection")
          ignore_subvalidations = false
          base.class_eval <<-"end_eval"
            class << self
              def #{validation_type}_with_reflection(*attr_names)
                ignoring_subvalidations(#{ignore_subvalidations}) do
                  #{validation_type}_without_reflection(*attr_names)
                  remember_validation_metadata(:#{validation_type}, *attr_names)
                end
              end

              alias_method_chain :#{validation_type}, :reflection
            end
          end_eval
        end
      end

      module ClassMethods

        # Returns an array of MacroReflection objects for all validations in the class
        def reflect_on_all_validations
          read_inheritable_attribute(:validations) || []
        end

        # Returns an array of MacroReflection objects for all validations defined for the field +attr_name+.
        def reflect_on_validations_for(attr_name)
          attr_name = attr_name.to_sym
          reflect_on_all_validations.select do |reflection|
            reflection.name == attr_name
          end
        end
        
        # A few convenience methods added in by Mike. Why not loop and define_method these?
        
        def unique_validations
          reflect_on_all_validations.select{|v| v.macro == :validates_uniqueness_of }
        end

        def required_validations
          reflect_on_all_validations.select{|v| v.macro == :validates_presence_of }
        end

        def confirmation_validations
          reflect_on_all_validations.select{|v| v.macro == :validates_confirmation_of }
        end
        
        def length_validations
          reflect_on_all_validations.select{|v| v.macro == :validates_length_of || v.macro == :validates_size_of }
        end
        
        def inclusion_validations
          reflect_on_all_validations.select{|v| v.macro == :validates_inclusion_of }
        end

        def custom_validations
          # We don't want to get anything like: validate_associated_records_for_posts.
          reflect_on_all_validations.select{|v| v.macro == :validate && v.name.to_s.match("_associated_").nil? }
        end
        
        private
        
        def remember_validation_metadata(validation_type, *attr_names)
          configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
          attr_names.each do |attr_name|
            write_inheritable_array :validations,
              [ ActiveRecord::Reflection::MacroReflection.new(validation_type, attr_name.to_sym, configuration, self) ]
          end
        end
        
        def ignoring_subvalidations(ignore)
          save_ignore = Koujou::ActiveRecordExtensions::ValidationReflection.in_ignored_subvalidation
          unless Koujou::ActiveRecordExtensions::ValidationReflection.in_ignored_subvalidation
            Koujou::ActiveRecordExtensions::ValidationReflection.in_ignored_subvalidation = ignore
            yield
          end
        ensure
          Koujou::ActiveRecordExtensions::ValidationReflection.in_ignored_subvalidation = save_ignore
        end
      end

    end
  end
end
