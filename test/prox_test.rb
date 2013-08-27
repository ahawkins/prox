require_relative 'test_helper'

class ProxTest < MiniTest::Unit::TestCase
  Person = Struct.new(:name, :id) do
    def ==(other)
      other.instance_of?(self.class) && id == other.id
    end

    def eql?(other)
      self == other
    end

    def method_missing(name, *args, &block)
      if name == :secret_method
        'bar'
      else
        super
      end
    end
  end

  def test_fowards_messages_to_the_content
    proxy = Prox.new Person.new('Adam')

    assert_equal proxy.name, 'Adam'
  end

  def test_proxies_methods_implemented_with_method_missing
    proxy = Prox.new Person.new('Adam')

    assert_equal 'bar', proxy.secret_method
  end

  def test_raises_an_error_on_undefined_methods
    proxy = Prox.new Person.new

    assert_raises NoMethodError do
      proxy.hobby
    end
  end

  def test_raises_an_error_when_no_content
    proxy = Prox.new nil

    assert_raises Prox::MissingObject do
      proxy.hi
    end
  end

  def test_proxy_completely_imitate_reflection_interface
    proxy = Prox.new Person.new('Adam')

    assert proxy.is_a?(Person)
    assert proxy.kind_of?(Person)
    assert proxy.instance_of?(Person)
    assert_equal Person, proxy.class
  end

  def test_equality
    a = Person.new 'Adam', 'ahawkins'
    b = Person.new 'Paul', 'pcowan'
    c = Person.new 'Adam', 'ahawkins'

    assert_equal a, c, "Precondition: objects must be equal"
    assert_equal c, a, "Precondition: objects must be equal"
    refute_equal a, b, "Precondition: objects must not be equal"
    refute_equal b, a, "Precondition: objects must not be equal"

    assert a.eql?(c), "Precondition: objects must be equal"
    assert c.eql?(a), "Precondition: objects must be equal"
    refute a.eql?(b), "Precondition: objects must not be equal"
    refute b.eql?(a), "Precondition: objects must not be equal"

    pa = Prox.new a
    pb = Prox.new b
    pc = Prox.new c

    assert_equal pa, pc
    assert_equal pc, pa
    refute_equal pa, pb
    refute_equal pb, pa

    assert pa.eql?(pc)
    assert pc.eql?(pa)
    refute pa.eql?(pb)
    refute pb.eql?(pa)

    assert_equal pa, c
    assert_equal pc, a
    refute_equal pa, b
    refute_equal pb, a

    assert pa.eql?(c)
    assert pc.eql?(a)
    refute pa.eql?(b)
    refute pb.eql?(a)
  end
end
