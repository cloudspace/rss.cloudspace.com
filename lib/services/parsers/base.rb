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

      # define either translations or transcriptions
      def self.attributes(*args)
        args = args.map { |a| a.respond_to?(:to_sym) ? a.to_sym : a.symbolize_keys }
        attr_splitter = lambda do |*array, **hash|
          transcribe_attributes(array)
          translate_attributes(hash)
        end
        attr_splitter.call(*args)
      end

      # define attributes to be included aliased in the output of the #attributes instance method
      def self.translate_attributes(translations = {})
        @attribute_translations ||= {}
        @attribute_translations.merge!(translations)
      end

      # define attributes to be included as is in the output of the #attributes instance method
      def self.transcribe_attributes(transcriptions)
        @attribute_transcriptions ||= []
        @attribute_transcriptions += [*transcriptions]
      end

      # delegate methods on the parser to some specified instance variable named as a symbol
      def self.delegate_methods(*method_names, to: nil)
        method_names.each do |m|
          recipient_symbol = "@#{to}".to_sym
          define_method(m) do |*args, &blk|
            recipient = instance_variable_get(recipient_symbol)
            @cached_delegates ||= {}
            @cached_delegates[m] ||= recipient.send(m, *args, &blk)
          end
        end
      end

      # produces a hash of attributes which can be used to create an object in rails
      def attributes
        @attributes ||= {}.tap do |attrs|
          self.class.instance_variable_get(:@attribute_translations).each_pair do |after, before|
            attrs[after] = send(before)
          end
          self.class.instance_variable_get(:@attribute_transcriptions).each do |var|
            attrs[var] = send(var)
          end
        end
      end

      # a simple alias method. was the parsing successful?
      def success?
        !!@success
      end

      # abstract method. will be called on subclass instance construction if defined
      def parse(*)
      end
    end
  end
end
