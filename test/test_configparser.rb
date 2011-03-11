require 'helper'

class TestConfigparser < Test::Unit::TestCase
	should "parse a simple config" do
		cp = ConfigParser.new('test/simple.cfg')
		assert_not_nil(cp)
		assert_equal('hi',cp['test1'])
		assert_equal('hello',cp['test2'])
		assert_equal('55',cp['first_section']['mytest'])
		assert_equal('99',cp['first_section']['yourtest'])
		assert_nil(cp['first_section']['nothere'])
		assert_equal('or the highway',cp['second section']['myway'])
	end
	
	should "convert a simple config to a string" do
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
	
	should "parse a config with substitutions" do
		cp = ConfigParser.new('test/complex.cfg')
		assert_not_nil(cp)
		assert_equal('strange-default-whatever',cp['global2'])
		assert_equal('strange-default-whatever-yodel-local',cp['section1']['local1'])
		assert_equal('recent hotel',cp['section2']['local2'])
		assert_equal('un$(resolvable)',cp['section2']['local3'])
	end
end
