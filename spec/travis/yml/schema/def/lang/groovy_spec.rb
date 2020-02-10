describe Travis::Yml::Schema::Def::Groovy do
  subject { Travis::Yml.schema[:definitions][:language][:groovy] }

  # it { puts JSON.pretty_generate(subject) }

  it do
    should include(
    '$id': :groovy,
      title: 'Groovy',
      summary: kind_of(String),
      see: kind_of(Hash),
      type: :object,
      properties: {
        jdk: {
          '$ref': '#/definitions/type/jdks',
          flags: [
            :expand
          ],
          only: {
            language: [
              'groovy'
            ]
          },
        }
      },
      normal: true
    )
  end
end
