# Constant::Enum

ActiveRecord-like model for dealing with constant data.  Works well with ActiveRecord 4.x
enums. Also supports simple slugging of attributes. Performance is excellent as these are
in-memory structures and not DB calls.

This does not have any dependencies and could be used standalone, with Sinatra, etc.

## Usage

To use, create class that inherits from `ConstantEnum::Base`, similar to how you would
create an `ActiveRecord::Base` class.

In the simplest structure, you specify a name and an integer ID.  Imagine we're creating
an action sports blog that will cover certain genres, which we know ahead of time:

    class Genre < ConstantEnum::Base
      enum_of skate:      1,
              surf:       2,
              snow:       3,
              bike:       4
    end

Then, in any ActiveRecord class that wants to use this enum, you specify the enum class:

    class Video < ActiveRecord::Base
      enum genre: Genre.enum

      # other code...
    end

Once setup, you can now do things like:

    @genre  = Genre.find_by_name!(:skate)
    @videos = Video.where(genre: genre)

For convenience, the class method `[]` will return the ID, enabling a shortcut calling form:

    @videos = Video.where(genre: Genre[:skate])

When building forms, you can use the special method `dropdown` which provides options in the
same order that Rails form helpers expect them:

     <%= f.input :genre, label: 'Genre', collection: Genre.dropdown %>

You can create interesting route URLs by using this in Rails `config/routes.rb`:

    # /videos/bike, /videos/surf, etc
    get 'videos/:genre' => 'videos#index', as: 'videos_genre',
      constraints: { genre: Genre.all.map(&:slug) }

Then using the shortcut form show above, you can (safely) do a query with this param:

    @videos = Video.where(genre: Genre[ params[:genre] ])

This will raise `ConstantEnum::RecordNotFound`, which you can catch in your controllers to provide a clean error:

    rescue_from ActiveRecord::RecordNotFound, ConstantEnum::RecordNotFound do
      # show error page
    end

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
