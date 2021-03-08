require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    # Student .create_table creates the students table in the database
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    # Student .drop_table drops the students table from the database
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    # Student #save saves an instance of the Student class to the database and then sets the given students `id` attribute
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      # Student #save updates a record if called on an object that is already persisted
      self.update
    end
  end

  def self.create(name, grade)
    # Student .create creates a student with two attributes, name and grade, and saves it into the students table.
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(db_row)
    # Student .new_from_db creates an instance with corresponding attribute values
    # db_row = [id, name, grade]
    Student.new(db_row[0], db_row[1], db_row[2])
  end

  def self.find_by_name(name)
    # Student .find_by_name returns an instance of student that matches the name from the DB
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    return Student.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    # Student #update updates the record associated with a given instance
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE ID = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
