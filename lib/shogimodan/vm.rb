# coding: utf-8

class ShogiModan
  class VM
    def initialize(code, stdin=$stdin, stdout=$stdout)
      @code, @stdin, @stdout = code, stdin, stdout
      init
    end

    def init
      @registers = [nil, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      @stack = []
      @pc = 0
      @labels = collect_labels(@code)
    end
    attr_reader :registers, :stack, :pc
    private :init

    def run
      init

      loop do 
        op, arg1, arg2 = @code[@pc]
        #p [@pc, op, arg1, arg2, @registers, @stack]

        case op
        when nil
          break
        when :label
          # do nothing
        when :mov
          set(arg1, get(arg2))
        when :add
          set(arg1, get(arg1) + get(arg2))
        when :sub
          set(arg1, get(arg1) - get(arg2))
        when :mul
          set(arg1, get(arg1) * get(arg2))
        when :div
          set(arg1, get(arg1).to_f / get(arg2))
        when :mod
          set(arg1, get(arg1) % get(arg2))
        when :push
          @stack.push get(arg1)
        when :pop
          val = @stack.pop || (raise "stack is empty")
          set(arg1, val)
        when :putc
          if defined?(Encoding) then 
            @stdout.print get(arg1).to_i.chr(Encoding::UTF_8)
          else
            @stdout.print get(arg1).to_i.chr
          end
        when :putn
          @stdout.print get(arg1).to_s
        when :jump_if
          if get(arg1) != 0
            @pc = lookup_label(get(arg2)) - 1
          end
        when :jump_ifp
          if get(arg1) >= 0
            @pc = lookup_label(get(arg2)) - 1
          end
        else
          raise "unknown opecode: #{op.inspect}"
        end
        @pc += 1
      end
    end

    private 

    def collect_labels(code)
      {}.tap{|labels|
        code.each_with_index{|(op, arg1, arg2), i|
          if op == :label
            check_register_idx(arg1)
            labels[arg1] = i
          end
        }
      }
    end

    def lookup_label(n)
      if @labels.key?(n)
        @labels[n]
      else
        raise ShogiModan::ProgramError, "label number #{n} is not found"
      end
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
  end
end
