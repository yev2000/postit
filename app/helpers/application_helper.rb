module ApplicationHelper
	## helpers correlate with view templates

	def fix_url(str)
		if str
			str.starts_with?('http://') ? str : "http://#{str}"
		else
			nil
		end
	end
end
