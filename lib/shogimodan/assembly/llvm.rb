class ShogiModan
  class Assembly
    module LLVM
      HEADER =
        "define void @main() nounwind {\n" <<
        "%r = alloca [9 x double]\n" <<
        (0..8).map {|i|
          "%header#{i} = getelementptr [9 x double]* %r, i32 0, i32 #{i}\n" <<
          "store double #{(i + 1).to_f}, double* %header#{i}, align 1\n"
        }.join

      FOOTER = <<-EOL
          ret void
        }
        declare i32 @putchar(i8) nounwind
        declare i8 @getchar() nounwind
      EOL

      class << self
        def convert(iseqs)
          HEADER + body(iseqs) + FOOTER
        end

        private

        def body(iseqs)
          c = -1
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
            else
              raise "#{inst.inspect} is not implemented."
            end
          }.join "\n"
        end
      end
    end
  end
end
