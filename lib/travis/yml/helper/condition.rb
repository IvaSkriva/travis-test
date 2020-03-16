require 'travis/conditions'
require 'travis/yml/helper/obj'

module Travis
  module Yml
    class Condition
      include Helper::Obj, Memoize

      attr_reader :cond, :config, :data

      def initialize(cond, config, data)
        @cond = normalize(cond)
        @config = config
        @data = data
      end

      def accept?
        return true unless cond
        data = merge(self.data, config.dup)
        Travis::Conditions.eval(cond, data, version: :v1)
      rescue TypeError, ArgumentError, RegexpError => e
        Raven.capture_exception(e, extra: { condition: cond, data: data }) if defined?(Raven)
        false
      rescue Travis::Conditions::Error => e
        false
      end

      def normalize(cond)
        cond.to_s unless cond.nil? || cond.is_a?(Array) || cond.is_a?(Hash)
      end

      def merge(data, config)
        # This should merge env.global only, but Gatekeeper's build config
        # normalization moves env.jobs to env and there are existing configs
        # relying on this.
        #
        # E.g.: https://travis-ci.org/mlpack/ensmallen/builds/659436019/config
        #
        #   env:
        #     - ONE=one
        #   stages:
        #     - name: one
        #       if: 'env(ONE) = one'
        #   jobs:
        #     include:
        #       - stage: one
        #         name: one
        #
        # Yml moves env to env.jobs, but Gatekeeper's build config normalization
        # moves it back to env, using _that_ config internally for filtering
        # stages and POSTing it to /expand, which filters jobs.
        config[:env] = super(*config[:env].values_at(:global, :jobs, :matrix).flatten.compact) if config[:env].is_a?(Hash)
        super
      end

      def to_s
        "IF #{config[:if]}"
      end
    end
  end
end
