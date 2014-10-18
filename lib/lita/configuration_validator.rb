module Lita
  # Validates a registry's configuration, checking for required attributes that are missing.
  # @since 4.0.0
  # @api private
  class ConfigurationValidator
    # @param registry [Lita::Registry] The registry to validate.
    def initialize(registry)
      @registry = registry
    end

    # Validates adapter and handler configuration.
    # @return [void]
    # @raise [Lita::ValidationError] If any required configuration attributes are missing.
    def call
      validate_adapters
      validate_handlers
    end

    private

    # The registry's adapters.
    def adapters
      @registry.adapters
    end

    # All a plugin's top-level configuration attributes.
    def children_for(plugin)
      plugin.configuration.children
    end

    # Generates the fully qualified name of a configuration attribute.
    def full_attribute_name(names, name)
      (names + [name]).join(".")
    end

    # The registry's handlers.
    def handlers
      @registry.handlers
    end

    # Validates the registry's adapters.
    def validate_adapters
      adapters.each_value { |adapter| validate(:adapter, adapter, children_for(adapter)) }
    end

    # Validates the registry's handlers.
    def validate_handlers
      handlers.each { |handler| validate(:handler, handler, children_for(handler)) }
    end

    # Validates an array of attributes, recursing if any nested attributes are encountered.
    def validate(type, plugin, attributes, attribute_namespace = [])
      attributes.each do |attribute|
        if attribute.children?
          validate(type, plugin, attribute.children, attribute_namespace.clone.push(attribute.name))
        elsif attribute.required? && attribute.value.nil?
          raise ValidationError, I18n.t(
            "lita.config.missing_required_#{type}_attribute",
            type => plugin.namespace,
            attribute: full_attribute_name(attribute_namespace, attribute.name)
          )
        end
      end
    end
  end
end