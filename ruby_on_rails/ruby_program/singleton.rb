require 'singleton'

class Configuration
    include(Singleton)
end

class Database
    include(Singleton)
end

p Configuration.instance
p Database.instance