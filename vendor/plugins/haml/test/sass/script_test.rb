#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require 'sass/engine'

module Sass::Script::Functions::UserFunctions
  def assert_options(val)
    val.options[:foo]
    Sass::Script::String.new("Options defined!")
  end
end

class SassScriptTest < Test::Unit::TestCase
  include Sass::Script

  def test_color_checks_input
    assert_raise(Sass::SyntaxError, "Color values must be between 0 and 255") {Color.new([1, 2, -1])}
    assert_raise(Sass::SyntaxError, "Color values must be between 0 and 255") {Color.new([256, 2, 3])}
  end

  def test_color_checks_rgba_input
    assert_raise(Sass::SyntaxError, "Alpha channel must be between 0 and 1") {Color.new([1, 2, 3, 1.1])}
    assert_raise(Sass::SyntaxError, "Alpha channel must be between 0 and 1") {Color.new([1, 2, 3, -0.1])}
  end

  def test_string_escapes
    assert_equal "'", resolve("\"'\"")
    assert_equal '"', resolve("\"\\\"\"")
    assert_equal "\\", resolve("\"\\\\\"")
    assert_equal "\\02fa", resolve("\"\\02fa\"")

    assert_equal "'", resolve("'\\''")
    assert_equal '"', resolve("'\"'")
    assert_equal "\\", resolve("'\\\\'")
    assert_equal "\\02fa", resolve("'\\02fa'")
  end

  def test_string_interpolation
    assert_equal "foo2bar", resolve('\'foo#{1 + 1}bar\'')
    assert_equal "foo2bar", resolve('"foo#{1 + 1}bar"')
    assert_equal "foo1bar5baz4bang", resolve('\'foo#{1 + "bar#{2 + 3}baz" + 4}bang\'')
  end

  def test_color_names
    assert_equal "white", resolve("white")
    assert_equal "white", resolve("#ffffff")
    assert_equal "#fffffe", resolve("white - #000001")
  end

  def test_rgba_color_literals
    assert_equal Sass::Script::Color.new([1, 2, 3, 0.75]), eval("rgba(1, 2, 3, 0.75)")
    assert_equal "rgba(1, 2, 3, 0.75)", resolve("rgba(1, 2, 3, 0.75)")

    assert_equal Sass::Script::Color.new([1, 2, 3, 0]), eval("rgba(1, 2, 3, 0)")
    assert_equal "rgba(1, 2, 3, 0)", resolve("rgba(1, 2, 3, 0)")

    assert_equal Sass::Script::Color.new([1, 2, 3]), eval("rgba(1, 2, 3, 1)")
    assert_equal Sass::Script::Color.new([1, 2, 3, 1]), eval("rgba(1, 2, 3, 1)")
    assert_equal "#010203", resolve("rgba(1, 2, 3, 1)")
    assert_equal "white", resolve("rgba(255, 255, 255, 1)")
  end

  def test_rgba_color_math
    assert_equal "rgba(50, 50, 100, 0.35)", resolve("rgba(1, 1, 2, 0.35) * rgba(50, 50, 50, 0.35)")
    assert_equal "rgba(52, 52, 52, 0.25)", resolve("rgba(2, 2, 2, 0.25) + rgba(50, 50, 50, 0.25)")

    assert_raise(Sass::SyntaxError, "Alpha channels must be equal: rgba(1, 2, 3, 0.15) + rgba(50, 50, 50, 0.75)") do
      resolve("rgba(1, 2, 3, 0.15) + rgba(50, 50, 50, 0.75)")
    end
    assert_raise(Sass::SyntaxError, "Alpha channels must be equal: #123456 * rgba(50, 50, 50, 0.75)") do
      resolve("#123456 * rgba(50, 50, 50, 0.75)")
    end
    assert_raise(Sass::SyntaxError, "Alpha channels must be equal: #123456 / #123456") do
      resolve("rgba(50, 50, 50, 0.75) / #123456")
    end
  end

  def test_rgba_number_math
    assert_equal "rgba(49, 49, 49, 0.75)", resolve("rgba(50, 50, 50, 0.75) - 1")
    assert_equal "rgba(100, 100, 100, 0.75)", resolve("rgba(50, 50, 50, 0.75) * 2")
  end

  def test_compressed_colors
    assert_equal "#123456", resolve("#123456", :style => :compressed)
    assert_equal "rgba(1, 2, 3, 0.5)", resolve("rgba(1, 2, 3, 0.5)", :style => :compressed)
    assert_equal "#123", resolve("#112233", :style => :compressed)
    assert_equal "#000", resolve("black", :style => :compressed)
    assert_equal "red", resolve("#f00", :style => :compressed)
    assert_equal "blue", resolve("#00f", :style => :compressed)
    assert_equal "navy", resolve("#000080", :style => :compressed)
    assert_equal "navy #fff", resolve("#000080 white", :style => :compressed)
    assert_equal "This color is #fff", resolve('"This color is #{ white }"', :style => :compressed)
  end

  def test_implicit_strings
    silence_warnings do
      assert_equal Sass::Script::String.new("foo"), eval("foo")
      assert_equal Sass::Script::String.new("foo bar"), eval("foo bar")
      assert_equal Sass::Script::String.new("foo/bar"), eval("foo/bar")
    end
  end

  def test_interpolation
    assert_equal "foo bar, baz bang", resolve('"foo #{"bar"}, #{"baz"} bang"')
    assert_equal "foo bar baz bang", resolve('"foo #{"#{"ba" + "r"} baz"} bang"')
    assert_equal 'foo #{bar baz} bang', resolve('"foo \#{#{"ba" + "r"} baz} bang"')
    assert_equal 'foo #{baz bang', resolve('"foo #{"\#{" + "baz"} bang"')
  end

  def test_rule_interpolation
    assert_equal(<<CSS, render(<<SASS))
foo bar baz bang {
  a: b; }
CSS
foo \#{"\#{"ba" + "r"} baz"} bang
  a: b
SASS
    assert_equal(<<CSS, render(<<SASS))
foo \#{bar baz} bang {
  a: b; }
CSS
foo \\\#{\#{"ba" + "r"} baz} bang
  a: b
SASS
    assert_equal(<<CSS, render(<<SASS))
foo \#{baz bang {
  a: b; }
CSS
foo \#{"\\\#{" + "baz"} bang
  a: b
SASS
  end

  def test_implicit_string_warning
    assert_warning(<<WARN) {eval("foo")}
DEPRECATION WARNING:
On line 1, character 1 of 'test_implicit_string_warning_inline.sass'
Implicit strings have been deprecated and will be removed in version 2.4.
'foo' was not quoted. Please add double quotes (e.g. "foo").
WARN
    assert_warning(<<WARN) {eval("1 + foo")}
DEPRECATION WARNING:
On line 1, character 5 of 'test_implicit_string_warning_inline.sass'
Implicit strings have been deprecated and will be removed in version 2.4.
'foo' was not quoted. Please add double quotes (e.g. "foo").
WARN
    assert_warning(<<WARN) {render("@if 1 + foo")}
DEPRECATION WARNING:
On line 1, character 9 of 'test_implicit_string_warning_inline.sass'
Implicit strings have been deprecated and will be removed in version 2.4.
'foo' was not quoted. Please add double quotes (e.g. "foo").
WARN

    # Regression
    assert_warning(<<WARN) {render("@if if")}
DEPRECATION WARNING:
On line 1, character 5 of 'test_implicit_string_warning_inline.sass'
Implicit strings have been deprecated and will be removed in version 2.4.
'if' was not quoted. Please add double quotes (e.g. "if").
WARN
  end

  def test_inaccessible_functions
    assert_warning <<WARN do
DEPRECATION WARNING:
On line 2, character 6 of 'test_inaccessible_functions_inline.sass'
Implicit strings have been deprecated and will be removed in version 2.4.
'to_s' was not quoted. Please add double quotes (e.g. "to_s").
WARN
      assert_equal "send(to_s)", resolve("send(to_s)", :line => 2)
    end
    assert_equal "public_instance_methods()", resolve("public_instance_methods()")
  end

  def test_default_functions
    assert_equal "url(12)", resolve("url(12)")
    assert_equal 'blam(foo)', resolve('blam("foo")')
  end

  def test_function_results_have_options
    assert_equal "Options defined!", resolve("assert_options(abs(1))")
    assert_equal "Options defined!", resolve("assert_options(round(1.2))")
  end

  def test_hyphenated_variables
    assert_equal("a-b", resolve("!a-b", {}, env("a-b" => Sass::Script::String.new("a-b"))))
  end

  def test_ruby_equality
    assert_equal eval('"foo"'), eval('"foo"')
    assert_equal eval('1'), eval('1.0')
    assert_not_equal eval('1'), eval('"1"')
  end

  def test_booleans
    assert_equal "true", resolve("true")
    assert_equal "false", resolve("false")
  end

  def test_boolean_ops
    assert_equal "true", resolve("true and true")
    assert_equal "true", resolve("false or true")
    assert_equal "true", resolve("true or false")
    assert_equal "true", resolve("true or true")
    assert_equal "false", resolve("false or false")
    assert_equal "false", resolve("false and true")
    assert_equal "false", resolve("true and false")
    assert_equal "false", resolve("false and false")

    assert_equal "true", resolve("not false")
    assert_equal "false", resolve("not true")
    assert_equal "true", resolve("not not true")

    assert_equal "1", resolve("false or 1")
    assert_equal "false", resolve("false and 1")
    assert_equal "2", resolve("2 or 3")
    assert_equal "3", resolve("2 and 3")
  end

  def test_arithmetic_ops
    assert_equal "2", resolve("1 + 1")
    assert_equal "0", resolve("1 - 1")
    assert_equal "8", resolve("2 * 4")
    assert_equal "0.5", resolve("2 / 4")
    assert_equal "2", resolve("4 / 2")

    assert_equal "-1", resolve("-1")
  end

  def test_string_ops
    assert_equal "foo bar", resolve('"foo" "bar"')
    assert_equal "true 1", resolve('true 1')
    assert_equal "foo, bar", resolve("'foo' , 'bar'")
    assert_equal "true, 1", resolve('true , 1')
    assert_equal "foobar", resolve('"foo" + "bar"')
    assert_equal "true1", resolve('true + 1')
    assert_equal "foo-bar", resolve("'foo' - 'bar'")
    assert_equal "true-1", resolve('true - 1')
    assert_equal "foo/bar", resolve('"foo" / "bar"')
    assert_equal "true/1", resolve('true / 1')

    assert_equal "-bar", resolve("- 'bar'")
    assert_equal "-true", resolve('- true')
    assert_equal "/bar", resolve('/ "bar"')
    assert_equal "/true", resolve('/ true')
  end

  def test_relational_ops
    assert_equal "false", resolve("1 > 2")
    assert_equal "false", resolve("2 > 2")
    assert_equal "true", resolve("3 > 2")
    assert_equal "false", resolve("1 >= 2")
    assert_equal "true", resolve("2 >= 2")
    assert_equal "true", resolve("3 >= 2")
    assert_equal "true", resolve("1 < 2")
    assert_equal "false", resolve("2 < 2")
    assert_equal "false", resolve("3 < 2")
    assert_equal "true", resolve("1 <= 2")
    assert_equal "true", resolve("2 <= 2")
    assert_equal "false", resolve("3 <= 2")
  end

  def test_equals
    assert_equal("true", resolve('"foo" == !foo', {},
        env("foo" => Sass::Script::String.new("foo"))))
    assert_equal "true", resolve("1 == 1.0")
    assert_equal "true", resolve("false != true")
    assert_equal "false", resolve("1em == 1px")
    assert_equal "false", resolve("12 != 12")
  end

  def test_operation_precedence
    assert_equal "false true", resolve("true and false false or true")
    assert_equal "true", resolve("false and true or true and true")
    assert_equal "true", resolve("1 == 2 or 3 == 3")
    assert_equal "true", resolve("1 < 2 == 3 >= 3")
    assert_equal "true", resolve("1 + 3 > 4 - 2")
    assert_equal "11", resolve("1 + 2 * 3 + 4")
  end

  def test_functions
    assert_equal "#80ff80", resolve("hsl(120, 100%, 75%)")
    assert_equal "#81ff81", resolve("hsl(120, 100%, 75%) + #010001")
  end

  def test_operator_unit_conversion
    assert_equal "1.1cm", resolve("1cm + 1mm")
    assert_equal "true", resolve("2mm < 1cm")
    assert_equal "true", resolve("10mm == 1cm")
    assert_equal "true", resolve("1 == 1cm")
    assert_equal "true", resolve("1.1cm == 11mm")
  end

  def test_operations_have_options
    assert_equal "Options defined!", resolve("assert_options(1 + 1)")
    assert_equal "Options defined!", resolve("assert_options('bar' + 'baz')")
  end

  # Regression Tests

  def test_funcall_has_higher_precedence_than_color_name
    assert_equal "teal(12)", resolve("teal(12)")
    assert_equal "tealbang(12)", resolve("tealbang(12)")
    assert_equal "teal-bang(12)", resolve("teal-bang(12)")
    assert_equal "teal+bang(12)", resolve("teal\\+bang(12)")
  end

  def test_interpolation_after_hash
    assert_equal "#2", resolve('"##{1 + 1}"')
  end

  private

  def resolve(str, opts = {}, environment = env)
    munge_filename opts
    eval(str, opts, environment).to_s
  end

  def eval(str, opts = {}, environment = env)
    munge_filename opts
    Sass::Script.parse(str, opts.delete(:line) || 1,
      opts.delete(:offset) || 0, opts).perform(environment)
  end

  def render(sass, options = {})
    munge_filename options
    Sass::Engine.new(sass, options).render
  end

  def env(hash = {})
    env = Sass::Environment.new
    hash.each {|k, v| env.set_var(k, v)}
    env
  end

  def test_number_printing
    assert_equal "1", eval("1")
    assert_equal "1", eval("1.0")
    assert_equal "1.121", eval("1.1214")
    assert_equal "1.122", eval("1.1215")
    assert_equal "Infinity", eval("1.0/0.0")
    assert_equal "-Infinity", eval("-1.0/0.0")
    assert_equal "NaN", eval("0.0/0.0")
  end
end
