# frozen_string_literal: true
module Travis
  module Yaml
    module Spec
      module Def
        module Deploy
          # docs do not mention pages
          class Pages < Deploy
            register :pages

            def define
              super
              map :github_token,       to: :str, secure: true
              map :repo,               to: :str
              map :target_branch,      to: :str
              map :local_dir,          to: :str
              map :fqdn,               to: :str
              map :project_name,       to: :str
              map :email,              to: :str
              map :name,               to: :str
              map :github_url,         to: :str
              map :keep_history,       to: :bool
              map :verbose,            to: :bool
              map :allow_empty_commit, to: :bool
              map :committer_from_gh,  to: :bool
              map :deployment_file,    to: :bool
            end
          end
        end
      end
    end
  end
end
