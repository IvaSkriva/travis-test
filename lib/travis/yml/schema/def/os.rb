# frozen_string_literal: true
require 'travis/yml/schema/type'

module Travis
  module Yml
    module Schema
      module Def
        # TODO check with Hiro, see https://github.com/travis-ci/travis-ci/issues/2320
        # however, python is listed in the docs: https://docs.travis-ci.com/user/osx-ci-environment/#Runtimes
        # also, node_js now seems to be supported: https://github.com/travis-ci/travis-ci/issues/2311#issuecomment-205549262

        # going forward we should really  make it so that the :os dictates what
        # languages are supported, not the other way around

        EXCEPT = {
          linux: {
            language: %i(objective-c)
          },
          windows: {
            language: %i(objective-c)
          },
          freebsd: {
            language: %i(objective-c)
          }
        }

        ALIAS = {
          linux:   %i(ubuntu),
          osx:     %i(mac macos macosx ios),
          freebsd: %i(bsd),
          windows: %i(win)
        }

        class Oss < Type::Seq
          register :oss

          def define
            title 'Operating systems'
            summary 'Build environment operating systems'
            see 'Build Environment Overview': 'https://docs.travis-ci.com/user/reference/overview/'

            normal
            types :os
            export
          end
        end

        class Os < Type::Str
          register :os

          def define
            downcase

            value   :linux,   alias: ALIAS[:linux],   except: EXCEPT[:linux]
            value   :osx,     alias: ALIAS[:osx]
            value   :windows, alias: ALIAS[:windows], except: EXCEPT[:windows]
            value   :freebsd, alias: ALIAS[:freebsd], except: EXCEPT[:freebsd]
            value   :'linux-ppc64le' #, deprecated: 'use os: linux, arch: ppc64le'

            export
          end
        end
      end
    end
  end
end
