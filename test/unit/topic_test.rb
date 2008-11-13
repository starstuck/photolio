# -*- coding: utf-8 -*-
require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  def test_set_name
    @topic = Topic.new

    begin
      @topic.name = 'some'
    rescue ArgumentError
      assert true
    else
      assert false, 'Setting topic name should raise exception'
    end
  end

  def test_name_update_on_title_change
    @topic = Topic.new(:title => "My little, new topic")
    assert_equal 'my_little_new_topic', @topic.name

    @topic.title = 'With translated characters: Ółą'
    assert_equal 'with_translated_characters_ola', @topic.name
  end

end
