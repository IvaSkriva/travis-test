require 'travis/yml/docs/examples'
require 'travis/yml/docs/page'
require 'travis/yml/docs/schema'

module Travis
  module Yml
    module Docs
      extend self, Helper::Obj

      def index(current)
        Page::Index.new(pages, current).render
      end

      def pages
        @pages ||= begin
          pages = root.pages.uniq(&:full_id)
          pages = pages.map { |page| [page.full_id, page] }
          pages = pages.to_h.sort.to_h
          only(pages, :root).merge(except(pages, :root))
        end
      end

      def root
        schema = Schema::Factory.build(nil, Yml.schema)
        Page.build(schema)
      end
    end
  end
end
