require 'mini_racer'
require 'json'

class Sidamo
  attr_accessor :load_paths, :included_sources
  
  def initialize(opts={})
    @included_sources = []

    @v8 = MiniRacer::Context.new(opts)
    load File.join(File.dirname(__FILE__), '..', 'src', 'coffee-script.js')
  end

  def load(path)
    @v8.load path
  end

  def bootstrap(filename)
    files = File.readlines(filename).map(&:strip).reject(&:blank?).map{|file| File.join(File.dirname(filename), file)}
    files.each{|file| include(file)}
  end
  
  def include(source)
    return false if @included_sources.include? source

    if File.extname(source) == '.coffee'
      js_path = File.join File.dirname(source), File.basename(source, '.coffee') + ".js"
      if File.exist?(js_path) && File.ctime(js_path) > File.ctime(source)
        load js_path
      else
        load compile_source(source, js_path)
      end
    else
      load source
    end

    @included_sources.push source
    return true
  end

  def compile_source(coffee_path, js_path)
    js = File.open(coffee_path){|f| compile(f.read, bare: true)}
    File.write(js_path, js)
    return js_path
  end

  def eval(coffee)
    @v8.eval compile(coffee, bare: true)
  end

  def eval_js(js)
    @v8.eval(js)
  end

  alias_method :evaluate, :eval

  def compile(coffee, options={})
    @v8.eval("CoffeeScript.compile(#{JSON.dump(coffee)}, #{JSON.dump(options)})")
  end

  def compile?(coffee)
    begin
      compile(coffee)
    rescue MiniRacer::RuntimeError
      return false
    end
    true
  end

  # Syntax check
  def compile_js?(js)
    begin
      @v8.eval("new Function(#{JSON.dump(js)})")
    rescue MiniRacer::RuntimeError
      return false
    end
    true
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
end
