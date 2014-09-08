# a simple mixin to provide ActiveModel::Serializers-style attribute definition on any class
module Service::Attributable
  def self.included(base)
    base.extend(ClassMethods)
  end

  # produces a hash of attributes which can be used to create an object in rails
  def attributes
    unless @attributes
      @attributes = {}.tap do |attrs|
        self.class.instance_variable_get(:@attribute_translations).each_pair do |after, before|
          attrs[after] = send(before)
        end
        self.class.instance_variable_get(:@attribute_transcriptions).each do |var|
          attrs[var] = send(var)
        end
      end
    end
    @attributes.reject { |k, v| v.nil? }
  end

  # class methods mixed in upon inclusion
  module ClassMethods
    # define either transcriptions or translations.
    def attributes(*transcriptions, **translations)
      @attribute_transcriptions = [] unless @attribute_transcriptions
      @attribute_translations = {} unless @attribute_translations
      @attribute_transcriptions += [*transcriptions.map(&:to_sym)]
      @attribute_translations.merge!(translations.symbolize_keys)
    end
  end
end
