# frozen_string_literal: true

module Facts
  module Bsd
    class Filesystems
      FACT_NAME = 'filesystems'

      def call_the_resolver
        fact_value = Facter::Resolvers::Bsd::Filesystems.resolve(:systems)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
