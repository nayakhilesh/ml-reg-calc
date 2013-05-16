# Akhilesh Nayak
# 5/15/2013

require 'optparse'
require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO


def process_data_file(filename,delimiter)

  line_count = %x{wc -l #{filename}}.split.first.to_i
  line_num = 0
  maxs = []
  mins = []
  avgs = []
  x_dim = 0
  File.open(filename, 'r').each_line do |line|
    line_num += 1
    $logger.info('Processing line %d of %d' %[line_num,line_count])
    tokens = line.chomp.split(delimiter)
    $logger.debug(tokens)
    if line_num == 1
      x_dim = tokens.size - 1
      maxs = tokens[0...x_dim].map(&:to_f)
      mins = tokens[0...x_dim].map(&:to_f)
      avgs = tokens[0...x_dim].map(&:to_f)
    else
      (0...x_dim).each do |index|
        maxs[index] < tokens[index].to_f and maxs[index] = tokens[index].to_f
        mins[index] > tokens[index].to_f and mins[index] = tokens[index].to_f
        avgs[index] = avgs[index] + tokens[index].to_f
      end
    end
  end
  
  (0...x_dim).each do |index|
    avgs[index] = avgs[index] / line_num
  end
  
  $logger.debug(maxs)
  $logger.debug(mins)
  $logger.debug(avgs)
  
  # TODO

end


def usage
  'Usage: lin_reg_calc.rb --train FILE --input FILE [--delimiter CHAR]'
end

def parse_options

  options = {}
  optparse = OptionParser.new do |opts|
  
    opts.banner = usage
    
    options[:training_file] = nil
    opts.on('-t', '--train FILE', 'File with training data') do |filename|
      options[:training_file] = filename
    end
    
    options[:input_file] = nil
    opts.on('-i', '--input FILE', 'Input file with required predictions') do |filename|
      options[:input_file] = filename
    end
    
    options[:delimiter] = ','
    opts.on('-l', '--delimiter CHAR', 'Character delimiting the data') do |char|
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
    
    process_data_file(options[:training_file],options[:delimiter])

  else
      puts usage
      exit
  end
  
end

if __FILE__ == $0
  main
end