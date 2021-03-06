# coding: utf-8

require_relative '../lib/full_clone'
gem              'minitest'
require          'minitest/autorun'

#Test the monkey patches applied to the Object class.
class ObjectFullCloneTester < Minitest::Test

  class SimpleClass
    attr_accessor :iva
    attr_accessor :ivb
    attr_accessor :ivc

    def initialize(iva, ivb, ivc)
      @iva, @ivb, @ivc = iva, ivb, ivc
    end
  end

  def test_basic_deep_cloning
    sa = "North"
    simple1 = SimpleClass.new(sa, 5, nil)
    simple2 = simple1.full_clone

    assert_equal(simple1.iva, simple2.iva)
    assert_equal(simple1.ivb, 5)
    assert_nil(simple1.ivc)
    refute_equal(simple1.iva.object_id, simple2.iva.object_id)

    sa << "West"

    assert_equal(sa, "NorthWest")
    assert_equal(simple1.iva, "NorthWest")
    assert_equal(simple2.iva, "North")
  end

  def test_with_exclusion
    sa = "North"
    simple1 = SimpleClass.new(sa, 5, nil)
    simple1.define_singleton_method(:full_clone_exclude) {[:@iva]}
    assert_equal(simple1.singleton_methods, [:full_clone_exclude])
    simple2 = simple1.full_clone
    assert_equal(simple2.singleton_methods, [:full_clone_exclude])

    assert_equal(simple1.iva, simple2.iva)
    assert_equal(simple1.ivb, 5)
    assert_nil(simple1.ivc)
    assert_equal(simple1.iva.object_id, simple2.iva.object_id)
  end

  def test_with_direct_looping
    simple1 = SimpleClass.new('East', 5, nil)
    simple1.ivc = simple1
    simple2 = simple1.full_clone

    assert_equal(simple2.object_id, simple2.ivc.object_id)
    refute_equal(simple1.object_id, simple2.ivc.object_id)
  end

  def test_with_direct_looping_and_exclusion
    simple1 = SimpleClass.new('East', 5, nil)
    simple1.define_singleton_method(:full_clone_exclude) {[:@ivc]}
    assert_equal(simple1.singleton_methods, [:full_clone_exclude])
    simple1.ivc = simple1
    simple2 = simple1.full_clone
    assert_equal(simple2.singleton_methods, [:full_clone_exclude])

    refute_equal(simple2.object_id, simple2.ivc.object_id)
    assert_equal(simple1.object_id, simple2.ivc.object_id)
  end

  def test_with_indirect_looping
    simple1 = SimpleClass.new('East', 5, nil)
    simple3 = SimpleClass.new('West', 6, simple1)
    simple1.ivc = simple3
    simple2 = simple1.full_clone

    assert_equal(simple2.object_id, simple2.ivc.ivc.object_id)
  end

end