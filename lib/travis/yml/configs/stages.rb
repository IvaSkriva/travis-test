require 'travis/yml/configs/model/job'

module Travis
  module Yml
    module Configs
      class Stages < Struct.new(:configs, :jobs)
        # This will use the stage order defined in the :stages section, or an
        # empty array if none. Any stage names that not present in the stages
        # section, but are present in the jobs list, will be appended to the
        # stages section, i.e. sorted to the end of the list.

        DEFAULT_STAGE = 'test'

        def apply
          assign_names if stages?
          [stages, jobs.map(&:attrs)]
        end

        def assign_names
          jobs.inject(DEFAULT_STAGE) do |name, job|
            job.stage ||= name
            job.stage = job.stage.to_s.capitalize
          end
        end

        def stages?
          !configs.empty? || !names.empty?
        end

        def stages
          names.map.with_index do |name, ix|
            stage(name) || { name: name }
          end
        end

        def stage(name)
          configs.detect { |config| config[:name] == name }
        end

        def names
          names = configs.map { |stage| stage[:name] }
          names = names + jobs.map(&:stage)
          names.compact.map(&:capitalize).uniq
        end

        def jobs
          @jobs ||= super.map { |attrs| Model::Job.new(attrs) }
        end

        def configs
          @configs ||= Array(super).map do |config|
            config[:name] ||= DEFAULT_STAGE
            config[:name].capitalize!
            config
          end
        end
      end
    end
  end
end
