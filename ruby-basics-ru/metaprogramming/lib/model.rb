# frozen_string_literal: true

# BEGIN
# lib/model.rb

module Model
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def attribute(name, options = {})
      @attributes ||= {}
      @attributes[name] = options[:type]

      # Создаем геттер
      define_method(name) do
        value = instance_variable_get("@#{name}")
        type = self.class.attributes[name]

        # Преобразуем тип значения, если задан тип
        if type && !value.nil?
          case type.to_s
          when 'String' then value.to_s
          when 'Integer' then value.to_i
          when 'Float' then value.to_f
          when 'Boolean' then !!value
          when 'DateTime' then DateTime.parse(value) rescue nil
          else value
          end
        else
          value
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
    attrs.each do |key, value|
      if self.class.attributes.key?(key)
        send("#{key}=", value)
      end
    end
  end

  def attributes
    self.class.attributes.keys.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end
  end
end
# END
