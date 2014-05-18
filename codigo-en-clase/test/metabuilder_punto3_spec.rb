require 'rspec'
require_relative '../src/perro'
require_relative '../src/metabuilder'

describe 'Metabuilder' do

  it 'puede definir validaciones' do
    builder_de_perros = Metabuilder.new
      .add_property(:raza)
      .add_property(:edad)
      .add_property(:peso)
      .set_target_class(Perro)
      .validate {
        ['Fox terrier', 'salchicha', 'chihuahua'].include? raza
      }
      .validate {
        edad > 0 && edad < 20
      }
      .build

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

end