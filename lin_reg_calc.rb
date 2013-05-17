# Akhilesh Nayak
# 5/15/2013

require 'optparse'
require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO


def process_data_file(filename,delimiter,alpha)

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
      maxs = tokens.first(x_dim).map(&:to_f)
      mins = tokens.first(x_dim).map(&:to_f)
      avgs = tokens.first(x_dim).map(&:to_f)
    else
      (0...x_dim).each do |index|
        maxs[index] < tokens[index].to_f and maxs[index] = tokens[index].to_f
        mins[index] > tokens[index].to_f and mins[index] = tokens[index].to_f
        avgs[index] = avgs[index] + tokens[index].to_f
      end
    end
  end
  
  avgs.map! { |sum| sum / line_num }
  
  $logger.debug(maxs)
  $logger.debug(mins)
  $logger.debug(avgs)
  
  x = []
  y = 0.0
  new_theta = [0.0]
  x_dim = maxs.size
  x_dim.times { new_theta << 0.0 }
  theta = new_theta
  $logger.debug(theta)
    
  j = Float::MAX
  prev_j = Float::MAX
  iter = 0
  begin
  
    iter += 1
    $logger.info('Starting iteration:' + iter.to_s)
    line_num = 0
    prev_j = j
    j = 0.0
    theta = new_theta
    new_theta = []
    File.open(filename, 'r').each_line do |line|
      line_num += 1
      $logger.debug('Processing line %d of %d' %[line_num,line_count])
      tokens = line.chomp.split(delimiter)
      $logger.debug(tokens)
      arr = []
      (0...x_dim).each do |i|
        arr << normalize(tokens[i].to_f,avgs[i],maxs[i]-mins[i])
      end
      x = [1.0] + arr
      $logger.debug(x)
      y = tokens.last.to_f
      $logger.debug(y)
      h = dot_prod(theta,x)
      error = h - y
      j += (error ** 2)
      (0...x.size).each do |i|
        new_theta[i] ||= 0.0
        new_theta[i] += (error * x[i])
      end
    end
    
    j /= (2*line_num)
    $logger.debug(prev_j)
    $logger.info(j)
    (0...new_theta.size).each do |index|
      new_theta[index] = theta[index] - ((alpha*new_theta[index])/line_num)
    end
        
  end while j < prev_j
  
  return theta,maxs,mins,avgs
end

def dot_prod(vect1,vect2)
  (0...vect1.count).inject(0.0) { |acc, index| acc + vect1[index]*vect2[index] }
end

def normalize(feature,mean,range)
  (feature - mean) / range
end

def usage
  'Usage: lin_reg_calc.rb --train FILE --input FILE [--alpha FLOAT] [--delimiter CHAR]'
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
    
    options[:alpha] = 0.1
    opts.on('-a', '--alpha FLOAT', 'Learning rate (default is 0.1)') do |num|
      options[:alpha] = num.to_f
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
    
    start_time = Time.now
    
    theta,maxs,mins,avgs = process_data_file(options[:training_file],options[:delimiter],options[:alpha])
    p theta
    p maxs
    p mins
    p avgs
    
    end_time = Time.now
    $logger.info('Total time=%ds' %[end_time - start_time])
    
    puts 'x1='
    x1 = gets.chomp.to_f
    puts 'x2='
    x2 = gets.chomp.to_f
    
    puts (theta[0] + (theta[1]*normalize(x1,avgs[0],maxs[0] - mins[0])) +
                    (theta[2]*normalize(x2,avgs[1],maxs[1] - mins[1])))

  else
    puts usage
    exit
  end
  
end

if __FILE__ == $0
  main
end