# Number Proof Generator

module AST
  OPS = ['+', '-', '*', '/']
  PREC = {'+' => 10, '-' => 10, '*' => 20, '/' => 20}

  class Node
    attr_reader :lhs, :op, :rhs

    def initialize(lhs, op, rhs)
      @lhs = lhs
      @op = op
      @rhs = rhs
    end

    def evaluate
      l = @lhs.evaluate
      r = @rhs.evaluate
      case @op
      when '+'
        l + r
      when '-'
        l - r
      when '*'
        l * r
      when '/'
        l.to_f / r
      end
    end

    def to_s
      l = lhs.to_s
      l = '(' + l + ')' if lhs.is_a?(Node) and PREC[lhs.op] < PREC[@op]
      r = rhs.to_s
      r = '(' + r + ')' if rhs.is_a?(Node) and PREC[rhs.op] <= PREC[@op]
      return l + op + r
    end
  end
end

class String
  def evaluate
    self.to_i
  end
end

def enumast(numbers, ops)
  l = numbers.size
  if l > 1
    for i in 1..(l-1)
      n1 = numbers[0, l-i]
      n2 = numbers[l-i, l]
      enumast n1, ops do |a|
        enumast n2, ops do |b|
          for op in ops
            yield AST::Node.new(a, op, b)
          end
        end
      end
    end
  else
    yield numbers[0]
  end
end

def combnum(numbers, groups)
  l = numbers.size
  if l > groups
    if groups > 1
      for i in 1..(l-groups+1)
        n1 = numbers[0, i]
        n2 = numbers[i, l]
        combnum n2, groups - 1 do |g|
          yield [n1.join] + g
        end
      end
    else
      yield [numbers.join]
    end
  else
    yield numbers
  end
end

def npgen(numbers, results)
  for i in 1..(numbers.size)
    combnum numbers, i do |n|
      enumast n, AST::OPS do |ast|
        res = ast.evaluate
        if res.finite? and res.to_i == res
          res = res.to_i
          s  = ast.to_s
          if res >= 0 
            if results[res].nil? || results[res].size > s.size
              results[res] = s
            end
          end
        end
      end
    end
  end
end

results = {}
for i in 1..9
  STDERR.puts i
  npgen(['9']*i, results)
end

sorted = []
results.each_pair do |k, v|
  sorted.push [k, v]
end

sorted.sort_by! {|x| x[0]}
sorted.each do |x|
  puts "#{x[0]} = #{x[1]}"
end