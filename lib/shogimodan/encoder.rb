# coding: utf-8

class ShogiModan
  class Encoder
    def initialize(code)
      @code = code
    end

    def encode
      opnames = Compiler::OPERATORS.invert

      sente = true
      @code.map{|op, arg1, arg2|
        "".tap{|s|
          if op == :label
            s << "*#{arg1}"
          else
            s << (sente ? "▲" : "△")
            s << Compiler::COLS[arg1]
            s << (arg2 ? Compiler::ROWS[arg2] : "_")
            s << opnames[op]
            sente = !sente
          end
        }
      }.join(" ")
    end
  end
end

if $0==__FILE__
  $LOAD_PATH << "#{File.expand_path File.dirname __FILE__}/../"
  require "shogimodan"

  puts ShogiModan::Encoder.new([
    [:add, 1, 2], [:label, 3], [:putc, 4]
  ]).encode
end
