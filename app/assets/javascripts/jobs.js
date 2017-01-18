$(document).on('change', '[id^="job_status_ddn_"]', function(){
    var value_literals = this.value.split("_");
    var handle = value_literals[0];
    var job_id = value_literals[1];
    var status = value_literals[2];
    var url = '/job/app/'+ handle + '/stats.json';
    var params = '?job_id=' + job_id + '&status=' + status;
    var full_url = url + params;
    ajaxOnUrl(full_url);
});

function toggle_download_button(flag){
    if (flag) {
        $('#download_bundle_button').attr('style', 'display:visible');
    } else {
        $('#download_bundle_button').attr('style', 'display:none');
    }
}

function loadJobs(position){
    $('#' + position + '_jobs').html('<div class="any-center"><img id="loader-img" alt="" src="https://res.cloudinary.com/resume/image/upload/v1441358516/713_anrrgc.gif" width="100" height="100" align="center" /> <div class="info-text-large-center" style="font-size: 24px;"> Personalizing ... </div></div>');
    var url = '/jobs/load';
    if (position != ''){
        url = url + '?position='+ position
    }
    $.ajax({
        type: 'POST',
        url: url,
        success: function (response) {
            if (response.success) {
                $(".consumer-selectize").selectize();
            }
        }
    });
}


