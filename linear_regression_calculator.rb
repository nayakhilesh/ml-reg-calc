class LinearRegressionCalculator

  def initialize(learning_rate)
    @learning_rate = learning_rate
  end

  def learn_data(file, delimiter)
  
    maxs, mins, avgs = get_normalization_params(file, delimiter)
    @normalize = ->(feature, i) { (feature - avgs[i]) / (maxs[i] - mins[i]) }
    @theta = gradient_descent_algorithm(file, delimiter, maxs.size)

  end
  
  def predict(file, delimiter)
  
    line_count = %x(wc -l #{file}).split.first.to_i
    line_num = 0
    File.open(file + '.out', 'w') do |file_handle|
      File.open(file, 'r').each_line do |line|
        line_num += 1
        $logger.info(sprintf('Processing line %d of %d', line_num, line_count))
        tokens = line.chomp.split(delimiter)
        $logger.debug(tokens)
        sum = @theta[0]
        (0...(@theta.size - 1)).each do |i|
          sum += (@theta[i + 1] * @normalize.call(tokens[i].to_f, i))
        end
        file_handle.write(tokens.join(delimiter) + delimiter + sum.to_s)
        file_handle.write("\n")
      end
    end
  
  end
  
  private
  
  def gradient_descent_algorithm(file, delimiter, num_features)
  
    line_count = %x(wc -l #{file}).split.first.to_i
    line_num = 0
    
    x = []
    y = 0.0
    new_theta = [0.0]
    num_features.times { new_theta << 0.0 }
    theta = new_theta
    $logger.debug(theta)
      
    j = Float::MAX
    prev_j = Float::MAX
    iter = 0
    loop do
    
      iter += 1
      $logger.info('Starting iteration:' + iter.to_s)
      line_num = 0
      prev_j = j
      j = 0.0
      theta = new_theta
      new_theta = []
      File.open(file, 'r').each_line do |line|
        line_num += 1
        $logger.debug(sprintf('Processing line %d of %d', line_num, line_count))
        tokens = line.chomp.split(delimiter)
        $logger.debug(tokens)
        arr = []
        (0...num_features).each do |i|
          arr << @normalize.call(tokens[i].to_f, i)
        end
        x = [1.0] + arr
        $logger.debug(x)
        y = tokens.last.to_f
        $logger.debug(y)
        h = dot_prod(theta, x)
        error = h - y
        j += (error**2)
        (0...x.size).each do |i|
          new_theta[i] ||= 0.0
          new_theta[i] += (error * x[i])
        end
      end
      
      j /= (2 * line_num)
      $logger.debug(prev_j)
      $logger.info(j)
      (0...new_theta.size).each do |index|
        new_theta[index] = theta[index] - 
                           ((@learning_rate * new_theta[index]) / line_num)
      end
      
      break unless j < prev_j
    end
  
    theta
  end
  
  def dot_prod(vect1, vect2)
    (0...vect1.count).reduce(0.0) { |acc, index| acc + (vect1[index] * vect2[index]) }
  end
  
  def get_normalization_params(file, delimiter)
  
    line_count = %x(wc -l #{file}).split.first.to_i
    line_num = 0
    maxs = []
    mins = []
    avgs = []
    x_dim = 0
    File.open(file, 'r').each_line do |line|
      line_num += 1
      $logger.debug(sprintf('Processing line %d of %d', line_num, line_count))
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
  
    return maxs, mins, avgs
  end
  
end