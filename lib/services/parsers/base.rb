module Service
  module Parser
    # the parser base class. do not directly instantiate, only for subclassing
    class Base
      # essentially a constructor that also calls parse before returning self
      def self.parse(*args, &blk)
        obj = allocate
        obj.send(:initialize, *args, &blk)
        obj.parse
        obj
      end

      # a simple alias method. was the parsing successful?
      def success?
        !!@success
      end

      # abstract method. must be implemented in the subclass
      def parse(*)
        fail NotImplementedError
      end

      private

      # abstract method. must be implemented in the subclass
      def transcribed_fields(*)
        fail NotImplementedError
      end

      # copies the results of calling each method on each transcribed field into instance vars
      def transcribe_attrs
        transcribed_fields.each do |m|
          instance_variable_set("@#{m}".to_sym, @parser.send(m))
        end
      end
    end
  end
end
