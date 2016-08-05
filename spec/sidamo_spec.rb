require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Sidamo do
  it "should evaluate coffeescript" do
    subject.eval("if true then 'yes' else 'no'").should == 'yes'
  end

  it "should compile coffeescript" do
    subject.compile("->", :bare => true).strip.should == "(function() {});"
  end

  it "should provide compile?" do
    subject.compile?("->").should be_truthy
    subject.compile?("->>").should be_falsy
  end

  it "should work at the class level" do
    Sidamo.eval("((x) -> x * x)(2)").should == 4
    Sidamo.evaluate("((x) -> x * x)(3)").should == 9
    Sidamo.compile("->", :bare => true).strip.should == "(function() {});"
    Sidamo.compile?('->').should be_truthy
  end

  it "should remember values across evaluations" do
    subject.eval('a = 3')
    subject.eval('a').should == 3
  end

  it "should run js and always return nil" do
    subject.run("{a: 1}").should be_nil
  end

  it "should load js files" do
    subject.load fixture('doubler.js')
    subject.eval('double 2').should == 4
  end
  
  it "should include coffee files" do
    s = Sidamo.new
    s.include Pathname.new(fixture('tripler.coffee'))
    s.eval('triple 2').should == 6
  end
  
  it 'should include files only once' do
    s = Sidamo.new
    s.include(Pathname.new(fixture('tripler.coffee'))).should be_truthy
    s.included_sources.length.should == 1
    
    s.include(Pathname.new(fixture('tripler.coffee'))).should be_falsy
    s.included_sources.length.should == 1
  end

  it "should include js files" do
    s = Sidamo.new
    s.include Pathname.new(fixture('doubler.js'))
    s.eval('double 2').should == 4
  end
  
  # it "should allow includes from within js" do
  #   s = Sidamo.new({}, Pathname.new(fixture('tripler.coffee')).dirname)
  #   s.eval_js("include('tripler'); triple(4)").should == 12
  # end

  it "should eval javascript" do
    subject.eval_js("f = function(){ return 3;}; f()").should == 3
  end

  it "should syntax check javascript" do
    subject.compile_js?("1 + 1").should be_truthy
    subject.compile_js?("1 + function").should be_falsy
    subject.compile_js?("function zed(){}").should be_truthy
    subject.compile_js?("ka.blooey()").should be_truthy # not executing
  end

  # it "should dispose of its context when asked" do
  #   subject.dispose
  # end
  
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
