require "option_parser"
require "benchmark"
require "string_scanner"

PASSWORD_FORMAT =  /(?<min>\d+)-(?<max>\d+) (?<letter>\w): (?<password>\w+)/

file_name = ""
benchmark = false
sled_policy = false

OptionParser.parse do |parser|
  parser.banner = "Welcome to Report Repair"

  parser.on "-f FILE", "--file=FILE", "Input file" do |file|
    file_name = file
  end
  parser.on "-b", "--benchmark", "Measure benchmarks" do
    benchmark = true
  end
  parser.on "-s", "--sled", "Sled password policy" do
    sled_policy = true
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

unless file_name.empty?
  passwords = File.read_lines(file_name)
  
  if sled_policy
    if benchmark
      Benchmark.ips do |x|
        x.report("passwords") {result = number_of_valid_passwords_sled(passwords)}
      end
    else
      result = number_of_valid_passwords_sled(passwords)
    end
  else
    if benchmark
      Benchmark.ips do |x|
        x.report("passwords") {result = number_of_valid_passwords_toboggan(passwords)}
      end
    else
      result = number_of_valid_passwords_toboggan(passwords)
    end
  end

  puts result
end

def number_of_valid_passwords_sled(passwords : Array(String))
  total_valid = 0
  passwords.each do |password|
    if password_is_valid_sled(password)
      total_valid += 1
    end
  end
  return total_valid
end

def password_is_valid_sled(password : String)
  s = StringScanner.new(password)
  s.scan(PASSWORD_FORMAT)
  
  count = s["password"].count(s["letter"])
  if (s["min"].to_i <= count) && (count <= s["max"].to_i)
    return true
  else
    return false
  end
end

def number_of_valid_passwords_toboggan(passwords : Array(String))
  total_valid = 0
  passwords.each do |password|
    if password_is_valid_toboggan(password)
      total_valid += 1
    end
  end
  return total_valid
end

def password_is_valid_toboggan(password : String)
  s = StringScanner.new(password)
  s.scan(PASSWORD_FORMAT)
  
  position_1 = s["password"][s["min"].to_i - 1]
  position_2 = s["password"][s["max"].to_i - 1]

  if !(position_1.to_s == s["letter"]) ^ !(position_2.to_s == s["letter"])
    return true
  else
    return false
  end
end