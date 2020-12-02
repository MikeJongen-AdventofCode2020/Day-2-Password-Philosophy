require "option_parser"
require "benchmark"

file_name = ""
benchmark = false

OptionParser.parse do |parser|
  parser.banner = "Welcome to Report Repair"

  parser.on "-f FILE", "--file=FILE", "Input file" do |file|
    file_name = file
  end
  parser.on "-b", "--benchmark", "Measure benchmarks" do
    benchmark = true
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

unless file_name.empty?
  passwords = File.read_lines(file_name)
  
  if benchmark
    Benchmark.ips do |x|
      x.report("passwords") {result = number_of_valid_passwords(passwords)}
    end
  else
    result = number_of_valid_passwords(passwords)
  end

  puts result
end

def number_of_valid_passwords(passwords : Array(String))
  total_valid = 0
  passwords.each do |password|
    if password_is_valid(password)
      total_valid += 1
    end
  end
  return total_valid
end

def password_is_valid(password : String)
  return false
end