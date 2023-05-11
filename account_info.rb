# frozen_string_literal: true

require 'json'

module AccountInfo # <1>
  def read(filename) # <2>
    File.open(filename) do |file|
      JSON.parse(File.read(file), symbolize_names: true)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  class AccountInfoTest # <3>
    include AccountInfo # <4>
  end

  info_test = AccountInfoTest.new
  account = info_test.read(ARGV[0]) # <5>
  p account
  puts account[:email]
  puts account[:password]
end
