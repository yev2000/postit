module ApplicationHelper
	## helpers correlate with view templates

	def fix_url(str)
		if str
			str.starts_with?('http://') ? str : "http://#{str}"
		else
			nil
		end
	end

	def pretty_time_string(date_time)
		if logged_in? && !current_user_get.time_zone.blank?
			date_time = date_time.in_time_zone(current_user_get.time_zone)
		#else
		#	date_time = date_time.localtime
		end

		date_time.strftime("%B %d, %Y at %I:%M%P %Z")

	end

	### the use of nbsp does not look correct here.
	### wondering if I need to pull this out to replace the
	### spaces with nbsp elsewhere.
	def pretty_posted_time_string(date_time)
		" on " + pretty_time_string(date_time) + "&nbsp;&nbsp;&nbsp;&nbsp;(#{time_ago_in_words(date_time)} ago)"
	end

	def positive_voted_entry_style
		"positive_vote_box"
	end

	def negative_voted_entry_style
		"negative_vote_box"
	end

	def neutral_voted_entry_style
		"neutral_vote_box"
	end

end
