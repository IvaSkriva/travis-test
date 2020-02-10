describe Travis::Yml::Schema::Def::Addon::Homebrew do
  subject { Travis::Yml.schema[:definitions][:addon][:homebrew] }

   # it { puts JSON.pretty_generate(subject) }

  it do
    should include(
      '$id': :homebrew,
      title: 'Homebrew',
      summary: kind_of(String),
      see: kind_of(Hash),
      normal: true,
      anyOf: [
        {
          type: :object,
          properties: {
            update: {
              type: :boolean
            },
            packages: {
              '$ref': '#/definitions/type/strs'
            },
            casks: {
              '$ref': '#/definitions/type/strs'
            },
            taps: {
              '$ref': '#/definitions/type/strs'
            },
            brewfile: {
              anyOf: [
                {
                  type: :boolean
                },
                {
                  type: :string
                }
              ]
            }
          },
          additionalProperties: false,
          normal: true,
          prefix: {
            key: :packages
          },
          changes: [
            {
              change: :enable
            }
          ],
        },
        {
          '$ref': '#/definitions/type/strs'
        },
        {
          type: :boolean
        }
      ]
    )
  end
end
