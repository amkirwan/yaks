module Yaks
  class Format
    class CollectionJson < self
      register :collection_json, :json, 'application/vnd.collection+json'

      include FP

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {
          version: "1.0",
          items: serialize_items(resource)
        }
        result[:href] = resource.self_link.uri if resource.self_link
        result[:links] = serialize_links(resource) if resource.collection? && resource.links.any?
        result[:queries] = serialize_queries(resource) unless serialize_queries(resource).nil?
        {collection: result}
      end

      # @param [Yaks::Resource] resource
      # @return [Array]
      def serialize_items(resource)
        resource.seq.map do |item|
          attrs = item.attributes.map do |name, value|
            {
              name: name,
              value: value
            }
          end
          result = { data: attrs }
          result[:href] = item.self_link.uri if item.self_link
          item.links.each do |link|
            next if link.rel.equal? :self
            result[:links] = [] unless result.key?(:links)
            result[:links] << {rel: link.rel, href: link.uri}
            result[:links].last[:name] = link.title if link.title
          end
          result
        end
      end

      def serialize_links(resource)
        result = []
        resource.links.each do |link|
          result << {href: link.uri, rel: link.rel}
        end
        result
      end

      def serialize_queries(resource)
        result = []

        resource.forms.each do |f|
          next unless f.method == "GET"

          # `action` in Yaks is not required,
          # but it is for Collection+JSON
          unless f.action.nil?
            result << { rel: f.name, href: f.action }
            result.last[:prompt] = f.title if f.title

            f.fields.each do |field|
              result.last[:data] = [] unless result.last.key? :data
              result.last[:data] << {name: field.name, value: nil.to_s}
              result.last[:data].last[:prompt] = field.label if field.label
            end if f.fields.any?
          end
        end if resource.forms.any?

        result if result.any?
      end
    end
  end
end
