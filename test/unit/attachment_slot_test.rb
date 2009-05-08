require 'test_helper'

class AttachmentSlotTest < ActiveSupport::TestCase

  test "get definition" do
    slot = attachment_slots(:love_stories_label_slot)
    assert_not_nil slot.definition

    slot = AttachmentSlot.new(:name => 'not_defined', 
                              :having_attachment => galleries(:love_stories))
    assert_nil slot.definition
  end

  test "validate attachment by type" do
    definition = AttachmentSlot::Definition.new('banner',
                                                :valid_types => [Photo, 'Asset'])
    assert_equal true, definition.valid_attachment?(assets(:love_stories_banner))
    assert_equal true, definition.valid_attachment?(photos(:one))
    assert_equal false, definition.valid_attachment?(topics(:one))
  end

end
