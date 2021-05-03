module Notebooks
    
end

class Notebooks::Binding
    def initialize (bookname)
      p bookname
    end
end

p ::Notebooks::Binding.new("effective ruby")