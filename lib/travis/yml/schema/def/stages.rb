# frozen_string_literal: true
require 'travis/yml/schema/dsl/map'
require 'travis/yml/schema/dsl/seq'

module Travis
  module Yml
    module Schema
      module Def
        class Stages < Dsl::Seq
          register :stages

          def define
            summary 'Build stages definition'
            normal
            type :stage
            export
          end
        end

        class Stage < Dsl::Map
          register :stage

          def define
            # examples \
            #   name: 'job name',
            #   if: 'branch = master'

            prefix :name
            map :name, to: :str, eg: 'unit tests'
            map :if,   to: :str, eg: 'branch = master'
            export
          end
        end
      end
    end
  end
end
