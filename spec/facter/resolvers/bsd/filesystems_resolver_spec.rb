# frozen_string_literal: true

describe Facter::Resolvers::Bsd::Filesystems do
  let(:systems) { 'devfs,fdescfs,procfs,zfs' }

  after do
    Facter::Resolvers::Bsd::Filesystems.invalidate_cache
  end

  before do
    allow(Facter::Bsd::FfiHelper).to receive(:getfsstat)
      .and_return(%w[devfs fdescfs procfs zfs])
  end

  it 'returns systems' do
    result = Facter::Resolvers::Bsd::Filesystems.resolve(:systems)

    expect(result).to eq(systems)
  end
end
