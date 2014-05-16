require 'rspec'
require_relative '../src/perro'
require_relative '../src/metabuilder'

describe 'Metabuilder' do

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

end