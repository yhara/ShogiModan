# coding: utf-8
require "#{File.expand_path File.dirname __FILE__}/spec_helper.rb"

describe "ShogiModan::Encoder" do
  context ".new" do
    it "should accept a string as soruce program" do
      encoder = ShogiModan::Encoder.new("")
      encoder.should be_instance_of(ShogiModan::Encoder)
    end
  end

  context "#encode" do
    it "should encode a program" do
      encoder = ShogiModan::Encoder.new([
        [:add, 1, 2], [:label, 3], [:putc, 4]
      ])
      encoder.encode.should == "▲１二歩 *3 △４_玉"
    end
  end
end

#encoder = ShogiModan::Encoder.new [
#  [:mul, 9, 8],  #9: 72
#  [:putc, 9],   
#  [:add, 6, 4],  #6: 10
#  [:mul, 6, 6],  
#  [:add, 6, 1],  #   101
#  [:putc, 6],
#  [:add, 6, 7],  #   108
#  [:putc, 6],
#  [:putc, 6],
#  [:add, 6, 3],  #   111
#  [:putc, 6],
#  [:mul, 7, 7],  #7: 49
#  [:sub, 7, 5],  #   44
#  [:putc, 7],
#  [:mul, 4, 8],  #4: 32
#  [:putc, 4],
#  [:mov, 9, 6],  #9: 111
#  [:add, 9, 8],  #   119
#  [:putc, 9],
#  [:putc, 6],
#  [:sub, 9, 5],  #   114
#  [:putc, 9],
#  [:sub, 6, 3],  #6: 108
#  [:putc, 6],
#  [:sub, 6, 8],  #   100
#  [:putc, 6],
#  [:add, 4, 1],
#  [:putc, 4]
#]
#puts encoder.encode
