require 'mini_racer'
require 'json'

class Sidamo
  def initialize(opts={})
    @v8 = MiniRacer::Context.new(opts)
  end

  def load(path)
    @v8.load Sidamo.js_path(path)
  end

  def attach(name, proc)
    @v8.attach name, proc
  end

  def eval(coffee)
    eval_js Sidamo.compile(coffee, bare: true)
  end

  def eval_js(js)
    @v8.eval(js)
  end

  def run(coffee)
    run_js Sidamo.compile(coffee, bare: true)
  end

  def run_js(js)
    @v8.eval("#{js}; null") # avoid returning un-needed objects
  end

  alias_method :evaluate, :eval

  def bootstrap(catalog)
    Sidamo.catalog_files(catalog).each{|path| load(path)}
  end

  def self.compile(coffee, options={})
    compiler.eval("CoffeeScript.compile(#{JSON.dump(coffee)}, #{JSON.dump(options)})")
  end

  # Common, separate compiler v8 instance.
  def self.compiler
    @compilerV8 ||= MiniRacer::Context.new.tap do |v8|
      v8.load File.join(File.dirname(__FILE__), '..', 'src', 'coffee-script.js')
    end
  end

  def self.compile?(coffee)
    begin
      compile(coffee)
    rescue MiniRacer::RuntimeError
      return false
    end
    true
  end

  # Syntax check
  def self.compile_js?(js)
    begin
      compiler.eval("new Function(#{JSON.dump(js)})")
    rescue MiniRacer::RuntimeError
      return false
    end
    true
  end

  def self.js_path(path)
    if File.extname(path) == '.coffee'
      js_path = File.join(File.dirname(path), File.basename(path, '.coffee') + ".js")
      compile_source(path, js_path) unless File.exist?(js_path) && File.ctime(js_path) > File.ctime(path)
      js_path
    else
      path
    end
  end

  def self.compile_source(coffee_path, js_path)
    js = File.open(coffee_path){|f| compile(f.read, bare: true)}
    File.write(js_path, js)
  end

  def self.snapshot(catalog)
    MiniRacer::Snapshot.new catalog_files(catalog).map{|f| File.read(js_path(f))}.join("\n")
  end

  def self.catalog_files(catalog)
    File.readlines(catalog).map(&:strip).reject(&:empty?).map{|file| File.join(File.dirname(catalog), file)}
  end
end
