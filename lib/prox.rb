require "prox/version"
require 'delegate'

class Prox < ::SimpleDelegator
  class MissingObject < StandardError
    def initialize(message)
      @message = message
    end

    def to_s
      "Cannot send #{@message} without a __getobj__ object!"
    end
  end

  alias __proxy_class__ class

  def is_a?(klass)
    __getobj__.is_a? klass
  end
  alias kind_of? is_a?

  def instance_of?(klass)
    __getobj__.instance_of? klass
  end

  def class
    __getobj__.class
  end

  def method_missing(name, *args, &block)
    raise MissingObject, name unless __getobj__
    __getobj__.send name, *args, &block
  end
end
