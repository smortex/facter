# frozen_string_literal: true

require 'ffi'

module Facter
  module Bsd
    module FfiHelper
      module Libc
        extend FFI::Library

        MNT_NOWAIT = 2

        class Fsid < FFI::Struct
          layout :val, [:int32_t, 2]
        end

        class Statfs < FFI::Struct
          MFSNAMELEN = 16
          MNAMELEN = 1024
          STATFS_VERSION = 0x20140518

          layout :f_version, :uint32_t,
                 :f_type, :uint32_t,
                 :f_flags, :uint64_t,
                 :f_bsize, :uint64_t,
                 :f_iosize, :uint64_t,
                 :f_blocks, :uint64_t,
                 :f_bfree, :uint64_t,
                 :f_bavail, :int64_t,
                 :f_files, :uint64_t,
                 :f_ffree, :int64_t,
                 :f_syncwrites, :uint64_t,
                 :f_asyncwrites, :uint64_t,
                 :f_syncreads, :uint64_t,
                 :f_asyncreads, :uint64_t,
                 :f_spare, [:uint64_t, 10],
                 :f_namemax, :uint32_t,
                 :f_owner, :uid_t,
                 :f_fsid, Fsid,
                 :f_charspare, [:char, 80],
                 :f_fstypename, [:char, MFSNAMELEN],
                 :f_mntfromname, [:char, MNAMELEN],
                 :f_mntonname, [:char, MNAMELEN]
        end

        ffi_lib 'c'
        attach_function :getfsstat, %i[pointer long int], :int
        attach_function :sysctl, %i[pointer uint pointer pointer pointer size_t], :int
      end

      def self.getfsstat
        nullptr = FFI::Pointer::NULL

        count = Libc.getfsstat(nullptr, 0, Libc::MNT_NOWAIT)
        return nil if count.negative?

        buf = FFI::MemoryPointer.new(Libc::Statfs, count)
        count = Libc.getfsstat(buf, buf.size, Libc::MNT_NOWAIT)
        return nil if count.negative?

        fs = Array.new(count) do |i|
          Libc::Statfs.new(buf + i * Libc::Statfs.size)
        end

        fs.map { |x| x[:f_fstypename].to_s }.uniq
      end

      def self.sysctl(type, oids)
        name = FFI::MemoryPointer.new(:uint, oids.size)
        name.write_array_of_uint(oids)
        namelen = oids.size

        oldp = FFI::Pointer::NULL
        oldlenp = FFI::MemoryPointer.new(:size_t)

        newp = FFI::Pointer::NULL
        newlen = 0

        if type == :string
          res = Libc.sysctl(name, namelen, oldp, oldlenp, newp, newlen)
          return nil if res.negative?
        else
          oldlenp.write(:size_t, FFI.type_size(type))
        end

        oldp = FFI::MemoryPointer.new(:uint8_t, oldlenp.read(:size_t))
        res = Libc.sysctl(name, namelen, oldp, oldlenp, newp, newlen)
        return nil if res.negative?

        case type
        when :string
          oldp.read_string
        else
          oldp.read(type)
        end
      end
    end
  end
end
