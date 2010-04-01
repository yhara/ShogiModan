# coding: utf-8

# for ruby 1.8.7
unless [].respond_to?(:sample)
  class Array; alias sample choice; end
end

class ShogiModan
  class Encoder
    def initialize(code, autofill=false)
      @code, @autofill = code, autofill
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
            if arg2
              s << Compiler::ROWS[arg2]
            elsif @autofill
              s << Compiler::ROWS.sample
            else
              s << "_"
            end
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
  ], true).encode
end
