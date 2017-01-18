
function ajaxGetScrapeData(url, param) {
    $.ajax({
        type: 'GET',
        url: url + param,
        success: function (response) {
            if (response.success) {
                if (response != null) {

                }
                return true;
            } else {
                return false;
            }
        }
    });
    return false;
}

function comment_delete_confirm(id){
    $('#comment_delete_id').val(id);
    var delete_modal = $('#comment-delete-confirm');
    delete_modal.data('id', id);
    delete_modal.modal('show');
}


function feed_delete_confirm(id){
    $('#feed_delete_id').val(id);
    var delete_modal = $('#feedDeleteModal');
    delete_modal.data('id', id);
    delete_modal.modal('show');
}