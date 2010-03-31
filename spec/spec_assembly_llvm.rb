require "#{File.expand_path File.dirname __FILE__}/spec_helper.rb"
require 'tempfile'

def run_by_llvm(iseqs)
  tfile = Tempfile.new('a').path
  File.open(tfile, 'w') {|io|
    io.write ShogiModan::Assembly::LLVM.convert(iseqs)
  }
  `llvm-as #{tfile} -o - | lli`
end

describe 'ShogiModan::Assembly::LLVM' do
  context '.convert' do
    before :each do
      @iseqs = [[:mul, 9, 8], [:putc, 9, 2],
        [:add, 6, 4], [:mul, 6, 6], [:add, 6, 1],
        [:putc, 6, 1], [:add, 6, 7], [:putc, 6, 1],
        [:putc, 6, 8], [:add, 6, 3], [:putc, 6, 9],
        [:mul, 7, 7], [:sub, 7, 5], [:putc, 7, 1],
        [:mul, 4, 8], [:putc, 4, 2], [:mov, 9, 6],
        [:add, 9, 8], [:putc, 9, 8], [:putc, 6, 7],
        [:sub, 9, 5], [:putc, 9, 1], [:sub, 6, 3],
        [:putc, 6, 3], [:sub, 6, 8], [:putc, 6, 2],
        [:add, 4, 1], [:putc, 4, 3], [:add, 5, 5], [:putc, 5, 3]]
    end

    it 'accepts an array as VM codes, ' <<
    'and returns a string representation of LLVM assembly code' do
      ShogiModan::Assembly::LLVM.convert([]).
        should be_instance_of(String)
    end

    it 'converts the helloworld VM codes' <<
    'to the corresponding LLVM assembly code' do
      ShogiModan::Assembly::LLVM.convert(@iseqs).
        should match(/def/)
    end

    it "'s generating code is actually runnable on LLVM" do
      run_by_llvm(@iseqs.take(2)).should == 'H'
      run_by_llvm(@iseqs).should == "Hello, world!\n"

    end
  end

  context '.body' do
    it 'is private' do
      lambda {
        ShogiModan::Assembly::LLVM.body([])
      }.should raise_error(NoMethodError)
    end

    before do
      @body_method =
        ShogiModan::Assembly::LLVM.method(:body)
    end

    it 'is [(Symbol, a, a)] -> String' do
      @body_method.call([]).
        should be_an_instance_of(String)

      @body_method.call([[:add, 1, 2]]).
        should be_an_instance_of(String)

      lambda {
        @body_method.call(:hey)
      }.should raise_error
    end

    it 'converts [:add, 1, 2] to the LLVM code represents the addition' do
      @body_method.call([[:add, 1, 2]]).
        should match(/add/)
    end
  end

  context '::HEADER' do
    it 'is the LLVM Assembly code which does preparation such as' <<
    'initializing ShogiModan registers' do
      ShogiModan::Assembly::LLVM::HEADER.split(/\n/).join.
        should match(/%r = alloca \[9 x double\]/)
    end
  end

  context '::FOOTER' do
    it 'is the LLVM Assembly code which does preparation such as' <<
    'initializing ShogiModan registers' do
      ShogiModan::Assembly::LLVM::FOOTER.should be_instance_of(String)
    end
  end
end
