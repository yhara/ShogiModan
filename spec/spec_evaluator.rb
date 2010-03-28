# coding: utf-8
$DEBUG = false
class ShogiModan
  def initialize(src="")
    @code = parse(src)
  end

  def run
    show(@code)

    @registers = [nil, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    @stack = []
    @pc = 0
    loop do 
      op, arg1, arg2 = @code[@pc]

      p [@pc, op, arg1, arg2, @registers, @stack] if $DEBUG

      case op
      when nil
        break
      when :mov
        set(arg1, get(arg2))
      when :load
        set(arg1, arg2)
      when :add
        set(arg1, get(arg1) + get(arg2))
      when :sub
        set(arg1, get(arg1) - get(arg2))
      when :mul
        set(arg1, get(arg1) * get(arg2))
      when :div
        set(arg1, get(arg1) / get(arg2))
      when :mod
        set(arg1, get(arg1) % get(arg2))
      when :push
        @stack.push get(arg1)
      when :pop
        val = @stack.pop || (raise "stack is empty")
        set(arg1, val)
      when :putc
        if defined?(Encoding) then 
          print get(arg1).chr(Encoding::UTF_8)
        else
          print get(arg1).chr
        end
      when :putn
        print get(arg1)
      when :jump
        @pc += get(arg1)
      when :if
        if get(arg1) != 0
          @pc += get(arg2)
        end
      when :exit
        break
      when :puts
        print arg1
      end
      @pc += 1
    end
  end

  private

  OPERATORS = {
    :mov  => "歩",
    :add  => "金",
    :sub  => "銀",
    :mul  => "桂",
    :div  => "香",
    :mod  => "と",
    :push => "龍",
    :pop  => "馬",
    :putc => "玉",
    :putn => "王",
    :if   => "飛",
    :ifp  => "角",
    # :lt ? 
  }
#  SENTE = "先手"
#  GOTE = "後手"
  SENTE = "☗"
  GOTE  = "☖"
  COL    = %w(* １ ２ ３ ４ ５ ６ ７ ８ ９)
  ROW = %w(* 一 二 三 四 五 六 七 八 九)
  def show(code)
    sente = true
    code.each do |op, arg1, arg2|
      $stderr.print(if sente then SENTE else GOTE end)
      if arg1.is_a? String 
        $stderr.print [op, arg1, arg2].inspect
      else
        $stderr.print " #{COL[arg1||0]}#{ROW[arg2||0]}#{OPERATORS[op]||op}"
      end
      $stderr.puts
      sente = !sente
    end
    puts code.map(&:first).inject(Hash.new{0}){|h, op| h[op] += 1; h}.sort_by{|k, v|v}
  end

  def get(i)
    check_register_idx(i)
    @registers[i]
  end

  def set(i, v)
    check_register_idx(i)
    @registers[i] = v
  end

  def check_register_idx(*args)
    args.each do |i|
      unless (0..9).include? i
        raise "bad index of register: #{i}"
      end
    end
  end

  def parse(src)
  end
end

def R(n); n; end

require 'kagemusha'
def exec(code)
  buf = ""
  musha = Kagemusha.new(Kernel)
  musha.def(:print){|s|
    buf << s.to_s
    $stderr.print s.to_s if $DEBUG
  }
  #  musha.def(:puts){|s|
  #    buf << s + "\n"
  #    $stderr.puts s if $DEBUG
  #  }
  musha.swap{
    sm = ShogiModan.new
    sm.instance_variable_set(:@code, code)
    sm.run
  }
  buf
end

describe "ShogiModan evaluator" do
  it "evaluates a program which displays 'Hi'" do
    exec([
         [:mul,  R(9), R(8)], # ９八
         [:putc, R(9)],       # ９x
         [:mul,  R(8), R(4)], # ８四
         [:add,  R(9), R(8)], # ９八
         [:add,  R(9), R(1)], # ９一
         [:putc, R(9)]        # ９x
    ]).should == "Hi"
  end

  it "evaluates a fizzbuzz program" do
    ct = 9
    tmp1 = 8
    tmp2 = 8
    tmp3 = 8
    tmp4 = 8
    tmp5 = 8
    tmp6 = 8
    # 6 - 35 = -29
    exec([
         # 準備：R2に終了値を作る
         [:mul, R(2), R(8)],
         # 準備：
         [:mul, R(7), R(5)],
         [:sub, R(6), R(7)],

         # スタックに1をpush
         [:push, R(1)], 
         # ループ開始
         # カウントをpop
         [:pop, R(ct)],
         # 終了チェック
         [:mov, R(tmp1), R(ct)],
         [:sub, R(tmp1), R(2)],
         [:if, R(tmp1), R(1)],
         [:exit],

         [:push, R(1)],
         # Fizz?
         [:mov, R(tmp2), R(ct)],
         [:mod, R(tmp2), R(3)],
         [:if, R(tmp2), R(4)],
         [:puts, "Fizz"],
         [:pop, R(tmp4)],
         [:add, R(tmp4), R(1)],
         [:push, R(tmp4)],
         # Buzz?
         [:mov, R(tmp3), R(ct)],
         [:mod, R(tmp3), R(5)],
         [:if, R(tmp3), R(4)],
         [:puts, "Buzz"],
         [:pop, R(tmp5)],
         [:add, R(tmp5), R(1)],
         [:push, R(tmp5)],
         # num?
         [:pop, R(tmp6)],
         [:sub, R(tmp6), R(1)],
         [:if, R(tmp6), R(1)],
         [:putn, R(ct)],

         # 改行
         [:mov, R(8), R(5)],
         [:add, R(8), R(5)],
         [:putc, R(8)],

         # カウントアップ
         [:add, R(ct), R(1)],
         [:push, R(ct)],

         # 戻る
         [:if, R(1), R(6)]
    ]).should == [
    "1",
    "2",
    "Fizz",
    "4",
    "Buzz",
    "Fizz",
    "7",
    "8",
    "Fizz",
    "Buzz",
    "11",
    "Fizz",
    "13",
    "14",
    "FizzBuzz",
    ].map{|x| x+"\n"}.join
  end
end
