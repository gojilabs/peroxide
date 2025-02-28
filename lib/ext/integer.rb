# frozen_string_literal: true

class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 8
  MAX_UINT = 2**N_BITS - 1
  MAX_INT = 2**(N_BITS - 1) - 1
  MIN_INT = -MAX_INT - 1
  MIN_UINT = 0
end
