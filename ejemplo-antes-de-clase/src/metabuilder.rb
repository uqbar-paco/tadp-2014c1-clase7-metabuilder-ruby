class Metabuilder

  attr_accessor :clazz, :properties, :validators, :behaviors

  def initialize
    @properties = []
    @validators = []
    @behaviors = []
  end

  def add_property(name)
    @properties << name.to_s
    self
  end

  def set_target_class(clazz)
    @clazz = clazz
    self
  end

  def build
    Builder.new(self)
  end

  def self.build(&block)
    metabuilder = self.new
    metabuilder.instance_eval &block
    metabuilder.build
  end

  def validate(&block)
    @validators << block
  end

  def behave_when(nombre, condicion, comportamiento)
    @behaviors << Behavior.new(nombre, condicion, comportamiento)
  end

  alias :property :add_property
  alias :target_class :set_target_class

end

class Builder

  def initialize(metabuilder)
    @metabuilder = metabuilder
    @instance = metabuilder.clazz.new
    @instance.singleton_class.send(:attr_accessor, *@metabuilder.properties)
  end

  def es_set_property(selector)
    selector.end_with?('=') && @metabuilder.properties.include?(selector[0..-2])
  end

  def method_missing(name, *args, &block)
    if (es_set_property(name.to_s))
      @instance.send(name, *args, &block)
    else
      super
    end
  end

  def validate(instancia)
    @metabuilder.validators.each {|validator|
      unless instancia.instance_eval &validator
        raise 'Una validación falla!'
      end
    }
  end

  def apply_behaviors(instancia)
    @metabuilder.behaviors.select { |behavior|
      behavior.aplica?(instancia)
    }.each { |behavior|
      behavior.aplicar(instancia)
    }
  end

  def build
    validate(@instance)
    apply_behaviors(@instance)
    @instance
  end

end

class Behavior

  attr_accessor :nombre, :condicion, :comportamiento

  def initialize(nombre, condicion, comportamiento)
    @nombre = nombre
    @condicion = condicion
    @comportamiento = comportamiento
  end

  def aplica?(instancia)
    instancia.instance_eval &@condicion
  end

  def aplicar(instancia)
    instancia.define_singleton_method nombre, &comportamiento
  end

end