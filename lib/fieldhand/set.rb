module Fieldhand
  Set = Struct.new(:spec, :name) do
    def self.from(element)
      spec = element.setSpec.text
      name = element.setName.text

      new(spec, name)
    end
  end
end
