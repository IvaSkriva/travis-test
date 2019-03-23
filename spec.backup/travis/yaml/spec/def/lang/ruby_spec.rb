describe Travis::Yaml::Spec::Def::Ruby do
  let(:spec)    { Travis::Yaml.spec }
  let(:support) { Travis::Yaml.support }
  let(:lang)    { spec[:map][:language][:types][0] }
  let(:ruby)    { support[:map][:rvm][:types][0] }
  let(:gemfile) { support[:map][:gemfile][:types][0] }
  let(:jdk)     { support[:map][:jdk][:types][0] }
  let(:bundler_args) { support[:map][:bundler_args][:types][0] }

  it { expect(lang[:values]).to include(value: 'ruby') }
  it { expect(ruby[:only][:language]).to include('ruby') }
  it { expect(gemfile[:only][:language]).to include('ruby') }
  it { expect(jdk[:only][:language]).to include('ruby') }
  it { expect(bundler_args[:only][:language]).to include('ruby') }
end
