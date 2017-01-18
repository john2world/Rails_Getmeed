function loadFeed(position) {
    $('#' + position + '_feed').html('<div class="any-center"><img id="loader-img" alt="" src="https://res.cloudinary.com/resume/image/upload/v1441358516/713_anrrgc.gif" width="100" height="100" align="center" /> <div class="info-text-large-center" style="font-size: 24px;"> Personalizing ... </div></div>');
    var url = '/feed/load';
    if (position != '') {
        url = url + '?position=' + position;
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


function loadCompanyFeed(company_id, position) {
    $('#company_feed').html('<div class="any-center"><img id="loader-img" alt="" src="https://res.cloudinary.com/resume/image/upload/v1441358516/713_anrrgc.gif" width="100" height="100" align="center" /> <div class="info-text-large-center" style="font-size: 24px;"> Personalizing ... </div></div>');
    var url = '/feed/' + company_id + '/load?position=' + position;
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

