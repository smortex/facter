# frozen_string_literal: true

module Facter
  module Resolvers
    module Bsd
      class Filesystems < BaseResolver
        # :systems
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_filesystems(fact_name) }
          end

          def read_filesystems(fact_name)
            require 'facter/resolvers/bsd/ffi/ffi_helper'
            filesystems = Facter::Bsd::FfiHelper.getfsstat
            @fact_list[:systems] = filesystems.sort.join(',')
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
