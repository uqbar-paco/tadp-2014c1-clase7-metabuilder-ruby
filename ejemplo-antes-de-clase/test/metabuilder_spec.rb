require 'rspec'
require_relative '../src/metabuilder'

describe 'Metabuilder' do

  class Perro
    attr_accessor :raza, :edad, :peso
  end

  it 'puede crear un builder con varias properties' do
    builder_de_perros = Metabuilder.new
    .set_target_class(Perro)
    .add_property(:raza)
    .add_property(:edad)
    .add_property(:peso)
    .build

    builder_de_perros.raza = 'Fox terrier'
    builder_de_perros.edad = 4
    builder_de_perros.peso = 14
    perro = builder_de_perros.build

    perro.raza.should == 'Fox terrier'
    perro.edad.should == 4
    perro.peso.should == 14
  end

  it 'falla si quiero setear una property que no definí' do
    builder_de_perros = Metabuilder.new
      .set_target_class(Perro)
      .add_property(:raza)
      .add_property(:edad)
      .add_property(:peso)
      .build

    expect {
      builder_de_perros.peto = 6
    }.to raise_error NoMethodError
  end

  it 'puede usarse con una sintaxis alternativa' do
    builder_de_perros = Metabuilder.build {
      property(:raza)
      property(:edad)
      property(:peso)
      target_class(Perro)
    }

    builder_de_perros.raza = 'Fox terrier'
    builder_de_perros.edad = 4
    builder_de_perros.peso = 14
    perro = builder_de_perros.build

    perro.raza.should == 'Fox terrier'
    perro.edad.should == 4
    perro.peso.should == 14
  end

  it 'puede definir validaciones' do
    builder_de_perros = Metabuilder.build {
      property(:raza)
      property(:edad)
      property(:peso)
      target_class(Perro)
      validate {
        ['Fox terrier', 'salchicha', 'chihuahua'].include? raza
      }
      validate {
        edad > 0 && edad < 20
      }
    }

    builder_de_perros.raza = 'Fox terrier'
    builder_de_perros.edad = 4
    builder_de_perros.peso = 14
    perro = builder_de_perros.build

    perro.raza.should == 'Fox terrier'
    perro.edad.should == 4
    perro.peso.should == 14
  end

  it 'falla cuando una validación no se cumple' do
    builder_de_perros = Metabuilder.build {
      property(:raza)
      property(:edad)
      property(:peso)
      target_class(Perro)
      validate {
        ['Fox terrier', 'salchicha', 'chihuahua'].include? raza
      }
      validate {
        (edad > 0) && (edad < 20)
      }
    }

    expect {
      builder_de_perros.raza = 'Fox terrier'
      builder_de_perros.edad = 22
      builder_de_perros.peso = 14
      builder_de_perros.build
    }.to raise_error StandardError
  end

  it 'puede agregar comportamiento' do
    builder_de_perros = Metabuilder.build {
      property(:raza)
      property(:edad)
      property(:peso)
      target_class(Perro)
      behave_when 'expectativa_de_vida', proc {raza == 'Fox terrier'}, proc {
        20 - edad
      }
      behave_when 'expectativa_de_vida', proc {raza == 'salchicha'}, proc {
        edad + peso * 2
      }
      behave_when 'expectativa_de_vida', proc {raza == 'chihuahua'}, proc {
        5
      }
    }

    builder_de_perros.raza = 'Fox terrier'
    builder_de_perros.edad = 4
    builder_de_perros.peso = 14
    perro = builder_de_perros.build

    perro.raza.should == 'Fox terrier'
    perro.edad.should == 4
    perro.peso.should == 14
    perro.expectativa_de_vida.should == 16
  end

end