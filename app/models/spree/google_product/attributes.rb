module Spree
  class GoogleProduct
    class Attributes
      class Define
        def initialize(a)
          @attributes = a
        end

        GoogleProduct::G_ATTRIBUTES.each do |attribute|
          define_method attribute do |value = nil, &block|
            raise "Cannot pass value and block to define" if value && block
            return @attributes.register_attribute(attribute, value) if value
            return @attributes.register_attribute(attribute, &block) if block

            Class.new do
              def initialize(a, name)
                @attributes = a
                @name = name
              end

              def as_db_column(field = nil, &block)
                @attributes.registered_attributes.delete(@name)
                @attributes.register_db_field(@name, field, &block)
              end
            end.new(@attributes, attribute)
          end
        end
      end

      DbField = Struct.new(:name, :db_name, :render_block)

      def self.instance
        @instance ||= new
      end

      def self.configure(&block)
        yield instance
      end

      attr_accessor :ignore_db_mismatch

      def define
        Define.new(self)
      end

      def registered_attributes
        @registered_attributes ||= {}
      end

      # Assigns field to variant using registered attributes/db_fields
      # TODO WTF?
      def assign(variant, field)
        set_to = variant.method("#{field}=")

        if attribute = db_fields[field]
          set_to.(variant.google_product.send(field))

        elsif attribute = registered_attributes[field]
          if attribute.respond_to?(:call)
            set_to.(attribute.call(variant))
          else
            set_to.(attribute)
          end
        end
      end

      def value_of(variant, field, context = nil)
        if attribute = db_fields[field]
          variant.google_product.send(attribute.name)

        elsif attribute = registered_attributes[field]
          if attribute.respond_to?(:call)
            attribute.call(variant, context)
          else
            attribute
          end
        end
      end

      def db_field_names
        db_fields.values.map(&:db_name)
      end

      def render_db_field(context, form_builder, field)
        db_field = db_fields.values.find { |f| f.db_name == field.to_sym }
        block    = db_field.render_block || default_db_field_block

        context.instance_exec(form_builder, field, &block)
      end

      attr_writer :default_db_field_block

      def default_db_field_block
        @default_db_field_block || proc do |f, field_name|
          f.text_field(field_name)
        end
      end

      def db_fields
        @db_fields ||= {}
      end

      def register_attribute(name, value = nil, &block)
        unless G_ATTRIBUTES.include?(name)
          raise "#{name} is not a valid google shopping attribute."
        end
        db_fields.delete(name)
        registered_attributes[name] = block_given? ? block : value
      end

      def register_db_field(name, field = nil, &block)
        db_fields[name] = DbField.new(name, field || name,
                                      block || default_db_field_block)
      end
    end
  end
end
