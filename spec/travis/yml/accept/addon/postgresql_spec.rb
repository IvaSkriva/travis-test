describe Travis::Yml do
  accept 'addon: postgresql' do
    describe 'postgresql' do
      yaml %(
        addons:
          postgresql: 9.1
      )
      it { should serialize_to addons: { postgresql: '9.1' } }
      it { should_not have_msg }
    end

    describe 'postgres (alias)' do
      yaml %(
        addons:
          postgres: 9.1
      )
      it { should serialize_to addons: { postgresql: '9.1' } }
      it { should have_msg [:info, :addons, :alias_key, alias: 'postgres', key: 'postgresql'] }
    end
  end
end
