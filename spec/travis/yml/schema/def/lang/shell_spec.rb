describe Travis::Yml::Schema::Def::Shell do
  subject { Travis::Yml.schema[:definitions][:language][:shell] }

  # it { puts JSON.pretty_generate(subject) }

  it do
    should include(
      '$id': :shell,
        title: 'Shell',
        summary: kind_of(String),
        see: kind_of(Hash),
        type: :object,
        normal: true
    )
  end
end
