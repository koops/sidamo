# sidamo

A CoffeeScript-centric wrapper around Ruby's [therubyracer](http://github.com/cowboyd/therubyracer).

## Synopsis

    $ gem install sidamo
    $ irb
    >> require 'sidamo'
    >> sid = Sidamo.new
    >> sid.eval('if true then yes else no') 
    => true

## Features

* Include JavaScript or CoffeeScript sources into your environment.
* Evaluate JavaScript or CoffeeScript.
* Check and influence v8 memory usage.

## Copyright

Copyright (c) 2015 Ryan Koopmans. See LICENSE.txt for details.

