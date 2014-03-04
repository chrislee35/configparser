unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative 'helper'

class TestConfigparser < Test::Unit::TestCase
	def test_parse_a_simple_config
		cp = ConfigParser.new('test/simple.cfg')
		assert_not_nil(cp)
		assert_equal('hi',cp['test1'])
		assert_equal('hello',cp['test2'])
		assert_equal('55',cp['first_section']['mytest'])
		assert_equal('99',cp['first_section']['yourtest'])
		assert_nil(cp['first_section']['nothere'])
		assert_equal('or the highway',cp['second section']['myway'])
	end
	
	def test_convert_a_simple_config_to_a_string
		cp = ConfigParser.new('test/simple.cfg')
		doc = "test1: hi
test2: hello
[first_section]
myboolean
mytest: 55
yourtest: 99
[second section]
myway: or the highway
"
		assert_equal(doc,cp.to_s)
	end
	
	def test_parse_a_config_with_substitutions
		cp = ConfigParser.new('test/complex.cfg')
		assert_not_nil(cp)
		assert_equal('strange-default-whatever',cp['global2'])
		assert_equal('strange-default-whatever-yodel-local',cp['section1']['local1'])
		assert_equal('recent hotel',cp['section2']['local2'])
		assert_equal('un$(resolvable)',cp['section2']['local3'])
	end
  
  def test_parse_from_non_file
    simple_content = <<end_of_simple
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
end_of_simple
 
    cp = ConfigParser.new()
    cp.parse(simple_content.each_line)
		assert_equal(cp, { 
      "test1" => "hi",
      "test2" => "hello", 
      "first_section" => {
        "mytest" => "55", 
        "yourtest" => "99",
        "myboolean" => true
		  },
      "second section" => {
        "myway" => "or the highway"
      }})
  end
end
