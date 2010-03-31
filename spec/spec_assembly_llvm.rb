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

    it "calculates 9 * 8 / 2 and putc it" do
      run_by_llvm([[:mul, 9, 8], [:div, 9, 2], [:putc, 9, 0]]).should == "$"
    end

    it "calculates 9 * 8 mod 8 * 5 and putc it" do
      run_by_llvm([[:mul, 9, 8], [:mul, 8, 5], [:mod, 9, 8], [:putc, 9, 0]]).should == " "
    end

    context ':jump_if' do
      it "print 'H' and '8'" do
        run_by_llvm([[:mul, 9, 8], [:putc, 9, 0], [:sub, 3, 3], [:jump_if, 3, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3]]).should == "H8"
      end

      it "print 'H' and skip '8'" do
        run_by_llvm([[:mul, 9, 8], [:putc, 9, 0], [:jump_if, 9, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3]]).should == "H"
      end

      it "skip '8' and print 'H'" do
        run_by_llvm([[:jump_if, 9, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3], [:mul, 9, 8], [:putc, 9, 0]]).should == "H"
      end
    end

    context ':jump_ifp' do
      it "print 'H' and skip '8'" do
        # jump_ifp 1
        run_by_llvm([[:mul, 9, 8], [:putc, 9, 0], [:sub, 4, 3], [:jump_ifp, 4, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3]]).should == "H"
      end

      it "print 'H' and skip '8'" do
        # jump_ifp 0
        run_by_llvm([[:mul, 9, 8], [:putc, 9, 0], [:sub, 3, 3], [:jump_ifp, 3, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3]]).should == "H"
      end

      it "print 'H' and '8'" do
        # jump_ifp -1
        run_by_llvm([[:mul, 9, 8], [:putc, 9, 0], [:sub, 3, 4], [:jump_ifp, 3, 3], [:mul, 8, 7], [:putc, 8, 0], [:label, 3]]).should == "H8"
      end
    end

    context ':push and :pop' do
      it "print 'FGH'" do
        run_by_llvm([
          [:mul, 9, 8], [:push, 9, 0],
          [:sub, 9, 1], [:push, 9, 0],
          [:sub, 9, 1], [:push, 9, 0],
          [:pop, 8, 0], [:putc, 8, 0],
          [:pop, 8, 0], [:putc, 8, 0],
          [:pop, 8, 0], [:putc, 8, 0]
        ]).should == "FGH"
      end
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
        should match(/@main/)
    end
  end

  context '.footer' do
    before do
      @footer_method =
        ShogiModan::Assembly::LLVM.method(:footer)
    end
    it 'is the LLVM Assembly code which does preparation such as' <<
    'initializing ShogiModan registers' do
      @footer_method.call([]).should be_instance_of(String)
    end
  end
end
