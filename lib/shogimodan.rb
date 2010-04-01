# coding: utf-8

require 'shogimodan/compiler.rb'
require 'shogimodan/vm.rb'
require 'shogimodan/encoder.rb'
require 'shogimodan/assembly/llvm.rb'

class ShogiModan
  ProgramError = Class.new(StandardError)

  def initialize(src, stdin=$stdin, stdout=$stdout)
    @src, @stdin, @stdout = src, stdin, stdout
  end

  def run
    code = Compiler.new(@src).compile
    VM.new(code, @stdin, @stdout).run
  end
end
