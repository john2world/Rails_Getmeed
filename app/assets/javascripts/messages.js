
$(function () {
	$('#reply_message').click(function(){
		editMessage(this.id);
	});
	
	$('#cancel_message').click(function(){
		cancelEditMessage(this.id);
	});
});

function editMessage(id){
	var view_class = $('#' + id).parents("div")[2].className;
	// replace a single/first occurence of view with edit
	var edit_class = view_class.replace("view", "edit");
	// make the element with view_class hidden and show the edit_class div
	$('.' + view_class).hide();
	$('.' + edit_class).show();
};

function cancelEditMessage(id){
	// parent for cancel is the super parent div
	var edit_class = $('#' + id).parents("div")[2].className;
	// replace a single/first occurence of view with edit
	var view_class = edit_class.replace("edit", "view");
	// make the element with view_class hidden and show the edit_class div
	$('.' + edit_class).hide();
	$('.' + view_class).show();
};

