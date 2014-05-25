module Yaks
  # A collection of Resource objects, it has members, and its own set of link
  # relations like self and profile describing the collection.
  #
  # A collection can be the top-level result of an API call, like all posts to
  # a blog, or a subresource collection, like the comments on a post result.
  #
  # Some formats treat everything like a collection, and a single resource as a
  # collection of one. Others treat every top level response as singular, e.g.
  # a single "collection of orders". Because of this Resource and
  # CollectionResource can both be iterated with #each, for the "everything is
  # a collection crowd", and they both respond to `links`, `attributes` and
  # `subresources`, so they can both be approached like a singular resource.
  #
  # In the second case a collection has a single "subresource", being its
  # members.
  class CollectionResource
    include Equalizer.new(:links, :members)
    include Enumerable, LinkLookup

    extend Forwardable

    attr_reader :links, :members

    def_delegators :members, :each

    def initialize(links, members)
      @links   = links
      @members = members
    end

    def attributes
      {}
    end

    # Make a CollectionResource quack like a resource.
    #
    # At the moment this is only for HAL, which always assumes
    # a singular resource at the top level, this way it can treat
    # whatever it gets as a single resource with links and subresources,
    # we just push the collection down one level.
    #
    # Once inside subresources the HAL serializer does check if a resource
    # is a collection, since there it does make a distinction, and because
    # in that case it will iterate with each/map rather than calling subresources,
    # this doesn't cause infinite recursion. Not very pretty, needs looking at.
    #
    # :(
    def subresources
      if members && members.any?
        { profile => self }
      else
        {}
      end
    end

    def []
    end

    def collection?
      true
    end

  end
end
