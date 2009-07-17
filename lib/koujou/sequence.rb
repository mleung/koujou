module Koujou #:nodoc:
  class Sequence # :nodoc:
    include Singleton
    def initialize
      @current_value = 1
    end
    def next
      @current_value += 1
    end
  end
end