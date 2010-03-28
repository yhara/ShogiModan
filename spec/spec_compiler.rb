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
  end

  context "#compile" do
    def compile(src)
      ShogiModan::Compiler.new(src).compile
    end

    it "should compile two opecodes" do
      code = compile("▲１二歩△３四金")
      code.should == [[:mov, 1, 2], [:add, 3, 4]]
    end

    it "should compile a label" do
      code = compile("▲１一飛 △３四金 *1 this will be skipped")
      code.should == [[:jump_if, 1, 1], [:add, 3, 4], [:label, 1]]
    end
  end
end
