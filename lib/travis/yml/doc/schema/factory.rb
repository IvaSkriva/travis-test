# frozen_string_literal: true
module Travis
  module Yml
    module Doc
      module Schema
        module Factory
          include Helper::Obj
          extend self

          def build(schema)
            if schema.is_a?(Array)
              schema.map { |schema| build(schema) }
            elsif !schema.is_a?(Hash)
              raise "unexpected type #{schema.inspect}"
            elsif schema[:'$schema']
              schema_(schema)
            elsif schema[:'$ref']
              ref(schema)
            elsif secure?(schema)
              secure(schema)
            elsif schema[:allOf]
              all(schema)
            elsif schema[:anyOf]
              any(schema)
            elsif schema[:oneOf]
              one(schema)
            elsif schema[:type] == :boolean
              bool(schema)
            elsif schema[:type] == :number
              num(schema)
            elsif schema[:type] == :string && schema.key?(:enum)
              enum(schema)
            elsif schema[:type] == :string
              str(schema)
            elsif schema[:type] == :object
              map(schema)
            elsif schema[:type] == :array
              seq(schema)
            else
              raise "unexpected type #{schema.inspect}"
            end
          end

          private

            def secure?(schema) # ugh.
              return true if schema[:anyOf] == Yml.schema[:definitions][:type][:secure][:anyOf]
              return true if schema[:type] == :object && schema[:properties] && schema[:properties].key?(:secure)
              false
            end

            def schema_(schema)
              build(except(schema, :'$schema', :title, :definitions))
            end

            def all(schema)
              build(join(:allOf, schema))
            end

            def one(schema)
              build(join(:oneOf, schema))
            end

            def join(type, schema)
              objs = schema[type].map do |obj|
                obj = resolve(obj)
                key = %i(oneOf allOf).detect { |key| obj.key?(key) }
                key ? join(key, obj) : obj
              end

              obj = merge(*objs)
              schema = except(schema, type)
              schema = merge(schema, obj)
              schema = schema.merge(strict: true)
              schema
            end

            def any(schema)
              return build(join(:anyOf, schema)) if schema[:$id] == :languages
              node = Any.new(normalize(schema))
              node.schemas = build(schema[:anyOf])
              node
            end

            def seq(schema)
              node = Seq.new(normalize(schema))
              node.schema = build(schema[:items]) if schema[:items]
              node
            end

            def map(schema)
              node = Map.new({ keys: {} }.merge(normalize(schema)))
              node.map = mappings(schema)
              if patterns = schema[:patternProperties]
                raise if patterns.size > 1
                node.opts[:format] = patterns.keys.first.to_s
                node.schema = build(patterns.values.first)
              end
              node
            end

            def mappings(schema)
              map = schema[:properties] ? schema[:properties] : {}
              map.map { |key, schema| [key, build(schema)] }.to_h
            end

            def secure(schema)
              Secure.new(normalize(schema).merge(strict: !schema.key?(:anyOf))) # ??
            end

            def enum(schema) # ugh.
              schema = normalize(schema)
              values = merge(*schema[:enum].map { |value| { value.to_sym => {} } })
              values = values.merge(schema[:values] || {})
              values = values.map { |key, value| { value: key.to_s }.merge(value) }
              Enum.new(except(schema, :enum).merge(values: values))
            end

            def str(schema)
              Str.new(normalize(schema))
            end

            def bool(schema)
              Bool.new(normalize(schema))
            end

            def num(schema)
              Num.new(normalize(schema))
            end

            def ref(schema)
              definition(schema[:'$ref'])
            end

            def definition(ref)
              definitions[ref] ||= build(lookup(ref))
            end

            def lookup(ref)
              defs = Yml.schema[:definitions]
              keys = ref.to_s.sub('#/definitions/', '').split('/').map(&:to_sym)
              defn = keys.inject(defs) { |defs, key| defs[key] || unknown(ref) }
              defn || unknown(ref)
            end

            def resolve(schema)
              schema.key?(:'$ref') ? lookup(schema[:'$ref']) : schema
            end

            def unknown(ref)
              raise("unknown definition #{ref}")
            end

            def definitions
              @definitions ||= {}
            end

            DROP = %i(
              additionalProperties
              allOf
              anyOf
              definitions
              description
              examples
              expand
              items
              maxProperties
              minItems
              oneOf
              patternProperties
              properties
              title
            )

            REMAP = {
              '$id':         :id,
              '$schema':     :uri,
              pattern:       :format,
              maxProperties: :max_size
            }

            def normalize(schema)
              schema = remap(schema)
              schema = schema.merge(id: schema[:id].to_sym) if schema[:id]
              schema = schema.merge(strict: strict?(schema)) if schema[:type] == :object
              schema = schema.merge(aliases: aliases(schema)) if schema[:aliases]
              except(schema, *DROP)
            end

            def strict?(schema)
              return schema[:strict] if schema.key?(:strict)
              return false if schema.key?(:patternProperties)
              false?(schema[:additionalProperties])
            end

            def aliases(schema)
              aliases = schema[:aliases]
              return aliases unless aliases.values.first.is_a?(Array)
              aliases.map { |key, names| names.map { |name| [name, key] } }.flatten(1).to_h
            end

            def remap(hash)
              hash.map { |key, value| [REMAP[key] || key, value] }.to_h
            end

            def except(hash, *keys)
              hash.reject { |key, _| keys.include?(key) }
            end

            # MERGE = -> (_, lft, rgt) do
            #   if lft.is_a?(::Hash) && rgt.is_a?(::Hash)
            #     lft.merge(rgt, &MERGE)
            #   elsif lft.is_a?(::Array) && rgt.is_a?(::Array)
            #     lft.dup.concat(rgt).uniq
            #   else
            #     rgt
            #   end
            # end
            #
            # def merge(*objs)
            #   Array(objs).flatten.inject { |lft, rgt| lft.merge(rgt, &MERGE) } || {}
            # end
        end
      end
    end
  end
end

