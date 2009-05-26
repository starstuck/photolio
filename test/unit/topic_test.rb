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
    @topic = Topic.create(:site => sites(:polinostudio),
                          :title => "My little, new topic")
    assert_equal 'my_little_new_topic', @topic.name

    @topic.title = 'With translated characters: Ółą'
    @topic.save()
    assert_equal 'with_translated_characters_ola', @topic.name
  end

  def test_unique_title_generation
    @site = sites(:polinostudio)
    @topic = Topic.create(:site => @site,
                          :title => "Contact")
    assert_equal 'contact', @topic.name

    @topic2 = Topic.create(:site => @site,
                          :title => "contact")
    assert_equal 'contact_1', @topic2.name

    @topic3 = Topic.create(:site => @site,
                           :title => "ConTact")
    assert_equal 'contact_2', @topic3.name
  end

end
