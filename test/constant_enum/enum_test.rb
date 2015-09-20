require 'test_helper'

class EmptyEnum < ConstantEnum::Base
end

class Genre < ConstantEnum::Base
  enum_of skate: 1,
          surf:  2,
          snow:  3,
          bike:  4
end

class AssetType < ConstantEnum::Base
  enum_of photo: {id: 1, type: 'jpg', bucket: 'photos'},
          video: {id: 2, type: 'mp4', bucket: 'videos'},
          sound: {id: 3, type: 'mp4', bucket: 'sounds'}
end

class ConstantEnum::Test < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ConstantEnum::VERSION
  end

  def test_for_empty_enum
    assert_nil EmptyEnum.enum
    assert_raises ConstantEnum::RecordNotFound do
      EmptyEnum.where(name: 'foo')
    end
  end

  def test_simple_declarations
    assert_equal 4, Genre.count
    assert_equal 2, Genre[:surf]
    assert_equal 4, Genre['bike']
    assert_raises ConstantEnum::RecordNotFound do
      Genre[:no_such_key]
    end
  end

  def test_helper_methods
    gen = Genre.new(:snow, 3, nil)
    assert_equal gen, Genre.find(3)
    assert_equal :snow, gen.name
    assert_equal 'Snow', gen.title
    assert_equal 3, gen.id
  end

  def test_complex_declarations
    assert_equal 3, AssetType.count
    assert_equal 3, AssetType.all.size
    assert_equal 1, AssetType[:photo]
    assert_equal 2, AssetType['video']
    assert_raises ConstantEnum::RecordNotFound do
      AssetType[:no_such_key]
    end
  end

  def test_activerecord_finders
    at = AssetType.find(1)
    assert_equal 1, at.id
    assert_equal :photo, at.name
    assert_equal 'jpg', at.type
    assert_equal 'photos', at.bucket
    assert_equal 'Photo', at.title

    assert_nil AssetType.find_by_name('tacos')
    assert_raises ConstantEnum::RecordNotFound do
      AssetType.find_by_name!('tacos')
    end
  end

  def test_activerecord_where_clauses
    atlist = AssetType.where(type: 'mp4')
    assert_equal 2, atlist.length

    at = atlist.first
    assert_equal 2, at.id
    assert_equal :video, at.name
    assert_equal 'mp4', at.type
    assert_equal 'videos', at.bucket

    at = atlist.last
    assert_equal 3, at.id
    assert_equal :sound, at.name
    assert_equal 'mp4', at.type
    assert_equal 'sounds', at.bucket
  end
end
