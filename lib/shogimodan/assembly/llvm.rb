class ShogiModan
  class Assembly
    module LLVM
      HEADER =
        "define void @main() nounwind {\n" <<
        "%dst.r = alloca i32\n" <<
        "%r = alloca [9 x double]\n" <<
        (0..8).map {|i|
          "%header#{i} = getelementptr [9 x double]* %r, i32 0, i32 #{i}\n" <<
          "store double #{(i + 1).to_f}, double* %header#{i}, align 1\n"
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
            declare i8 @getchar() nounwind
          EOL
        end

        def body(iseqs)
          c = -1
          l = -1
          operate_register = lambda {|op, x, y|
            <<-"EOL"
            %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{x - 1}
            %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1
            %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{y - 1}
            %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1
            %tmp#{c += 1} = #{op} double %tmp#{c - 3}, %tmp#{c - 1}
            store double %tmp#{c}, double* %tmp#{c - 4}, align 1
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
              %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{a - 1}
              %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1
              %tmp#{c += 1} = fptosi double %tmp#{c - 1} to i8
              call i32 @putchar(i8 %tmp#{c})
              EOL
            when :mov
              <<-"EOL"
              %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{a - 1}
              %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{b - 1}
              %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1
              store double %tmp#{c}, double* %tmp#{c - 2}, align 1
              EOL
            when :label
              <<-"EOL"
              br label %label.#{a}
              label.#{a}:
              EOL
            when :jump_if, :jump_ifp
              <<-"EOL"
              %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{a - 1}
              %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1

              %tmp#{c += 1} = fcmp #{inst == :jump_if ? :one : :oge} double %tmp#{c - 1}, 0.0
              br i1 %tmp#{c}, label %jump_if.true.#{l + 1}, label %jump_if.false.#{l + 1}

              jump_if.true.#{l += 1}:
              %tmp#{c += 1} = getelementptr [9 x double]* %r, i32 0, i32 #{b - 1}
              %tmp#{c += 1} = load double* %tmp#{c - 1}, align 1
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
