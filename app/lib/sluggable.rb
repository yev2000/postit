##########################
#
#  SLUG
#
###########################

module Sluggable

  # alternative to get_field_for_slugging() to be defined in the classes that include this module:
  # add
  #     class_attribute: slug_column
  # to included do...
  #
  # In including class, you add
  #     sluggable_column :tile (for post)
  #     sluggable_column :name (for category) etc.
  #
  # And in the slug code where the appropriate field needs to be referenced
  #    the_slug = to_slug(self.send(self.class.slug_column.to_sym))
  #
  # also in the module:
  # module ClassMethod
  #   def sluggable_column(col_name)
  #    self.slug_column = col_name
  #   end
  # end
  #

  extend ActiveSupport::Concern

  included do
    after_validation :generate_slug
  end

  def compute_slug(basis_field_val)
    retval = ""
        
    if basis_field_val
      retval = basis_field_val.gsub(/[^a-zA-Z0-9]/, "-").gsub(/---*/, "-").downcase

      # we handle a special case here which is that if the slug already exists and
      # the substituted title matches the slug, we do not replace the slug
      if retval == self.slug
        return self.slug
      end

      # we have to find if there already exists a slug with this name
      another_obj = self.class.find_by(slug: retval)
      if (another_obj)
        # there is some other object with a slug that matches our proposed slug

        # if that object is "us" then we just return
        if (another_obj == self)
          return self.slug
        end

        # otherwise, we need to keep looking to see if there are yet more duplicates with the (<number>)
        # suffix, because there could be many duplicate objects.
        search_str = retval + "--%--"
        max_suffix_found = 0
        search_results = self.class.where("slug LIKE ?", search_str)
        search_results.each do |found_obj|

          # another special case - if we found the match against ourselves again
          # then we just return
          if (found_obj == self)
            return self.slug
          end
          
          if found_obj.slug
            last_dubdash_num = found_obj.slug.match(/--[0-9]*--$/).to_s.gsub('--', '').gsub('--','').to_i
          else
            last_dubdash_num = 0
          end

          if (last_dubdash_num && (max_suffix_found < last_dubdash_num))
            max_suffix_found = last_dubdash_num
          end
        end

        retval += "--#{max_suffix_found + 1}--"
        return retval
      else
        return retval
      end
    else
      # a nil title should never happen, but just in case if we do happen
      # to have an object with no basis field, we'll return nil to the caller.
      nil
    end
  end

  def generate_slug
    # if we want to have slugs that never change
    # we would do ||= so that once the slug is non-nil, it will never get updated.
    # In our case here, we always recompute.
    # there is a problem with this approach is that we may end up
    # changing the slug suffix number unnecessarily.
    # this is because the title may have changed by a special character
    # which would map to the original slug text.  So we need to figure that out.
    self.slug = compute_slug(self.get_field_for_slugging())
  end

  def to_param
    # we override default behavior to allow for string-based slugs
    # rather than the primary key (ID) of the post
    if self.slug == nil
      # we have not yet had a chance to construct the slug string, so
      # construct it now and save the post
      self.slug = compute_slug(self.get_field_for_slugging())
      self.save
    end

    # now return the slug, because ultimately to_param is looking to get back
    # the URL component for this instance, which will be the slug
    self.slug

  end

end
