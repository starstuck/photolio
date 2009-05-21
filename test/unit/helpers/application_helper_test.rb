require 'test_helper'

class DummyTopic; attr_accessor :body, :site; end

class ApplicationHelperTest < ActionView::TestCase

  def setup
    super
    @topic = DummyTopic.new
    @topic.site = sites(:pitchouguina)
  end

  def test_unknown_topic_macro
    @topic.body = 'Some [[my_macro]] text.'    
    assert_equal 'Some  text.', render_topic(@topic)
  end

  def test_asset_image_topic_macro
    @topic.body = 'Some [[asset_image_path(smart.jpg)]] asset.'
    assert_equal 'Some /pitchouguina/files/assets/smart.jpg asset.', render_topic(@topic)
    # Existing file
    @topic.body = 'Some [[ asset_image_path ( love_stories.jpg ) ]] asset.'
    assert_equal 'Some /pitchouguina/files/assets/love_stories.jpg asset.', render_topic(@topic)
    # Many macros in the same line
    @topic.body = 'Some [[asset_image_path(love_stories.jpg )]] and '\
                  '[[asset_image_path(smart.jpg)]] assets.'
    assert_equal('Some /pitchouguina/files/assets/love_stories.jpg and '\
                 '/pitchouguina/files/assets/smart.jpg assets.',
                 render_topic(@topic))
  end

  def test_photo_image_topic_macro
    @topic.body = 'Some [[photo_image_path(smart.jpg)]] asset.'
    assert_equal 'Some /pitchouguina/files/photos/smart.jpg asset.', render_topic(@topic)
  end

end
