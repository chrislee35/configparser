unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative 'helper'

class TestConfigparser < Minitest::Test
	def test_parse_a_simple_config
		cp = ConfigParser.new('test/simple.cfg')
		refute_nil(cp)
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
		assert_equal(doc, cp.to_s)
	end
	
	def test_parse_a_config_with_substitutions
		cp = ConfigParser.new('test/complex.cfg')
		refute_nil(cp)
		assert_equal('strange-default-whatever',cp['global2'])
		assert_equal('strange-default-whatever-yodel-local',cp['section1']['local1'])
		assert_equal('recent hotel',cp['section2']['local2'])
		assert_equal('un$(resolvable)',cp['section2']['local3'])
	end
  
  def test_parse_a_config_with_indents
    cp = ConfigParser.new('test/smb.cfg')
    refute_nil(cp)
    assert_equal("WORKGROUP", cp['global']["workgroup"])
    assert_equal("%h server (Samba, Ubuntu)", cp['global']["server string"])
    assert_equal("no", cp['global']["dns proxy"])
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
		assert_equal({ 
      "test1" => "hi",
      "test2" => "hello", 
      "first_section" => {
        "mytest" => "55", 
        "yourtest" => "99",
        "myboolean" => true
		  },
      "second section" => {
        "myway" => "or the highway"
      }}, cp)
  end

	def test_parse_configparser_example_from_python
		cp = ConfigParser.new('test/configparser_example.cfg')
		refute_nil(cp)
    doc = "[All Values Are Strings]
are they treated as numbers?: no
can use the API to get converted values directly: true
integers, floats and booleans are held as: strings
or this: 3.14159265359
values like this: 1000000
[Multiline Values]
chorus: I'm a lumberjack, and I'm okay I sleep all night and I work all day
[No Values]
empty string value here:
key_without_value
[Sections Can Be Indented]
can_values_be_as_well: True
does_that_mean_anything_special: False
multiline_values: are handled just fine as long as they are indented deeper than the first line of a value
purpose: formatting for readability
[Simple Values]
key: value
spaces around the delimiter: obviously
spaces in keys: allowed
spaces in values: allowed as well
you can also use: to delimit keys from values
[You can use comments]
"
    
    assert_equal(doc, cp.to_s)
	end
  
  def test_nil_option
    nil_content = <<end_of_simple
[some_section]
foo=
end_of_simple
    cp = ConfigParser.new()
    cp.parse(nil_content.each_line)
    assert_equal({ 
      "some_section" => {
        "foo" => ""
      }}, cp)
    assert_equal(nil_content, cp.to_s("="))
  end
  
  def test_from_python_cfgparser
    content = <<end_of_python_example
[Foo Bar]
foo=bar
[Spacey Bar]
foo = bar
[Commented Bar]
foo: bar ; comment
[Long Line]
foo: this line is much, much longer than my editor
   likes it.
[Section\\with$weird%characters[\t]
[Internationalized Stuff]
foo[bg]: Bulgarian
foo=Default
foo[en]=English
foo[de]=Deutsch
[Spaces]
key with spaces : value
another with spaces = splat!
end_of_python_example
    cp = ConfigParser.new()
    cp.parse(content.each_line)
    doc = "[Commented Bar]
foo: bar ; comment
[Foo Bar]
foo: bar
[Internationalized Stuff]
foo: Default
foo[bg]: Bulgarian
foo[de]: Deutsch
foo[en]: English
[Long Line]
foo: this line is much, much longer than my editor likes it.
[Section\\with$weird%characters[\t]
[Spaces]
another with spaces: splat!
key with spaces: value
[Spacey Bar]
foo: bar
"
    assert_equal(doc, cp.to_s)
  end
end
