##########################
#
#  SLUG
#
###########################

module Slugger
  def compute_slug(edited_obj, basis_field_val)
    retval = ""
        
    if basis_field_val
      retval = basis_field_val.gsub(/[^a-zA-Z0-9]/, "-").downcase

      # we handle a special case here which is that if the slug already exists and
      # the substituted title matches the slug, we do not replace the slug
      if retval == edited_obj.slug
        return edited_obj.slug
      end

      # we have to find if there already exists a slug with this name
      another_obj = edited_obj.class.find_by(slug: retval)
      if (another_obj)
        # there is some other object with a slug that matches our proposed slug

        # if that object is "us" then we just return
        if (another_obj == edited_obj)
          return edited_obj.slug
        end

        # otherwise, we need to keep looking to see if there are yet more duplicates with the (<number>)
        # suffix, because there could be many duplicate objects.
        search_str = retval + "(%)"
        max_suffix_found = 0
        search_results = edited_obj.class.where("slug LIKE ?", search_str)
        search_results.each do |found_obj|

          # another special case - if we found the match against ourselves again
          # then we just return
          if (found_obj == edited_obj)
            return edited_obj.slug
          end
          
          if found_obj.slug
            last_parens_num = found_obj.slug.match(/\([0-9]*\)$/).to_s.gsub('(', '').gsub(')','').to_i
          else
            last_parens_num = 0
          end

          if (last_parens_num && (max_suffix_found < last_parens_num))
            max_suffix_found = last_parens_num
          end
        end

        retval += "(#{max_suffix_found + 1})"
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
end
