# coding: utf-8
require "#{File.expand_path File.dirname __FILE__}/spec_helper.rb"

describe "ShogiModan::Compiler" do
  context ".new" do
    it "should accept a string as soruce program" do
      @compiler = ShogiModan::Compiler.new("")
      @compiler.should be_instance_of(ShogiModan::Compiler)
    end
  end

  context "::REXP_CODE" do
    it "should match a opecode" do
      ShogiModan::Compiler::REXP_CODE.should match("▲１二歩")
    end

    it "should match a 'same'" do
      ShogiModan::Compiler::REXP_CODE.should match("▲同　歩")
    end
  end

  context "#compile" do
    def compile(src)
      ShogiModan::Compiler.new(src).compile
    end

    it "should compile a program" do
      code = compile("▲１一飛 △同　金 *1 this will be skipped")
      code.should == [[:jump_if, 1, 1], [:sub, 1, 1], [:label, 1]]
    end
  end
end
