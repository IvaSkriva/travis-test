require 'travis/yml/helper/condition'
require 'travis/yml/helper/obj'
require 'travis/yml/configs/model/job'

module Travis
  module Yml
    module Configs
      class AllowFailures < Struct.new(:configs, :jobs, :data)
        include Helper::Obj

        DEFAULT_STAGE = 'test'

        def apply
          allow_failures
          jobs.map(&:attrs)
        end

        def allow_failures
          configs.each do |config|
            select(config).each do |job|
              allow_failure(config, job)
            end
          end
        end

        def allow_failure(config, job)
          if accept?(config)
            job.allow_failure = true
          else
            # TODO generate a message
          end
        end

        def accept?(config)
          Condition.new(config, data).accept?
        end

        def select(config)
          jobs.select { |job| matches?(job, config) }
        end

        def matches?(job, config)
          config.all? do |key, value|
            if key == :branch
              # TODO deprecated in favor of conditional allow_failures
              data[:branch] == value
            else
              # TODO if this is a hash or array we should not match for
              # equality, but inclusion (partial allow_failure matching)
              job[key] == config[key]
            end
          end
        end

        def jobs
          @jobs ||= super.map { |attrs| Model::Job.new(attrs) }
        end

        def configs
          @configs ||= Array(super).map { |config| except(config, :if) }
        end
      end
    end
  end
end

