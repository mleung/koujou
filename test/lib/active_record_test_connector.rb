# This let's us happily test AR. 
require 'active_record'
# Require all our models.
Dir.glob(File.join(File.dirname(__FILE__), "..", "lib", "models", "*.rb")).each { |f| require f }


class ActiveRecordTestConnector
  cattr_accessor :connected
  cattr_accessor :able_to_connect
  
  self.connected = false
  self.able_to_connect = true
  
  class << self
  
    def setup
      unless self.connected || !self.able_to_connect
        setup_connection
        load_schema
        self.connected = true
      end
    rescue Exception => e  # errors from ActiveRecord setup
      $stderr.puts "\nSkipping ActiveRecord tests: #{e}\n\n"
      self.able_to_connect = false
    end
  
    def setup_connection
      ActiveRecord::Base.establish_connection({
        :adapter => 'sqlite3',
        :dbfile => 'test.sqlite3'
      })
    end
    
    def load_schema
      ActiveRecord::Schema.define do
        create_table "users", :force => true do |t|
          t.string "name", "email", "first_name", "last_name", "hashed_password"
          t.integer "age"
          t.float "salary"
          t.datetime "hired_on"
          t.boolean "terms_of_service"
        end
        create_table "posts", :force => true do |t|
          t.string "name"
          t.text "body"
          t.integer "user_id"
        end
        create_table "comments", :force => true do |t|
          t.text "bod"
          t.integer "post_id"
        end
        create_table "profiles", :force => true do |t|
          t.integer "user_id"
          t.boolean "likes_cheese"
        end
        create_table "photos", :force => true do |t|
          t.integer "profile_id"
        end
        create_table "messages", :force => true do |t|
          t.string   "subject"
          t.text     "body"
          t.datetime "created_at"
          t.datetime "updated_at"
          t.integer  "sender_id"
          t.integer  "receiver_id"
          t.boolean  "read"
        end
        create_table "cars", :force => true do |t|
          t.integer "user_id"
          t.string "make", "model"
        end
        create_table "events", :force => true do |t|
          t.string "name"
        end
        create_table "registrants", :force => true do |t|
          t.integer "event_id"
          t.string "name"
        end
      end
    end
     
  end
end


