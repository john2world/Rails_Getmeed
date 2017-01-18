function ajaxUpvote(url, param) {
    $.ajax({
        type: 'POST',
        url: url + param,
        success: function (response) {
            if (response.success) {
                $("#upvotecount_" + param).text(parseInt($("#upvotecount_" + param).text()) + 1);
                $("#downvote_" + param).attr('class', 'downvote');
                $("#upvote_" + param).attr('class', 'votehidden');


            }
        }
    });
    return false;
}

function trackClick(data) {
    var authenticity = '?authenticity_token=' + $('#tokentag').val();
    $.ajax({
        type: 'POST',
        url: '/track/click/' + data + authenticity,
        success: function (response) {
            if (response.success) {
            }
        }
    });
    return false;
}

function ajaxOnUrl(url) {
    $.ajax({
        type: 'POST',
        url: url,
        success: function (response) {
            if (response.success) {
            } else {
                alert('Something went wrong!');
            }
        }
    });
}

function ajaxDownvote(url, param) {
    $.ajax({
        type: 'POST',
        url: url + param,
        success: function (response) {
            if (response.success) {
                $("#upvotecount_" + param).text(parseInt($("#upvotecount_" + param).text()) - 1);
                $("#upvote_" + param).attr('class', 'downvote');
                $("#downvote_" + param).attr('class', 'votehidden');
            }
        }
    });
    return false;
}

function ajaxUpdateSettings(handle, data) {
    $.ajax({
        type: 'POST',
        url: '/settings/' + handle + '/update',
        data: data,
        success: function (response) {
            if (response.success === false) {
                alert('Failed to update settings!');
            }
        }
    });
}