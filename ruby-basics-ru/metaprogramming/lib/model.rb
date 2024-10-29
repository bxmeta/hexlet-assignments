# frozen_string_literal: true

# BEGIN
require 'date'

module Model
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def attribute(name, options = {})
      @attributes ||= {}
      @attributes[name] = options

      # Создаем геттер
      define_method(name) do
        if instance_variable_defined?("@#{name}")
          instance_variable_get("@#{name}")
        else
          default = options[:default]
          default.is_a?(Proc) ? default.call : default
        end
      end

      # Создаем сеттер
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end

    def attributes
      @attributes || {}
    end
  end

  def initialize(attrs = {})
    self.class.attributes.each do |name, options|
      # Устанавливаем значение из хеша или дефолтное значение, если оно указано
      value = attrs.key?(name) ? attrs[name] : options[:default]
      send("#{name}=", convert_type(value, options[:type])) unless value.nil?
    end
  end

  def attributes
    self.class.attributes.each_with_object({}) do |(name, options), hash|
      hash[name] = send(name)
    end
  end

  private

  def convert_type(value, type)
    return nil if value.nil? || type.nil?

    case type.to_s
    when 'String' then value.to_s
    when 'Integer' then value.to_i
    when 'Float' then value.to_f
    when 'Boolean' then !!value
    when 'DateTime' then DateTime.parse(value) rescue nil
    else value
    end
  end
end
# END
