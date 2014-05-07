# mixin allowing delegation of one or more methods to the method or ivar specified, and caches result
module Service::Delegator
  def self.included(base)
    base.extend(ClassMethods)
  end

  # class methods mixed in upon inclusion
  module ClassMethods
    # delegate one or more methods on self to some specified ivar/method named as a symbol
    # and memoize the result for future calls to the same method
    def cache_delegate(*method_names, to: nil)
      fail ArgumentError, 'You must specify \'to\'' unless to

      method_names.each do |method_name|
        define_method(method_name) do |*args, &blk|
          recipient = instance_eval(to.to_s)

          if recipient
            @cached_delegates ||= {}

            @cached_delegates[method_name] = self.class.fetch_cache_or_execute @cached_delegates,
                                                                               method_name,
                                                                               recipient,
                                                                               *args,
                                                                               &blk
          else
            nil
          end
        end
      end
    end

    # Executes the given method on the recipient and caches it on the delegates object
    # If the method has been previously executed, return the cached value
    def fetch_cache_or_execute(cached_delegates, method_name, recipient, *args, &blk)
      if cached_delegates.key?(method_name)
        cached_delegates[method_name]
      else
        recipient.send(method_name, *args, &blk)
      end
    end

    # delegate one or more methods on self to some specified ivar/method named as a symbol
    def delegate(*method_names, to: nil)
      fail ArgumentError, 'You must specify \'to\'' unless to

      method_names.each do |method_name|
        define_method(method_name) do |*args, &blk|
          recipient = instance_eval(to.to_s)
          if recipient
            recipient.send(method_name, *args, &blk)
          else
            nil
          end
        end
      end
    end

    # delegate one or more methods on self as arguments to the specified method
    # http://en.wikipedia.org/wiki/Currying
    def spicy_delegate(*method_names, through: nil)
      method_names.each do |method_name|
        define_method(method_name) do |*args, &blk|
          send(through, method_name)
        end
      end
    end
  end
end
