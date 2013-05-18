# Akhilesh Nayak
# 5/15/2013

require 'optparse'
require 'logger'
require 'linear_regression_calculator'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

def usage
  'Usage: lin_reg_calc.rb --train FILE --input FILE [--rate FLOAT] [--delimiter CHAR]'
end

def parse_options

  options = {}
  optparse = OptionParser.new do |opts|
  
    opts.banner = usage
    
    options[:training_file] = nil
    opts.on('-t', '--train FILE', 'File with training data') do |file|
      options[:training_file] = file
    end
    
    options[:input_file] = nil
    opts.on('-i', '--input FILE', 'Input file with required predictions') do |file|
      options[:input_file] = file
    end
    
    options[:rate] = 0.1
    opts.on('-r', '--rate FLOAT', 'Learning rate (default is 0.1)') do |num|
      options[:rate] = num.to_f
    end
    
    options[:delimiter] = ','
    opts.on('-l', '--delimiter CHAR', 'Character delimiting the data (default is \',\')') do |char|
      options[:delimiter] = char
    end
        
    opts.on('-d', '--debug', 'Print debugging output') do
      $logger.level = Logger::DEBUG
    end
    
    opts.on('-h', '--help', 'Display this screen') do
     puts opts
     exit
    end
    
  end
  
  optparse.parse!
  return options
  
end

def main
  
  options = parse_options

  if options[:training_file] and options[:input_file]
    
    start_time = Time.now
    
    calc = LinearRegressionCalculator.new(options[:rate])
    
    calc.learn_data(options[:training_file], options[:delimiter])
    
    calc.predict(options[:input_file], options[:delimiter])
    
    end_time = Time.now
    
    $logger.info('Total time=%ds' %[end_time - start_time])
    
  else
  
    puts usage
    exit

  end

end

if __FILE__ == $0
  main
end