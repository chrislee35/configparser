# Configparser

Configparser parses configuration files compatible with Python's ConfigParser

## Installation

Add this line to your application's Gemfile:

    gem 'configparser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configparser

## Usage

	$ cat test/simple.cfg
		test1=hi
		test2 = hello

		[first_section]
		mytest=55
		yourtest     =     99
		#nothere=notthere
		myboolean

		[second section]
		myway=or the
		  highway
	
	require 'configparser'
	cp = ConfigParser.new('test/simple.cfg')
	puts cp.to_s
	
		test1: hi
		test2: hello
		[first_section]
		myboolean
		mytest: 55
		yourtest: 99
		[second section]
		myway: or the highway
		
	$ cat test/complex.cfg
		global1=default-$(global3)
		global2=strange-$(global1)
		global3=whatever

		[section1]
		local1=$(global2)-$(local2)-local
		local2=yodel

		[section2]
		local1=hotel
		local2=recent $(local1)
		local3=un$(resolvable)
	
	cp = ConfigParser.new('test/complex.cfg')
	puts cp['global2']
	puts cp['section1']['local1']
	puts cp['section2']['local2']
	puts cp['section2']['local3']
	
		strange-default-whatever
		strange-default-whatever-yodel-local
		recent hotel
		un$(resolvable)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
