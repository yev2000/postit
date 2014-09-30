$(document).ready(function() {
	function addHover(the_id, popup_id) {
		$(the_id).hover(function() {
			$(popup_id).show();
		}, function() {
			$(popup_id).hide();
		});
	};
});

