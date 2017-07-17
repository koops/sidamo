require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Sidamo do
  it "should evaluate coffeescript" do
    subject.eval("if true then 'yes' else 'no'").should == 'yes'
  end

  it "should eval javascript" do
    subject.eval_js("f = function(){ return 3;}; f()").should == 3
  end

  it "should remember values across evaluations" do
    subject.eval('a = 3')
    subject.eval('a').should == 3
  end

  it "should run js and always return nil" do
    subject.run("{a: 1}").should be_nil
  end

  it "should compile coffeescript" do
    Sidamo.compile("->", :bare => true).strip.should == "(function() {});"
  end

  it "should load js files" do
    subject.load fixture('doubler.js')
    subject.eval('double 2').should == 4
  end

  it "should load coffee files" do
    subject.load Pathname.new(fixture('tripler.coffee'))
    subject.eval('triple 2').should == 6
  end

  it "should keep the coffeescript compiler separate" do
    subject.eval_js('typeof CoffeeScript').should == 'undefined'
  end

  it "should provide compile?" do
    Sidamo.compile?("->").should be_truthy
    Sidamo.compile?("->>").should be_falsy
  end

  it "should syntax check javascript" do
    Sidamo.compile_js?("1 + 1").should be_truthy
    Sidamo.compile_js?("1 + function").should be_falsy
    Sidamo.compile_js?("function zed(){}").should be_truthy
    Sidamo.compile_js?("ka.blooey()").should be_truthy # not executing
  end

  it "should load snapshots" do
    snapshot = Sidamo.snapshot(Pathname.new(fixture('snapshot')))
    s = Sidamo.new snapshot: snapshot
    s.eval('double 2').should == 4
    s.eval('triple 2').should == 6
  end

  it "should dispose of its context when asked" do
    subject.dispose
    expect { subject.eval('1 + 1') }.to raise_exception(MiniRacer::ContextDisposedError)
  end
  
  # it "should give statistics" do
  #   s = Sidamo.new
  #   s.eval('1 + 1')
  #   s.used_heap_size.should > 0
  #   s.total_physical_size.should > 0
  # end

  # it "should take hints about when to collect garbage" do
  #   s = Sidamo.new({young_space_mb: 8})

  #   s.eval_js('for(var i = 0; i < 10000; i++){new String("bozo")}')
  #   before = s.used_heap_size
  #   s.collect_some_garbage
  #   s.used_heap_size.should < before
  # end
end
