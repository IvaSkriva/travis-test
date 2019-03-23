describe Travis::Yaml::Spec::Def::Rust do
  let(:spec)    { Travis::Yaml.spec }
  let(:support) { Travis::Yaml.support }
  let(:lang)    { spec[:map][:language][:types][0] }
  let(:rust)    { support[:map][:rust][:types][0] }

  it { expect(lang[:values]).to include(value: 'rust') }
  it { expect(rust[:only][:language]).to include('rust') }
end
