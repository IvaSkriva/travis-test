require 'forwardable'
require 'travis/yml/helper/obj'
require 'travis/yml/configs/errors'
require 'travis/yml/configs/ref'
require 'travis/yml/parts'

module Travis
  module Yml
    module Configs
      module Config
        def self.travis_yml(ctx, parent, slug, ref, mode)
          Config::File.new(ctx, parent, source: "#{slug}:.travis.yml@#{ref}", mode: mode)
        end

        module Base
          extend Forwardable
          include Helper::Obj, Errors, Memoize

          def_delegators :ctx, :data, :opts
          def_delegators :repo, :allow_config_imports?, :owner_name, :private?, :public?

          attr_reader :on_loaded

          def repo
            @repo ||= ctx.repos[slug]
          end

          def config
            @config ||= {}
          end

          def part
            Parts::Part.new(raw, source, mode) # TODO can Config and Part be joined?
          end

          def load(&block)
            @on_loaded = block if root?
          end

          def loaded
            @loaded = true
            return root.loaded unless root?
            return unless loaded?
            on_loaded.call
          end

          def imports
            imports = Array(config[:import])
            imports = imports.select { |import| import.is_a?(Hash) }
            imports.map { |import| Config::File.new(ctx, self, import) }
          end
          memoize :imports

          # Flattening the tree should result in a unique array of configs
          # ordered by the order resulting in walking the tree depth-first.
          # However, we load the tree breadth-first and load times vary.
          # Configs with the same source are only loaded once. So, nodes that
          # are supposed to be kept in a higher order position may not have
          # been loaded.
          #
          # For example:
          #
          #   - a
          #     - a.1
          #       - x
          #   - b
          #     - x
          #
          # We load a and b in parallel. a then loads a.1, which then tries to
          # load x. However, in the meantime b will have loaded x already, so
          # a.1 will end up with an x that has not been loaded.
          #
          # Therefor we swap nodes that have not been loaded but need to be
          # kept with nodes that have been loaded but needed to be uniq'ed
          # away.
          def flatten
            return [] if circular? || !matches?
            sort([self].compact + imports.map(&:flatten).flatten).uniq(&:to_s)
          end

          def sort(configs)
            configs.dup.each.with_index do |lft, i|
              next if lft.imports.any?
              rgt = configs.detect { |rgt| lft.to_s == rgt.to_s && rgt.imports.any? }
              configs[i] = configs.delete(rgt)
            end
          end

          def circular?
            parents.map(&:to_s).include?(to_s)
          end

          def matches?
            return true if Condition.new(import, data).accept?
            msg :info, :import, :skip_import, source: to_s, condition: import[:if]
            false
          end
          memoize :matches?

          def validate
            return if root?
            invalid_ownership(repo) if invalid_ownership?
            invalid_visibility(repo) if invalid_visibility?
            not_allowed(repo) if not_allowed?
          end

          def root
            root? ? self : parent.root
          end

          def root?
            parent.nil?
          end

          def parents
            root? ? [] : parent.parents + [parent]
          end

          def local?
            !parent || parent.repo == repo
          end

          def remote?
            !local?
          end

          def reencrypt?
            same_owner?(root) && remote? && secure?(config)
          end

          def same_owner?(other)
            repo.owner_name == other.owner_name
          end

          def empty?
            raw.nil? || raw.empty?
          end

          def skip
            @skip = true
          end

          def skip?
            !!@skip
          end

          def loaded?
            skip? || !!@loaded && imports.all?(&:loaded?)
          end

          def mode
            super&.to_sym
          end

          def to_h
            {
              source: to_s,
              config: raw,
              mode: mode
            }
          end

          private

            def store
              ctx.fetch.store(self)
            end

            def msg(*msg)
              msgs << msg
            end

            def msgs
              ctx.fetch.msgs
            end

            def invalid_ownership?
              parent.private? && private? && parent.owner_name != owner_name
            end

            def invalid_visibility?
              parent.public? && private?
            end

            def not_allowed?
              remote? && private? && !allow_config_imports?
            end

            def secure?(obj)
              case obj
              when Hash
                obj.key?(:secure) || obj.any? { |_, obj| secure?(obj) }
              when Array
                obj.any? { |obj| secure?(obj) }
              else
                false
              end
            end

            def parse(str)
              Yml.load(str, defaults: false).serialize
            end
        end
      end
    end
  end
end
