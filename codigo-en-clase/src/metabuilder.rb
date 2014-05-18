class Metabuilder
  attr_accessor :property_list, :clazz,:validators, :comportamientos

  def initialize
    self.property_list = []
    self.validators = []
    self.comportamientos = []
  end

  def add_property sym
    self.property_list << sym
    self
  end

  def validate &block
    self.validators << block
    self
  end

  def behave_when nombre,condicion,comportamiento
    self.comportamientos << Comportamiento.new(nombre,condicion,comportamiento)
    self
  end

  def set_target_class klass
    self.clazz = klass
    self
  end

  alias :property :add_property
  alias :target_class :set_target_class

  def self.build &block
    instancia = self.new
    instancia.instance_eval &block
    instancia.build
  end

  def build
    builder = GenericBuilder.new self.clazz, self.property_list, validators, comportamientos
  end

end

class GenericBuilder

  attr_accessor :target_class, :property_list, :validators,:comportamientos

  def initialize(target_class, property_list, validators,comportamientos)
    self.property_list = property_list
    self.comportamientos = comportamientos
    self.target_class = target_class
    self.validators = validators
    self.property_list.each do |property|
      self.singleton_class.send :attr_accessor, property
    end
  end

  def validar
    self.validators.each do |validador|
      unless instance_eval &validador
        raise 'No cumple la validacion'
      end

    end
  end

  def agregar_comportamiento instancia

    self.comportamientos.each do |comportamiento|
      if comportamiento.te_cumplis_para instancia
        comportamiento.definite_en instancia
      end
    end

  end

  def build
    self.validar
    instancia = self.target_class.new
    self.property_list.each do |property|
      instancia.send(("#{property.to_s}=").to_sym, self.send(property))
    end
    self.agregar_comportamiento instancia
    instancia
  end

end


class Comportamiento

  attr_accessor :nombre,:condicion,:comportamiento

  def initialize nombre,condicion,comportamiento
    self.nombre = nombre
    self.condicion = condicion
    self.comportamiento = comportamiento
  end

  def te_cumplis_para instancia
    instancia.instance_eval &self.condicion
  end

  def definite_en instancia
    instancia.singleton_class.send :define_method, self.nombre, &self.comportamiento
  end

end




