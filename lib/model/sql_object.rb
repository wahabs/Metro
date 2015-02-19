require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject

  extend Searchable
  extend Associatable

  def self.columns
    col_info = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    col_info[0].map { |col_name| col_name.to_sym }
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) { attributes[column] }
      define_method(column.to_s + "=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    self.parse_all (
      DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
    )
  end

  def self.parse_all(results)
    all_objects = []
    results.each do |hash|
      all_objects << self.new(hash)
    end
    all_objects
  end

  def self.find(id)
    column = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    self.parse_all(column).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=",value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |value| send(value) }
  end

  def insert
    col_names = "(#{self.class.columns.join(", ")})"
    question_marks = "(#{(["?"] * attribute_values.length).join(", ")})"
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{"#{self.class.table_name} #{col_names}"}
      VALUES
        #{question_marks}
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |attr_name| "#{attr_name} = ?"}.join(",")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    (self.id.nil?) ? insert : update
  end
end
