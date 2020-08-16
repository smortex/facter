# frozen_string_literal: true

describe Facts::Bsd::Filesystems do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Bsd::Filesystems.new }

    let(:value) { 'devfs,fdescfs,procfs,zfs' }

    before do
      allow(Facter::Resolvers::Bsd::Filesystems).to \
        receive(:resolve).with(:systems).and_return(value)
    end

    it 'calls Facter::Resolvers::Bsd::Filesystems' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Bsd::Filesystems).to have_received(:resolve).with(:systems)
    end

    it 'returns file systems fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'filesystems', value: value)
    end
  end
end
