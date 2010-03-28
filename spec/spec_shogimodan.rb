# coding: utf-8
require "#{File.expand_path File.dirname __FILE__}/spec_helper.rb"

describe "ShogiModan" do
  context ".new" do
    it "should accept a string as soruce program" do
      processor = ShogiModan.new("")
      processor.should be_instance_of(ShogiModan)
    end
  end

  context "#run" do
    it "should run a program" do
      buf = ""
      out = stub($stdout)
      out.stub(:print){|c| buf << c}

      src = File.read((File.expand_path File.dirname __FILE__) +
                      "/../examples/hello.modan")
      ShogiModan.new(src, $stdin, out).run
      buf.should == "Hello, world!"
    end
  end
end

