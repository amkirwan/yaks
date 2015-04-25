module Yaks
  class Mapper
    class Config
      include Attribs.new(
                type: nil, attributes: [], links: [], associations: [], forms: []
              )

      def add_attributes(*attrs)
        append_to(:attributes, *attrs.map(&Attribute.method(:create)))
      end
    end
  end
end
