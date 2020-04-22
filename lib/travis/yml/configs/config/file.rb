require 'travis/yml/configs/github/content'
require 'travis/yml/configs/config/base'

module Travis
  module Yml
    module Configs
      module Config
        class File < Obj.new(:ctx, :parent, :import)
          include Base

          attr_reader :path, :ref, :raw

          def initialize(ctx, parent, import)
            import = stringify(import)
            super
          end

          def load(&block)
            super
            _, @path, @ref = expand(source)
            return unless validate
            @raw = fetch
            @config = parse(raw)
            store
          rescue ApiError
            raise
          rescue InvalidRef => e
            error :import, :invalid_ref, ref: e.message
          rescue Error => e
            raise e.class.new(e.message, e.data.merge(source: to_s))
          ensure
            loaded
          end

          def source
            import['source']
          end

          def slug
            @slug ||= Ref.new(source).repo || parent.repo.slug
          end

          def merge_modes
            { lft: import['mode'] || :deep_merge_append } # rgt: config.merge_modes,
          end

          def part
            Parts::Part.new(raw, source, merge_modes)
          end

          def empty?
            raw.to_s.strip.empty?
          end

          def to_s
            "#{repo.slug}:#{path}@#{ref}"
          end

          def serialize
            {
              source: to_s,
              config: raw,
              mode: import['mode']
            }
          end

          private

            def expand(source)
              ref = local? ? parent&.ref : repo.default_branch
              ref = Ref.new(source, repo: repo.slug, ref: ref, path: parent&.path)
              ref.parts
            end

            def fetch
              Github::Content.new(repo, path, ref).content
            rescue FileNotFound => e
              required? ? raise : nil
            end
        end
      end
    end
  end
end
