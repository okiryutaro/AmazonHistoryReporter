require 'json'

def read_account(filename)
    File.open(filename) do |file|
        JSON.parse(File.read(file),symbolize_names:true)
    end
end


if __FILE__ == $PROGRAM_NAME
    account = read_account(ARGV[0])
    p account
    puts account[:email]
    puts account[:password]
end