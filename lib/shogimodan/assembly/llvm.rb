class ShogiModan
  class Assembly
    module LLVM
      HEADER =
        "@str = internal constant [3 x i8] c\"%f\\00\"\n"<<
        "define void @main() nounwind {\n" <<
        "%stack = alloca double, i32 1000\n" <<
        "%sp = alloca i32\n" <<
        "store i32 0, i32* %sp\n" <<
        "%dst.r = alloca i32\n" <<
        (1..9).map {|i|
          "%r.#{i} = alloca double\n" <<
          "%r.ptr.#{i} = getelementptr double* %r.#{i}\n" <<
          "store double #{i.to_f}, double* %r.ptr.#{i}, align 1\n"
        }.join

      class << self
        def convert(iseqs)
          HEADER + body(iseqs) + footer(iseqs)
        end

        private
        def footer(iseqs)
          labels = iseqs.select{|op, x, y|op == :label}
          return <<-EOL

              br label %exit
            switch:
              %dst = load i32* %dst.r
              switch i32 %dst, label %exit [
                #{labels.map{|_, n| "i32 #{n}, label %label.#{n}"}.join("\n")}
              ]
            exit:
              ret void
            }
            declare i32 @putchar(i8) nounwind
            declare i32 @printf(i8*, ...) nounwind
            declare i8 @getchar() nounwind
          EOL
        end

        def body(iseqs)
          c = -1
          l = -1
          operate_register = lambda {|op, x, y|
            <<-"EOL"
            %tmp#{c += 1} = load double* %r.ptr.#{x}, align 1
            %tmp#{c += 1} = load double* %r.ptr.#{y}, align 1
            %tmp#{c += 1} = #{op} double %tmp#{c - 2}, %tmp#{c - 1}
            store double %tmp#{c}, double* %r.ptr.#{x}, align 1
            EOL
          }

          iseqs.map {|inst, a, b|
            case inst
            when :add, :mul, :sub
              operate_register.call inst, a, b
            when :div
              operate_register.call :fdiv, a, b
            when :mod
              operate_register.call :frem, a, b
            when :putc
              <<-"EOL"
              %tmp#{c += 1} = load double* %r.ptr.#{a}, align 1

              %tmp#{c += 1} = fptosi double %tmp#{c - 1} to i8
              call i32 @putchar(i8 %tmp#{c})
              EOL
            when :putn
              <<-"EOL"
              %tmp#{c += 1} = load double* %r.ptr.#{a}, align 1
              call i32 (i8*, ...)* @printf(i8* getelementptr([3 x i8]* @str,i32 0,i32 0),double %tmp#{c})
              EOL
            when :mov
              <<-"EOL"
              %tmp#{c += 1} = load double* %r.ptr.#{b}, align 1
              store double %tmp#{c}, double* %r.ptr.#{a}, align 1
              EOL
            when :label
              <<-"EOL"
              br label %label.#{a}
              label.#{a}:
              EOL
            when :push
              <<-"EOL"
              %tmp#{c += 1} = load double* %r.ptr.#{a}, align 1
              %tmp#{c += 1} = load i32* %sp
              %tmp#{c += 1} = getelementptr double* %stack, i32 %tmp#{c - 1}
              store double %tmp#{c - 2}, double* %tmp#{c}, align 1

              %tmp#{c += 1} = add i32 %tmp#{c - 2}, 1
              store i32 %tmp#{c}, i32* %sp, align 1
              EOL
            when :pop
              <<-"EOL"
              %tmp#{c += 1} = load i32* %sp
              %tmp#{c += 1} = sub i32 %tmp#{c - 1}, 1
              store i32 %tmp#{c}, i32* %sp, align 1

              %tmp#{c += 1} = getelementptr double* %stack, i32 %tmp#{c - 1}
              %tmp#{c += 1} = load double* %tmp#{c - 1}

              store double %tmp#{c}, double* %r.ptr.#{a}, align 1;1
              EOL
            when :jump_if, :jump_ifp
              <<-"EOL"
              %tmp#{c += 1} = load double* %r.ptr.#{a}, align 1

              %tmp#{c += 1} = fcmp #{inst == :jump_if ? :one : :oge} double %tmp#{c - 1}, 0.0
              br i1 %tmp#{c}, label %jump_if.true.#{l + 1}, label %jump_if.false.#{l + 1}

              jump_if.true.#{l += 1}:
              %tmp#{c += 1} = load double* %r.ptr.#{b}, align 1
              %tmp#{c += 1} = fptoui double %tmp#{c - 1} to i32
              store i32 %tmp#{c}, i32* %dst.r
              br label %switch

              jump_if.false.#{l}:
              EOL
            else
              raise "#{inst.inspect} is not implemented."
            end
          }.join "\n"
        end
      end
    end
  end
end
