# coding: utf-8

require 'shogimodan/compiler.rb'
require 'shogimodan/vm.rb'

class ShogiModan
  ProgramError = Class.new(StandardError)

  def initialize(src)
    @src = parse src
  end

  def run
    @src.each_line do |line|
      if line =~ /２四歩/
      end
    end
  end

  private

  OPERATORS = {
    "歩" => :mov,
    "と" => :putn,
    "香" => :mul,
    "桂" => :sub,
    "銀" => :add,
    "金" => :putc,
    "王" => :eq,
    "玉" => :neq,
    "飛" => :jmp,
    "龍" => :jzero,
    "角" => :div,
    "馬" => :mod,
  }
  REGISTERS = %w(一 二 三 四 五 六 七 八 九)
  VALUES    = %w(１ ２ ３ ４ ５ ６ ７ ８ ９)

  def parse(src)
    src.scan(/[１-９][一-九][歩と香桂銀金王玉飛龍角馬]/).map{|move|
      val, reg, op = *move.chars.to_a

      [OPERATORS[op], REGISTERS.index(reg)+1, VALUES.index(val)+1]
    }
  end

end
