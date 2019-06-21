require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(name:, breed:, id: nil)
    self.name = name
    self.breed = breed
    @id = id
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog[0].empty?
      self.find_by_id(dog[0][0])
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).collect{|row| self.new(id: row[0], name: row[1], breed: row[2]) }.first
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap{ |dog| dog.save}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end
end
