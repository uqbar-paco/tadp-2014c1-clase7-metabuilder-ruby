require 'rspec'
require_relative '../src/perro'
require_relative '../src/metabuilder'

describe 'Metabuilder' do

  it 'puede agregar comportamiento' do
    builder_de_perros = Metabuilder.build {
      property(:raza)
      property(:edad)
      property(:peso)
      target_class(Perro)
      behave_when 'expectativa_de_vida', proc { raza == 'Fox terrier' }, proc {
        20 - edad
      }
      behave_when 'expectativa_de_vida', proc { raza == 'salchicha' }, proc {
        edad + peso * 2
      }
      behave_when 'expectativa_de_vida', proc { raza == 'chihuahua' }, proc {
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