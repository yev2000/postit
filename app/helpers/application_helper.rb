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
		date_time.localtime.strftime("%B %d, %Y at %I:%M%P %Z")
	end

	### the use of nbsp does not look correct here.
	### wondering if I need to pull this out to replace the
	### spaces with nbsp elsewhere.
	def pretty_posted_time_string(date_time)
		" on " + pretty_time_string(date_time) + "&nbsp;&nbsp;&nbsp;&nbsp;(#{time_ago_in_words(date_time)} ago)"
	end

end
