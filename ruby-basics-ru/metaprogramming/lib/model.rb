# frozen_string_literal: true

# BEGIN
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
        value = instance_variable_get("@#{name}")

        # Если значение не задано, используем дефолтное значение из опций
        if value.nil? && options.key?(:default)
          options[:default].is_a?(Proc) ? options[:default].call : options[:default]
        else
          type = self.class.attributes[name][:type]
          # Преобразуем тип значения, если тип задан
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
    self.class.attributes.each do |key, options|
      # Устанавливаем значение из attrs или дефолтное значение, если оно есть
      value = attrs.key?(key) ? attrs[key] : (options.key?(:default) ? options[:default] : nil)
      send("#{key}=", value)
    end
  end

  def attributes
    self.class.attributes.keys.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end
  end
end
# END
