# coding: utf-8
require "#{File.expand_path File.dirname __FILE__}/spec_helper.rb"

describe "ShogiModan::VM" do
  context ".new" do
    before :each do
      @vm = ShogiModan::VM.new([])
    end

    it "should accept an array" do
      @vm.should be_an_instance_of(ShogiModan::VM)
    end

    it "should initialize variables" do
      @vm.registers.should == [nil, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      @vm.stack.should be_empty
      @vm.pc.should == 0
    end
  end

  context "#collect_labels" do
    it "should collect all the labels" do
      code = [[:label, 1], [:mov, 2, 3], [:label, 2]]
      vm = ShogiModan::VM.new(code)
      vm.send(:collect_labels, code).should == {1 => 0, 2 => 2}
    end
  end

  context "#evaluate" do
    def evaluate(code)
      @vm = ShogiModan::VM.new(code, @in||$stdin, @out||$stdout)
      @vm.run
    end

    it "should execute :mov" do
      evaluate [[:mov, 1, 9]]
      @vm.registers[1].should == 9
    end

    it "should execute :add" do
      evaluate [[:add, 1, 9]]
      @vm.registers[1].should == 10
    end

    it "should execute :sub" do
      evaluate [[:sub, 1, 9]]
      @vm.registers[1].should == -8
    end

    it "should execute :mul" do
      evaluate [[:mul, 2, 9]]
      @vm.registers[2].should == 18
    end

    it "should execute :div" do
      evaluate [[:div, 8, 2]]
      @vm.registers[8].should == 4
      @vm.registers[8].should be_instance_of(Float)
    end

    it "should execute :mod" do
      evaluate [[:mod, 8, 3]]
      @vm.registers[8].should == 2
      @vm.registers[8].should be_kind_of(Integer)
    end

    it "should execute :mod (when Float is expected)" do
      evaluate [[:div, 1, 2], [:mod, 1, 3]]
      @vm.registers[1].should == 0.5
    end

    it "should execute :push" do
      evaluate [[:push, 1]]
      @vm.stack.should == [1]
    end

    it "should execute :pop" do
      evaluate [[:push, 1], [:pop, 2]]
      @vm.registers[2].should == 1
    end

    it "should execute :putc" do
      @out = mock($stdout)
      @out.should_receive(:print).with("a")
      evaluate [[:add, 5, 5], [:mul, 5, 5], [:sub, 5, 3],
                [:putc, 5]]
    end

    if defined?(Encoding)
      it "should execute :putc with kanji" do
        @out = mock($stdout)
        @out.should_receive(:print).with("✐")
        evaluate [[:add, 5, 5], [:mul, 5, 5], [:mul, 5, 5],
                  [:putc, 5]]
      end
    end

    it "should execute :putn" do
      @out = mock($stdout)
      @out.should_receive(:print).with("100")
      evaluate [[:add, 5, 5], [:mul, 5, 5],
                [:putn, 5]]
    end

    it "should execute :jump_if" do
      evaluate [[:jump_if, 1, 1], [:mov, 2, 3], [:label, 1]]
      @vm.registers[2].should == 2
    end

    it "should execute :jump_if, but should not jump if false(0)" do
      evaluate [[:sub, 9, 9],
                [:jump_if, 9, 1], [:mov, 2, 3], [:label, 1]]
      @vm.registers[2].should == 3
    end

    it "should execute :jump_ifp" do
      evaluate [[:jump_if, 1, 1], [:mov, 2, 3], [:label, 1]]
      @vm.registers[2].should == 2
    end

    it "should execute :jump_if, but should not jump if false(0)" do
      evaluate [[:sub, 8, 9],
                [:jump_ifp, 8, 1], [:mov, 2, 3], [:label, 1]]
      @vm.registers[2].should == 3
    end
  end
end
