require 'mini_racer'

class Sidamo
  attr_accessor :load_paths, :included_sources
  
  def initialize(v8Opts={}, *paths)
    path_strings = [File.join(File.dirname(__FILE__), '..', 'src'), paths].flatten 
    @load_paths = path_strings.map{|s| Pathname.new(s)}.select(&:exist?).select(&:directory?)
    @included_sources = []

    @v8 = MiniRacer::Context.new
    @v8.attach 'include', proc{|source| include(source)}
    
    include 'coffee-script'    
  end

  def load(path)
    @v8.load path
  end
  
  def compile_source(coffee_path)
    js = File.open(coffee_path){|f| compile(f.read, bare: true)}
    js_path = Pathname.new(coffee_path.dirname + (coffee_path.basename(".coffee").to_s + '.js'))

    File.write(js_path, js)
    return js_path
  end
  
  def include(source)
    return false if @included_sources.include? source
    files = find_files(source) or raise "Source #{source} not found in #{@load_paths.join(', ')}."
    
    coffee = files.find{|f| f.extname == '.coffee'}
    js = files.find{|f| f.extname == '.js'}

    if coffee && js
      if coffee.ctime > js.ctime
        load compile_source(coffee)
      else
        load js
      end
    elsif coffee
      load compile_source(coffee)
    else
      load js
    end
    
    @included_sources.push source
    return true
  end
  
  def find_files(source)
    @load_paths.each do |path|
      Dir.chdir(path) do
        files = Dir["#{source}.{js,coffee}"]
        return files.map{|f| path + f} unless files.empty?
      end
    end
    nil
  end

  def eval(coffee)
    @v8.eval(@v8.eval('CoffeeScript.compile').call(coffee, :bare => true))
  end

  def eval_js(js)
    @v8.eval(js)
  end

  alias_method :evaluate, :eval

  def compile(coffee, options = {})
    call 'CoffeeScript.compile', coffee, options
  end

  def compile?(coffee)
    begin
      compile(coffee)
    rescue ::V8::JSError => x
      return false
    end
    true
  end

  # Syntax check
  def compile_js?(js)
    begin
      @v8['_code'] = js
      @v8.eval('new Function(_code)')
    rescue ::V8::JSError => x
      return false
    end
    true
  end  

  def collect_some_garbage
    V8::C::V8::IdleNotification()
  end
  
  def dispose
    @v8.dispose
  end

  def self.eval(coffee)
    new.eval(coffee)
  end

  def self.evaluate(coffee)
    new.eval(coffee)
  end

  def self.compile(coffee, options = {})
    new.compile(coffee, options)
  end

  def self.compile?(coffee)
    new.compile?(coffee)
  end

  def self.compile_js?(js)
    new.compile_js?(js)
  end

  protected ########################################

  def call(properties, *args)
    @v8.eval(properties).call(*args)
  end
  
  def lock
    yield
    return
    result, exception = nil, nil
    V8::C::Locker() do
      begin
        result = yield
      rescue Exception => e
        exception = e
      end
    end

    if exception
      raise exception
    else
      result
    end
  end  
end
