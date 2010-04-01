# coding: utf-8

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
              s << Compiler::ROWS[rand(9)+1]
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
    [:sub, 9, 9], # prev
    [:sub, 8, 7], # current
    [:add, 6, 4], [:mul, 6, 6], [:mul, 6, 6],
    [:sub, 7, 7], [:sub, 7, 6], # counter
    [:add, 5, 5], # newline

    [:label, 1], # begin loop
      [:jump_ifp, 7, 2],
      [:add, 7, 1],

      [:putn, 8],
      [:putc, 5],
      [:push, 8], [:add, 8, 9], [:pop, 9],

      [:jump_if, 1, 1],
    [:label, 2] # end loop
    
  ], true).encode
end
