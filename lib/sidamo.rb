require 'mini_racer'
require 'json'

class Sidamo
  attr_accessor :included_sources

  def self.snapshot(catalog)
    MiniRacer::Snapshot.new catalog_files(catalog).map{|f| File.read(js_source(f))}.join("\n")
  end

  def initialize(opts={})
    @included_sources = []

    @v8 = MiniRacer::Context.new(opts)
    load File.join(File.dirname(__FILE__), '..', 'src', 'coffee-script.js')
  end

  def load(path)
    @v8.load path
  end

  def catalog_files(catalog)
    File.readlines(catalog).map(&:strip).reject(&:blank?).map{|file| File.join(File.dirname(catalog), file)}
  end

  def js_source(source)
    if File.extname(source) == '.coffee'
      js_path = File.join(File.dirname(source), File.basename(source, '.coffee') + ".js")
      compile_source(source, js_path) unless File.exist?(js_path) && File.ctime(js_path) > File.ctime(source)
      js_path
    else
      source
    end
  end

  def bootstrap(catalog)
    catalog_files(catalog).each{|source| include(source)}
  end

  def include(source)
    if @included_sources.include? source
      false
    else
      load js_source(source)
      @included_sources.push source
      return true
    end
  end

  def compile_source(coffee_path, js_path)
    js = File.open(coffee_path){|f| compile(f.read, bare: true)}
    File.write(js_path, js)
  end

  def attach(name, proc)
    @v8.attach name, proc
  end

  def eval(coffee)
    eval_js compile(coffee, bare: true)
  end

  def run(coffee)
    run_js compile(coffee, bare: true)
  end

  def eval_js(js)
    @v8.eval(js)
  end

  # avoid returning un-needed objects
  def run_js(js)
    @v8.eval("#{js}; null")
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
