describe Travis::Yaml::Spec::Def::Dart do
  let(:spec)    { Travis::Yaml.spec }
  let(:support) { Travis::Yaml.support }
  let(:lang)    { spec[:map][:language][:types][0] }
  let(:dart)    { support[:map][:dart][:types][0] }
  let(:with_content_shell) { support[:map][:with_content_shell][:types][0] }

  it { expect(lang[:values]).to include(value: 'dart', alias: ['dartlang']) }
  it { expect(dart[:only][:language]).to include('dart') }
  it { expect(with_content_shell[:only][:language]).to include('dart') }
end
