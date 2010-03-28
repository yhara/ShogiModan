# coding: utf-8

class ShogiModan
  class Compiler
    REXP_CODE = /[▲△☗☖]([１-９同])([一二三四五六七八九　])([歩金銀桂香と龍馬玉王飛角])/
    REXP_LABEL = /\*(\d+)/

    COLS = %w(* １ ２ ３ ４ ５ ６ ７ ８ ９)
    ROWS = %w(* 一 二 三 四 五 六 七 八 九)
    SAME = "同"
    OPERATORS = {
      "と" => :mov ,
      "歩" => :add ,
      "金" => :sub ,
      "銀" => :mul ,
      "桂" => :div ,
      "香" => :mod ,
      "龍" => :push,
      "馬" => :pop ,
      "玉" => :putc,
      "王" => :putn,
      "飛" => :jump_if,
      "角" => :jump_ifp,
    }

    def initialize(src)
      @src = src
    end

    def compile
      last_pos = nil
      rexp = Regexp.union(REXP_CODE, REXP_LABEL)
      @src.scan(rexp).map{|arg1, arg2, operator, label|
        if operator
          if arg1 == SAME
            col, row = last_pos
          else
            col = COLS.index(arg1)
            row = ROWS.index(arg2)
            last_pos = [col, row]
          end
            
          op  = OPERATORS[operator]
          [op, col, row]
        else
          [:label, label.to_i]
        end
      }
    end
  end
end
