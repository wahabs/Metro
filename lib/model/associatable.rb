require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    "#{class_name.to_s.underscore}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @options = options
  end

  def foreign_key
    @options[:foreign_key] || "#{@name}_id".to_sym
  end

  def primary_key
    @options[:primary_key] || :id
  end

  def class_name
    @options[:class_name] || "#{@name}".camelcase
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @self_class_name = self_class_name
    @options = options
  end

  def foreign_key
    @options[:foreign_key] || "#{@self_class_name.underscore}_id".to_sym
  end

  def primary_key
    @options[:primary_key] || :id
  end

  def class_name
    @options[:class_name] || "#{@name}".singularize.camelcase
  end

end

module Associatable

  def assoc_options
    @assoc_options ||= {}
  end

  # e.g. Human where(:id => 3) where 3 is the owner_id given by the cat
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      options.model_class.where(
        options.primary_key => self.send(options.foreign_key)
      ).first
    end
    @assoc_options = { name => options }
  end

  # e.g. Cats where(:owner_id => 3) where 3 is the id given by the human
  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      options.model_class.where(
      options.foreign_key => self.send(options.primary_key)
      )
    end
    @assoc_options = { name => options }
  end

  # e.g. Cat - has_one_through :home, :human, :house
   def has_one_through(name, through_name, source_name)

     define_method(name) do
       through_options = self.class.assoc_options[through_name]
       source_options = through_options.model_class.assoc_options[source_name]

       source_table = source_options.table_name
       through_table = through_options.table_name
       source_foreign_key = source_options.foreign_key
       source_primary_key = source_options.primary_key
       through_foreign_key = through_options.foreign_key
       through_primary_key = through_options.primary_key

       query = <<-SQL
         SELECT
           #{source_table}.*
         FROM
           #{through_table}
         JOIN
           #{source_table}
         ON
           #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
         WHERE
           #{through_table}.#{through_primary_key} = ?
       SQL

       column = DBConnection.execute(query, self.send(through_foreign_key))
       source_options.model_class.parse_all(column).first
     end

   end

end
