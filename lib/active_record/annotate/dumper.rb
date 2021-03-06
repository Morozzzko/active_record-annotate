module ActiveRecord
  module Annotate
    module Dumper
      class << self
        def dump(table_name, connection = ActiveRecord::Base.connection, config = ActiveRecord::Base)
          string_io = StringIO.new

          if connection.table_exists?(table_name) ||
            connection.respond_to?(:view_exists?) && connection.view_exists?(table_name)
            dumper(connection, config).send(:table, table_name, string_io)
          else
            string_io.write("  # can't find table `#{table_name}`")
          end
          
          process_annotation(string_io)
        end
        
      private
        def dumper(connection, config)
          if connection.respond_to?(:create_schema_dumper)
            connection.create_schema_dumper(ActiveRecord::SchemaDumper.send(:generate_options, config))
          else
            ActiveRecord::SchemaDumper.send(:new, connection)
          end
        end
        
        def process_annotation(string_io)
          string_io.string.split(?\n).map do |line|
            line.tap do |line|
              # commenting out the line
              line[0] = '#'
              # replacing strings with symbols
              line.gsub!(/"(\w+)"/, ':\1')
            end
          end
        end
      end
    end
  end
end
