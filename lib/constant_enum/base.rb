module ConstantEnum
  class RecordNotFound < StandardError; end
  #
  # This supports the creation of a constant class that is designed to work
  # well with ActiveRecord enums. The benefit is you get additional functionality,
  # like finders and slugs. Performance is excellent as these are in-memory
  # structures and not DB calls.
  #
  # In the simplest structure, you specify a name and an integer ID:
  #
  #   class Genre < ConstantEnum::Base
  #     enum_of skate:      1,
  #             surf:       2,
  #             snow:       3,
  #             bike:       4,
  #   end
  #
  # Then, in an ActiveRecord class that wants to use this enum:
  #
  #   class Video < ActiveRecord::Base
  #     enum genre: Genre.enum
  #     ...
  #   end
  #
  #  From there, you can now do things like:
  #
  #   @genre  = Genre.find_by_name!(:skate)
  #   @videos = Video.where(genre: genre)
  #
  # Interesting routes can be created like:
  #
  #   # /videos/bike, /videos/surf, etc
  #   get 'videos/:genre' => 'videos#index', as: 'videos_genre',
  #     constraints: { genre: Genre.all.map(&:slug) }
  #
  # If you have extra data for your enum, you can specify a hash:
  #
  #   class AssetType < ConstantEnum::Base
  #     enum_of \
  #       photo: {id: 1, type: 'jpg', bucket: 'photos'},
  #       video: {id: 2, type: 'mp4', bucket: 'videos'}
  #
  class Base < Struct.new(:name, :id, :attributes)
    extend Enumerable

    def self.enum_of(hash)
      raise ArgumentError, "#{self}.enum_of name1: id2, name2: id2" unless hash.is_a?(Hash)
      @data = {}
      @enum = {}
      hash.each do |name,value|
        if value.is_a?(Hash)
          @enum[name] = value[:id] # for Rails
          @data[name] = new(name, value[:id], value)
        else
          @enum[name] = value # for Rails
          @data[name] = new(name, value)
        end

        # Create constants such as ADMIN=1 etc
        const_name =
          name.to_s.upcase.strip.gsub(/[-\s]+/,'_').sub(/^[0-9_]+/,'').gsub(/\W+/,'')
        const_set const_name, @enum[name] unless const_defined?(const_name)
      end
    end

    # Just return the hash. For use in ActiveRecord models, eg "enum role: Role.enum"
    def self.enum
      @enum
    end

    # Role[:admin] => 1 ; also Role[1] => 1 so models don't have to care.
    def self.[](what)
      if what.is_a?(Integer)
        find(what).id
      else
        find_by_name!(what).id
      end
    end

    def self.find_by_name!(name)
      find_by!(name: name)
    end

    def self.find_by_name(name)
      find_by_name!(name) rescue nil
    end

    def self.find_by_slug!(slug)
      find_by!(slug: slug)
    end

    def self.find_by_slug(slug)
      find_by!(slug: slug) rescue nil
    end

    def self.find(id)
      find_by!(id: id)
    end

    def self.find_by_id(id)
      find(id) rescue nil
    end

    def self.find_by(hash)
      where(hash).first
    end

    def self.find_by!(hash)
      find_by(hash) or
        raise RecordNotFound,
           %Q(Couldn't find #{self} with #{hash.collect{|k,v| "#{k}=#{v.inspect}"} * ' '})
    end

    def self.all
      where()
    end

    # Allow simple detection, similar to ActiveRecord.  This method is a little
    # verbose because we need to mimic where({}) which returns everything.
    # It also supports where(type: 'video', active: true) for multiple restrictions.
    def self.where(hash={})
      results = []
      @data.each do |name,struct|
        found = true # where({})
        hash.each do |k,v|
          if k.to_s == 'name'
            found = false if name.to_s != v.to_s
          else
            found = false if struct.send(k) != v
          end
        end
        # for where({})
        results << struct if found
      end
      results
    end

    # Enumerable support
    def self.each(&block)
      all.each(&block)
    end
    singleton_class.send :alias_method, :find_each, :each

    def self.ids
      @enum.map{|r| r.last}
    end

    def self.names
      @enum.map{|r| r.first}
    end

    def self.count
      @enum.keys.length
    end

    # Dropdown is actually [Title, name] for Rails 4.1 enums
    def self.dropdown
      @enum.collect{|name,id| [name.to_s.titleize, name] }
    end

    #
    # Instance methods: @role = Role.new ; @role.slug
    #
    def slug
      name.to_s.downcase.gsub(/\W+/,'')
    end

    def title
      name.to_s.titleize
    end

    def to_s
      name.to_s
    end

    def to_param
      id.to_s
    end

    # Handle extra attribute methods like .label or .delivery_type
    def method_missing(meth, *args, &block)
      if attributes.has_key?(meth)
        attributes[meth]
      else
        super
      end
    end
  end
end