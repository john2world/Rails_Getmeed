/**
 * User: ravi
 * Date: 8/4/13
 * Time: 3:31 PM
 */


$(function () {

    $('[id^="add_new"]').click(function () {
        renderNewEditItem(this.id.split('_')[2]);
    });


    $('#home_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });



    $('#jobTabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });

    $('#allTabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });


    $('#feedTabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });


    $('#company_jobs_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    })


    $('#resumeTabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    })

    $('#questionTabs a').click(function (e) {
        e.preventDefault()
        $(this).tab('show')
    })

    $('[id^="upvote_"]').click(function () {
        var elementId = this.id;
        ajaxUpvote('/upvotes/', elementId.split("_")[1]);
    });




    $('[id^="downvote_"]').click(function () {
        var elementId = this.id;
        ajaxDownvote('/downvotes/', elementId.split("_")[1]);
    });

});


function renderEditItem(profileElementId) {
    $('#' + profileElementId).hide();
    var editID = profileElementId.replace("show", "edit");
    $('#' + editID).show();
};

function renderViewItem(profileItemId) {
    $('#' + profileItemId + '_true').hide();
    var showID = (profileItemId + '_true').replace("edit", "show");
    $('#' + showID).show();
};

function renderNewEditItem(profileItemType) {
    $('#add_new_' + profileItemType).css('display', 'none');
    $('#edit_' + profileItemType + '_div').show();
    $('#edit_' + profileItemType + '_div').focus();
};

function viewNewItem(profileItemType) {
    $('#edit_' + profileItemType + '_div').css('display', 'none');
    $('#form_'+ profileItemType + '_new')[0].reset();
    $('#add_new_' + profileItemType).css('display', '');
};