require 'hashie'

# a generic options class to hold onto settings
class Service::Options < Hashie::Mash
  def set(options)
    deep_merge!(options)
    delete_blank!
  end

  def set!(options)
    replace(options)
    delete_blank!
  end

  def delete_blank
    dup.delete_blank!
  end

  def delete_blank!
    deep_reject! { |k, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
  end

  def deep_reject(&blk)
    dup.deep_reject!(&blk)
  end

  def deep_reject!(&blk)
    each do |k, v|
      v.deep_reject!(&blk)  if v.is_a?(Hash)
      delete(k) if blk.call(k, v)
    end
  end
end
