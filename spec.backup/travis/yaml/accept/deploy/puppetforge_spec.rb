describe Travis::Yaml, 'deploy puppetforge' do
  let(:deploy) { subject.serialize[:deploy] }

  subject { described_class.apply(input) }

  let(:user)     { 'user' }
  let(:password) { 'password' }

  let(:input) do
    {
      deploy: {
        provider: 'puppetforge',
        user: user,
        password: password,
        url: 'url',
      }
    }
  end

  describe 'user, and password given as strings' do
    it { expect(deploy).to eq [input[:deploy]] }
  end

  describe 'user given as a secure string' do
    let(:user) { { secure: 'secure' } }
    it { expect(deploy).to eq [input[:deploy]] }
  end

  describe 'password given as a secure string' do
    let(:password) { { secure: 'secure' } }
    it { expect(deploy).to eq [input[:deploy]] }
  end
end
