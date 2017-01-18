// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.validate.js
//= require twitter/bootstrap
//= require bootstrap-wysihtml5
//= require pace
//= require bootstrap-hover-dropdown.min
//= require foggy.min
//= require bootstrap-switch.min
//= require jquery.placeholder.js
//= require jquery.fitvids.js
//= require jquery.flexslider-min.js
//= require rrssb
//= require algolia/algoliasearch.min
//= require algolia/typeahead.jquery
//= require jquery.remotipart
//= require ress
//= require companies
//= require posts
//= require jobs
//= require feed
//= require profiles
//= require insights
//= require main
//= require messages
//= require algoliasearch
//= require ajax
//= require backstretch
//= require jquery.cookie
//= require share
skills = [];
function foggyblur() {
    $('#whole_page').foggy({
        blurRadius: 12,          // In pixels.
        opacity: 1,           // Falls back to a filter for IE.
        cssFilterSupport: true  // Use "-webkit-filter" where available.
    });
}

function foggyUnblur() {
    $('#whole_page').foggy(false);
}

$(document).ready(function () {
    allModals = $('[id$="Modal"]');

    allModals.on('show.bs.modal', function () {
        $(window).resize();
        foggyblur();
    });

    allModals.on('hidden.bs.modal', function () {
        foggyUnblur();
    });

    $("#hits").hide();
    var activity_box = $("#activity_box");
    var body = $('body');

    $('#activity_question_show_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:display');
        $('#activity_question_show_link').attr('style', 'display:none');
        $('#activity_close_question_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:display');
        toggle_activity_box_controls();
    });

    $('#activity_story_show_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:display');
        $('#activity_story_show_link').attr('style', 'display:none');
        var selectType = $('#activity_box_type');
        selectType.val('story');
        $('#activity_close_story_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:display');
        toggle_activity_box_controls();
    });

    $('#activity_requirement_show_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:display');
        $('#activity_requirement_show_link').attr('style', 'display:none');
        var selectType = $('#activity_box_type');
        selectType.val('requirement');
        $('#activity_close_requirement_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:display');
        toggle_activity_box_controls();
    });

    $('#activity_close_requirement_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:none');
        $('#activity_requirement_show_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:none');
        $('#activity_close_requirement_link').attr('style', 'display:none');
    });

    $('#activity_close_story_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:none');
        $('#activity_story_show_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:none');
        $('#activity_close_story_link').attr('style', 'display:none');
    });

    $('#activity_close_question_link').on('click', function () {
        $('#activity_box_form').attr('style', 'display:none');
        $('#activity_question_show_link').attr('style', 'display:display');
        $('#activity_hr_header').attr('style', 'display:none');
        $('#activity_close_question_link').attr('style', 'display:none');
    });

    var defaultOptions = {
        toolbar: {
            'font-styles': false,
            'color': false,
            'emphasis': {
                'small': false
            },
            'blockquote': false,
            'lists': true,
            'html': false,
            'link': false,
            'image': false,
            'smallmodals': false
        }
    };

    $("textarea").each(function (i, elem) {

        var blacksheep = false;

        $.each(elem.classList, function (index, value) {
            if (value == 'dont-show-wysiwyg') {
                blacksheep = true
            }
        });

        if (!blacksheep) {
            $(elem).wysihtml5(defaultOptions);
        }
    });

    $('#activity_box_type').on('change', function () {
        toggle_activity_box_controls();
    });

    $('#activity_box_privacy').on('change', function () {
        var selectType = $('#activity_box_type');
        var selectPrivacy = $('#activity_box_privacy');
        var activityBox = $('#activity_box');
        var publish_button = $('#publish_button');
        if (selectType[0].value != "" && selectPrivacy[0].value != "" && activityBox[0].value.replace(/ /g, '') != "") {
            publish_button.attr('class', 'button button-green-large offset45');
            publish_button.attr('disabled', false);
        } else {
            publish_button.attr('class', 'button button-gray-large offset45');
            publish_button.attr('disabled', true);
        }
    });

    $("input.checkbox-switch").bootstrapSwitch();

    // Javascript to enable link to tab
    var url = document.location.toString();
    if (url.match('#')) {
        $('.nav-tabs a[href=#' + url.split('#')[1] + ']').tab('show');
    }

    $(document).ready(function () {
        var sign_up_dialogue = $("#signup_modal");
        if (!(sign_up_dialogue === undefined || sign_up_dialogue === null)) {
            setTimeout(function () {
                sign_up_dialogue.modal('show');
            }, 6000)
        }
    });

    $(document).ready(function () {
        var sign_up_dialogue = $("#infoModal");
        if (!(sign_up_dialogue === undefined || sign_up_dialogue === null)) {
            setTimeout(function () {
                sign_up_dialogue.modal('show');
            }, 1700)
        }
    });

    $(".row").each(function () {
        trimBrs(this);
    });

    $(".feed-render").each(function () {
        trimBrs(this);
    });

    $("#contact_all_checkbox").click(function () {
        $('[id^="contact_"]').prop('checked', this.checked);
    });

    var successLabelElem = $("#success");

    if (successLabelElem.css('display') != 'none') {
        successLabelElem.fadeOut(1500);
    }

    $('[id^="play"]').click(function () {
        var elementId = this.id;
        var data = elementId.split("__")[2];
        trackClick(data);
        showModalVideoBox(data);
    });

    function showModalVideoBox(data) {
        if ($(window).width() > 768) {
            var vidWidth = '100%';
            var dummyvidWidth = 720;
            var vidHeight = 375; // default
            var splits = data.split("--");
            var video_id = splits[3];
            var type = splits[0];
            var video_source = '';
            if (type == 'yt') {
                video_source = '"//www.youtube.com/embed/' + video_id + '?autoplay=1&amp;controls=0&amp;rel=0&amp;showinfo=0"'
            } else if (type == 'vimeo') {
                video_source = '"//player.vimeo.com/video/' + video_id + '?title=0&amp;autoplay=1&amp;byline=0&amp;portrait=0"'
            } else {
                return;
            }
            var iFrameCode = '<iframe width="' + vidWidth + '" height="' + vidHeight + '" scrolling="no" allowtransparency="true" allowfullscreen="true"  frameborder="0" src=' + video_source + '></iframe>';

            // Replace Modal HTML with iFrame Embed
            var modal = $('#mediaModal');
            modal.find('.modal-body').html(iFrameCode);
            // Set new width of modal window, based on dynamic video content
            modal.on('show.bs.modal', function () {
                // Add video width to left and right padding, to get new width of modal window
                var modalBody = $(this).find('.modal-body');
                var modalDialog = $(this).find('.modal-dialog');
                var newModalWidth = (dummyvidWidth) + parseInt(modalBody.css("padding-left")) + parseInt(modalBody.css("padding-right"));
                newModalWidth += parseInt(modalDialog.css("padding-left")) + parseInt(modalDialog.css("padding-right"));
                newModalWidth += 'px';
                // Set width of modal (Bootstrap 3.0)
                $(this).find('.modal-dialog').css('width', newModalWidth);
            });

            // Open Modal
            modal.modal();
        } else {
            var vidWidth = '100%'; // default
            var vidHeight = '100%'; // default
            var splits = data.split("--");
            var video_id = splits[3];
            var type = splits[0];
            var video_source = '';
            if (type == 'yt') {
                video_source = '"//www.youtube.com/embed/' + video_id + '?autoplay=1&amp;controls=0&amp;rel=0&amp;showinfo=0"'
            } else if (type == 'vimeo') {
                video_source = '"//player.vimeo.com/video/' + video_id + '?title=0&amp;autoplay=1&amp;byline=0&amp;portrait=0"'
            } else {
                return;
            }
            var iFrameCode = '<iframe width="' + vidWidth + '" height="' + vidHeight + '" scrolling="no" allowtransparency="true" allowfullscreen="true"  frameborder="0" src=' + video_source + '></iframe>';

            // Replace Modal HTML with iFrame Embed
            var modal = $('#mediaModal');
            modal.find('.modal-body').html(iFrameCode);
            // Set new width of modal window, based on dynamic video content
            //*** NOT SURE NEED THIS FOR SMARTPHONE ***//
            //modal.on('show.bs.modal', function () {
            // Add video width to left and right padding, to get new width of modal window
            //var modalBody = $(this).find('.modal-body');
            //var modalDialog = $(this).find('.modal-dialog');
            //var newModalWidth = (dummyvidWidth) + parseInt(modalBody.css("padding-left")) + parseInt(modalBody.css("padding-right"));
            //newModalWidth += parseInt(modalDialog.css("padding-left")) + parseInt(modalDialog.css("padding-right"));
            //newModalWidth += 'px';
            // Set width of modal (Bootstrap 3.0)
            //$(this).find('.modal-dialog').css('width', newModalWidth);
            //});

            // Open Modal
            modal.modal();
        }
    }

    $('#mediaModal').on('hidden.bs.modal', function () {
        $('#mediaModal').find('.modal-body').html('');
    });

    $('#user_photo_upload').on('change', function () {
        $('#form_profile_photo').submit();
    });

    $('#article_photo_upload').on('change', function () {
        $('#form_article_photo').submit();
    });

    $("[type='job-label']").selectize({
        create: true,
        sortField: {
            field: 'text'
        },
        onChange: function (value) {
            this["$input"].parents("form").submit();
        }
    });

    $("#work_skills, #course_skills, #intern_skills").selectize({
        persist: false,
        valueField: 'skill',
        labelField: 'skill',
        searchField: ['skill'],
        options: skills,
        delimiter: ',',
        minItems: 1,
        create: function (input) {
            return {
                skill: input
            };
        }
    });

    $("#degree").selectize({
        maxItems: 1,
        persist: false,
        create: true
    });

    $("#major").selectize({
        maxItems: 1,
        persist: false,
        create: true
    });

    $("#minor").selectize({
        maxItems: 1,
        persist: false,
        create: true
    });

    $("#handle").change(function () {
        checkHandle();
    });

});

function checkHandle() {
    handle = $("#handle").val();
    url = "http://" + location.host + "/users/checkhandle/" + handle + ".json";
    $.ajax({
        url: url,
    }).done(function (data) {
        if (data) {
            // handle available. make the class green and set text
            $("#handle").addClass("bg-success");
            $("#handle").removeClass("bg-danger");
            $("#handle_check_response").text("Available").addClass("text-success").removeClass("text-danger");
        } else {
            $("#handle").removeClass("bg-success");
            $("#handle").addClass("bg-danger");
            $("#handle_check_response").text("Un-Available").addClass("text-danger").removeClass("text-success");
        }
    });
}

function toggle_major_select_all(object) {
    if ($(object).is(':checked')) {
        majors_select.setValue(all_majors_string);
    } else {
        majors_select.clear();
    }
}
function showPromoModal() {
    foggyblur();
    var fbShareModal = $('#fbShareModal');
    fbShareModal.modal({backdrop: 'static'})
    fbShareModal.modal('show');
}

function showMeedioriteModal() {
    foggyblur();
    var fbShareModal = $('#meedioriteModal');
    fbShareModal.modal('show');
}

function trackLinkClick(subject_id) {
    $.post('/feed/track/click', {id: subject_id}, function () {
    });
}

function trackSocialChannel(id) {
    $.post('/social_group/track/click', {id: id}, function () {
    });
}

function escape_special_characters(text) {
    if (text === "") {
        return text;
    }
    text.replace(/\\n/g, "\\n")
        .replace(/\\'/g, "\\'")
        .replace(/\\"/g, '\\"')
        .replace(/\\&/g, "\\&")
        .replace(/\\r/g, "\\r")
        .replace(/\\t/g, "\\t")
        .replace(/\\b/g, "\\b")
        .replace(/\\f/g, "\\f");
    return text;
}

function showSignUpModal(timeout) {
    timeout = typeof timeout !== 'undefined' ? timeout : 2500;
    setTimeout(function () {
        var signupModal = $('#signUpModal');
        signupModal.modal({backdrop: 'static'});
        if (signupModal) {
            signupModal.modal('show');
        }
    }, timeout);
}

function showSocialShareModal() {
    var social_share = $('#socialShareModal');
    if (social_share) {
        foggyblur();
        social_share.modal('show');
    }
}

function showWelcomeModal() {
    var welcome_modal = $("#welcomeModal");
    welcome_modal.modal('show');
    return true;
}

function toggle_public_post(object) {

    if ($(object).is(':checked')) {
        $(".consumer-selectize").hide();
        $("#privacy").hide();
    } else {
        $(".consumer-selectize").show();
    }
}

function hideSearchBar() {
    $('#search_icon').hide();
    var search_bar = $('#q');
    search_bar.show("slow", function () {
        // Animation complete.
    });
    search_bar.focus();
}

function getUrls(text) {
    var source = (text || '').toString();
    var urlArray = [];
    var matchArray;

    // Regular expression to find FTP, HTTP(S) and email URLs.
    var regexToken = /(((ftp|https?):\/\/)[\-\w@:%_\+.~#?,&\/\/=]+)|((mailto:)?[_.\w-]+@([\w][\w\-]+\.)+[a-zA-Z]{2,3})/g;

    // Iterate through any URLs in the text.
    while ((matchArray = regexToken.exec(source)) !== null) {
        var token = matchArray[0];
        urlArray.push(token);
    }

    return urlArray;
}

function getNoCheckBoxesSelected() {
    var count = 0;
    $('#applicants_table input:checked').each(function () {
        count++;
    });
    return count;
}

// Load the IFrame Player API code asynchronously.
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/player_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

(function () {
    var w = window;
    var ic = w.Intercom;
    if (typeof ic === "function") {
        ic('reattach_activator');
        var intercomSettings = null;
        ic('update', intercomSettings);
    } else {
        var d = document;
        var i = function () {
            i.c(arguments)
        };
        i.q = [];
        i.c = function (args) {
            i.q.push(args)
        };
        w.Intercom = i;
        function l() {
            var s = d.createElement('script');
            s.type = 'text/javascript';
            s.async = true;
            s.src = 'https://static.intercomcdn.com/intercom.v1.js';
            var x = d.getElementsByTagName('script')[0];
            x.parentNode.insertBefore(s, x);
        }

        if (w.attachEvent) {
            w.attachEvent('onload', l);
        } else {
            w.addEventListener('load', l, false);
        }
    }
})();

function isBrOrWhitespace(node) {
    return node && ( (node.nodeType == 1 && node.nodeName.toLowerCase() == "br") ||
        (node.nodeType == 3 && /^\s*$/.test(node.nodeValue) ) );
}

function trimBrs(node) {
    while (isBrOrWhitespace(node.firstChild)) {
        node.removeChild(node.firstChild);
    }
    while (isBrOrWhitespace(node.lastChild)) {
        node.removeChild(node.lastChild);
    }
}

function toggle_select_majors(object, major_id_type) {
    if ($(object).is(':checked')) {
        var sum_majors = majors_select.getValue().concat(major_type_hash[major_id_type]);
        majors_select.setValue(sum_majors);
    } else {
        var final_majors = majors_select.getValue();
        final_majors = final_majors.filter(function (el) {
            return major_type_hash[major_id_type].indexOf(el) < 0;
        });
        majors_select.setValue(final_majors);
    }
}

function toggle_activity_box_controls() {
    var selectType = $('#activity_box_type');
    var selectPrivacy = $('#activity_box_privacy');
    var activityBox = $('#activity_box');
    var title_box = $('#activity_title_box');

    var publish_button = $('#publish_button');
    var activityInfo = $('#activity_info');
    if (selectType[0].value == "question") {
        title_box.show();
        title_box.attr('placeholder', 'Title — Ex: \"How difficult is course X under professor Y?\"');
        activityBox.attr('placeholder', 'Describe your question.. ')
    } else if (selectType[0].value == "requirement") {
        title_box.show();
        title_box.attr('placeholder', 'Title — Ex: \"Looking for a project partner for CS 256\"');
        activityBox.attr('placeholder', 'Describe your requirement..')
    } else if (selectType[0].value == "story") {
        title_box.show();
        title_box.attr('placeholder', 'Title — Ex: \"My internship experience at company X\"');
        activityBox.attr('placeholder', 'Describe your story.. (Ex: Last summer I had this awesome experience at X..)')
    } else if (selectType[0].value == "") {
        title_box.attr('style', 'display:none');
        activityBox.attr('placeholder', 'Ask questions, post requirements or share experiences! (You can use links or #hashtags)');
    }
    if (selectType[0].value != "" && selectPrivacy[0].value != "" && activityBox[0].value.replace(/ /g, '') != "") {
        publish_button.attr('class', 'button button-green-large offset45');
        publish_button.attr('disabled', false);
    } else {
        publish_button.attr('class', 'button button-gray-large offset45');
        publish_button.attr('disabled', true);
    }
}

function deactivate_account_toggle(target) {
    if (target.checked) {
        $('#deactivateAccountModal').modal('toggle');
        $('#profile_deactivate_confirmation').show();
    } else {
        $('#profile_deactivate_confirmation').hide();
    }
}

function confirm_deactivate(handle, target) {
    if (handle === null || handle === undefined) {
        return;
    }
    data = {key: 'deactivate', value: true};
    ajaxUpdateSettings(handle, data);
}

function redeem_meeds(handle, target) {
    if (handle === null || handle === undefined) {
        return;
    }
    data = {key: 'redeem_meeds', value: true};
    ajaxUpdateSettings(handle, data);
}

function send_message(object) {
    job_hash = $(object).attr('job_id');
    company_name = $(object).attr('name');
    recruiter_message_modal = $('#messageRecruiterModal');
    id_field = recruiter_message_modal.find("#form_message_id_hidden_id");
    insight_field = recruiter_message_modal.find("#form_message_id_hidden_insightToken");
    company_field = recruiter_message_modal.find("[type = 'company-name']");
    id_field.val(job_hash);
    company_field.text(company_name);
    recruiter_message_modal.modal('toggle');
}

function forward_job(object) {
    job_hash = $(object).attr('job_id');
    forward_job_modal = $('#forwardJobModal');
    id_field = forward_job_modal.find("#form_message_id_hidden_id");
    id_field.val(job_hash);
    forward_job_modal.modal('toggle');
}
$(document).ajaxSend(function (event, request, settings) {
    $('#loading-indicator').show();
});

$(document).ajaxComplete(function (event, request, settings) {
    $('#loading-indicator').hide();
});

function onPhotoUpload(form_id, event) {
    if (form_id == 'logo_upload_form') {
        $.each(event.fpfiles, function (index, element) {
            if (element != 'undefined') {
                $("#image_profile_photo").attr('src', element.url);
            }
        });
        $("#logo_upload_form").submit();
    }

}


function onFileUpload(event) {
    $.each(event.fpfiles, function (index, element) {
        if (element != 'undefined') {
            $("#file_url").attr('src', element.url);
        }
    });
    $("#file_upload_form").submit();

}


$(function () {
    var hash = window.location.hash;
    hash && $('ul.nav a[href="' + hash + '"]').tab('show');
    if (hash == '#jobs') {
        loadJobs('all');
    }

    $('.nav-tabs a').click(function (e) {
        $(this).tab('show');
        var scrollmem = $('body').scrollTop();
        window.location.hash = this.hash;
        $('html,body').scrollTop(scrollmem);
    });
});

function loadGalleria() {
    var gallery = $('.galleria');
    if (gallery.length) {
        console.log(gallery.length);
        renderGalleria();
    }
}

function loadGalleriaAjax() {

    setTimeout(function () {
        var gallery = $('.galleria');
        if (gallery.length) {
            renderGalleria();
        }
    }, 2000);
}


function renderGalleria() {
    Galleria.loadTheme('https://cdn.getmeed.com/assets/galleria/themes/twelve/galleria.twelve.min.js');
    $('.galleria').galleria({
        imageCrop: true,
        dataSource: image_data,
        transition: 'fadeslide',
        responsive: true,
        height: 0.5625,
        autoplay: true,
    });

}

$(window).bind("load", function () {
    // Running user guide if required after 2 secs since page load
    showUserGuide();
});

function scrollToShow(element_position, delay) {
    // check if the element is visible first
    current_position = $(window).scrollTop();
    if (current_position < element_position && element_position < (current_position + window.innerHeight)) {
        // already visible no need to scroll
        return false;
    }
    // default value for delay
    delay = delay || 1000;
    offset = element_position - current_position - (window.innerHeight / 2);
    $('html,body').delay(2000).animate({scrollTop: offset}, delay);
    return true;
}

function showUserGuide() {
    // check the page.
    pathName = window.location.pathname;
    search = window.location.search;
    root = pathName.split('/')[1];
    scroll = false;
    switch (root) {
        case "company":
            if (!$.cookie("company-user-guide")) {
                // show the guide
                $('body').chardinJs('start');
                $.cookie("company-user-guide", true);
                scroll = true;
            }
            break;
        case "job":
            if (!$.cookie("job-user-guide")) {
                // show the guide
                $('body').chardinJs('start');
                $.cookie("job-user-guide", true);
                scroll = true;
            }
            break;
        case "home":
            if (!$.cookie("home-user-guide")) {
                // show the guide
                $('body').chardinJs('start');
                $.cookie("home-user-guide", true);
                scroll = true;
            }
    }
    if (search.indexOf("edit=true") > 0) {
        if (!$.cookie("profile-references-guide")) {
            // show the guide
            $('body').chardinJs('start');
            $.cookie("profile-references-guide", true);
            scroll = true;
        }
    }
    // If scroll get the first element and scroll so that the element is in the center
    if (scroll) {
        top_values = $.map($("[data-intro]"), function (i, j) {
            return $(i).offset().top;
        }).sort();
        $.each(top_values, function (index, element_position) {
            // first scroll to that position
            if (scrollToShow(element_position, 1000)) {
                // since there is scrolling wait for some time
            }
        });
    }
}

function setGetParameter(paramName, paramValue) {
    var url = window.location.href;
    if (url.indexOf(paramName + "=") >= 0) {
        var prefix = url.substring(0, url.indexOf(paramName));
        var suffix = url.substring(url.indexOf(paramName));
        suffix = suffix.substring(suffix.indexOf("=") + 1);
        suffix = (suffix.indexOf("&") >= 0) ? suffix.substring(suffix.indexOf("&")) : "";
        url = prefix + paramName + "=" + paramValue + suffix;
    }
    else {
        if (url.indexOf("?") < 0)
            url += "?" + paramName + "=" + paramValue;
        else
            url += "&" + paramName + "=" + paramValue;
    }
    window.location.href = url;
}