require 'forwardable'

class Setting < ActiveRecord::Base

  class << self
    extend Forwardable
    def_delegators :instance, :method_missing

    def instance
      @instance ||= new
    end

    [:backoff_min, :backoff_max].map do |m|
      define_method m do
        instance.send(:fetch_value, m.to_s)
      end
    end
  end

  private

  def fetch_value(setting)
    cache.fetch(setting, :expires_in => 300) do
      Setting.find_by!(name: setting).read_attribute(:value)
    end
  end

  def cache
    Rails.cache
  end
end
