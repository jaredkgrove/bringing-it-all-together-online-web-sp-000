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
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).collect{|row| self.new(id: row[0], name: row[1], breed: row[2]) }.first
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
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
