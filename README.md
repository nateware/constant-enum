# Constant::Enum

ActiveRecord-like model for dealing with constant data.  Works well with
[ActiveRecord 4.x enums](http://api.rubyonrails.org/classes/ActiveRecord/Enum.html).
In their basic form, ActiveRecord enums are very simplistic, so this gem seeks to
add more robust functionality.

This does not have any dependencies and could be used standalone, with Sinatra, etc.

## Usage

First, create a class that inherits from `ConstantEnum::Base`, similar to how you would
create an `ActiveRecord::Base` class.  This will hold your enum names and IDs.

In the simplest structure, you specify a name and an integer ID.  Imagine we're creating
an action sports blog that will cover certain genres, which we know ahead of time:

    class Genre < ConstantEnum::Base
      enum_of skate: 1,
              surf:  2,
              snow:  3,
              bike:  4
    end

Then, in any ActiveRecord class that wants to use this enum, you specify this enum class:

    class Video < ActiveRecord::Base
      enum genre: Genre.enum

      # other code...
    end

Once setup, you can now do things like:

    @genre  = Genre.find_by_name!(:skate)
    @videos = Video.where(genre: @genre)

For convenience, the class method `[]` will return the ID from the name, enabling a
shortcut calling form:

    @videos = Video.where(genre: Genre[:skate])

In addition to translating names to IDs, several helper methods are provided to make
day-to-day life easier:

    @genre = Genre.find_by_name!(:skate)
    @genre.name  # :skate
    @genre.slug  # "skate"
    @genre.title # "Skate" - requires Rails (ActiveSupport Inflector)

You can create interesting route URLs by using these in Rails `config/routes.rb`:

    # /videos/bike, /videos/surf, etc
    get 'videos/:genre' => 'videos#index', as: 'videos_genre',
      constraints: { genre: Genre.all.map(&:slug) }

Then using the shortcut form show above, you can (safely) do a query with this param:

    @videos = Video.where(genre: Genre[ params[:genre] ])

This will raise `ConstantEnum::RecordNotFound`, which you can catch in your controllers to provide a clean error:

    rescue_from ActiveRecord::RecordNotFound, ConstantEnum::RecordNotFound do
      # show error page
    end

When building forms, you can use the special method `dropdown`, which provides options in the
same order that Rails form helpers expect them:

     <%= f.input :genre, label: 'Genre', collection: Genre.dropdown %>

This will create a nice human-readable select list with the correct names and values.

Finally, if you have extra data for your enum, you can instead specify a hash:

    class AssetType < ConstantEnum::Base
      enum_of photo: {id: 1, type: 'jpg', bucket: 'photos'},
              video: {id: 2, type: 'mp4', bucket: 'videos'}

      # other code...
    end

Then, retrieving a constant "record" will give you these attributes:

    @at = AssetType.find_by_type!('jpg')
    @at.id  # 1
    @at.bucket  # 'photos'

You can even use `where` to return a list:

    @ats = AssetType.where(type: 'jpg')
    @ats = AssetType.where(bucket: 'videos')

And so on.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nateware/constant-enum

## Copyright

Copyright (c) [Nate Wiger](http://github.com/nateware). All Rights Reserved. Released under the MIT License.
