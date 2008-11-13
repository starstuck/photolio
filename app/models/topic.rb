# -*- coding: utf-8 -*-

class Topic < ActiveRecord::Base

  NAME_TRANSTABLE = [ 'ÀÁÂÃÄÅĄÇĆÈÉÊËĘÌÍÎÏÐŁÑŃÒÓÔÕÖ×ØŚÙÚÛÜÝŻŹàáâãäåąçèéêëęìíîïłñńòóôõöøśùúûüýżź', 
                      'AAAAAAACCEEEEEIIIIDLNNOOOOOxOSUUUUYZZaaaaaaaceeeeeiiiilnnoooooosuuuuyzz' ]
  NAME_TRANSMAP = Hash[ * NAME_TRANSTABLE.map{|s| s.split('')}.transpose.flatten ]
  NAME_CLEANUP_REGEXP = /[^a-z0-9]+/

  belongs_to :site

  attr_protected :name

  validates_presence_of :site
  validates_length_of :name, :maximum => 255
  validates_length_of :title, :maximum => 255
  validates_length_of :body, :maximum => 30000, :allow_nil => true
  validates_uniqueness_of :title, :scope => ['site_id']
  validates_uniqueness_of :name, :scope => ['site_id']

  # Auto update name on title change
  def title=(new_title)
    write_attribute(:title, new_title)
    write_attribute(:name, compute_name_from_string(new_title))
  end

  def name=(new_name)
    raise(ArgumentError, 'Name should not be manulay updated')
  end

  protected

  def compute_name_from_string(title)
    chars = title.split('').collect do |c|
      ( NAME_TRANSMAP.key? c ) ? NAME_TRANSMAP[c] : c 
    end
    chars.join.downcase.gsub( NAME_CLEANUP_REGEXP, '_' )
  end

end
