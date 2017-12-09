require_relative "../config/environment.rb"

class Dog

attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
end

def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
  SQL

  DB[:conn].execute(sql)
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

def self.new_from_db(row)
  #binding.pry
  id = row[0]
  name = row[1]
  breed = row[2]
  Dog.new(id,name,breed)
end

def save
  if self.id
       self.update
     else
       sql = <<-SQL
         INSERT INTO dogs (name, breed)
         VALUES (?, ?)
       SQL

       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     self
end

def self.create(name:, breed:)
  dog = Dog.new(id, name, breed)
  dog.save
  dog
end


def update
  sql = <<-SQL
  UPDATE dogs
     SET name = ?, breed = ?
     WHERE id = ?
  SQL
  DB[:conn].execute(sql,self.name,self.breed)
end

def self.find_by_id(id)

     sql = <<-SQL
     SELECT * from dogs
     WHERE id = ?
     SQL

     DB[:conn].execute(sql,name).map do |row|
       #binding.pry
       self.new_from_db(row)
     end.first
   end

end #ends Dog Class
