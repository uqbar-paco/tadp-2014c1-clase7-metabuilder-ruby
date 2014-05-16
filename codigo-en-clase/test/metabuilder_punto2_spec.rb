require 'rspec'
require_relative '../src/perro'
require_relative '../src/metabuilder'

describe 'Metabuilder' do

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

end