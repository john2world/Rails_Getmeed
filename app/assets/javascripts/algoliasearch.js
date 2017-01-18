function remove_em_tags(taggedText) {
    var div = document.createElement("div");
    div.innerHTML = taggedText;
    return div.textContent || div.innerText || "";
}

function getLandingLink(handle, type) {
    handle = remove_em_tags(handle);
    if (type == 'job') {
        return '/job/' + handle;
    }

    return '/' + handle;

}
function searchCallback(success, content) {
    var hits = $('#hits');
    if (content.query != $("#q").val()) {
        // do not take out-dated answers into account
        return;
    }

    if (content.hits.length == 0) {
        // no results
        hits.empty();
        return;
    }

    // Scan all hits and display them
    var html = '';
    html += '<table>';
    for (var i = 0; i < content.hits.length; ++i) {
        var hit = content.hits[i];

        // For example, display all properties that have at least
        // one highlighted word (matchLevel = full or partial)
        var type = hit._highlightResult['type'];
        var handle = hit._highlightResult['handle'];
        html += '<tr class="hit attribute" onclick="document.location=\'' + getLandingLink(handle.value, type.value) +'\';">';
        if (type != undefined && handle != undefined) {
            display(hit);
        }
        hits.html(html);
        html += '</tr>';
        html += '<tr style="height: 10px !important;background-color: #FFFFFF;">';
        html += '<td colspan="3"></td>';
        html += '</tr>';
        html += '<tr style="height: 10px !important;background-color: #FFFFFF;">';
        html += '<td colspan="3"></td>';
        html += '</tr>';
    }
    html += '</table>';


    function display(hit) {
        var name = hit._highlightResult['name'].value.toUpperCase();
        if (name != undefined) {
            var picture = hit._highlightResult['picture'];
            html += '<td>';
            if (picture != undefined) {
                html += '<img src="' + remove_em_tags(picture.value) + '"class="image-small">';
            } else {
                html += '<img src="http://res.cloudinary.com/resume/image/upload/c_scale,w_75/v1405632414/user_male4-128_q1iypj.png" class="image-small">';
            }
            html += '</td>';
            html += '<td>';
            html += '<span>' + "</span>" + '<span class="search-title">' + name + '</span>';
            html += "</div>";
            html += '<div style= "margin-left: 1%;">';
            for (var propertyName in hit._highlightResult) {

                if (propertyName == 'major') {
                    var major = hit._highlightResult[propertyName];
                    var university = hit._highlightResult['university'];
                    if (major != undefined && university != undefined) {
                        html += '<div>' + major.value +  ', ' + '</div>'  + '<div>' + university.value + "</div>";
                    }
                }

                if (propertyName == 'coursework') {
                    hit._highlightResult[propertyName].forEach(function (course) {
                        if (course.matchLevel == 'full') {
                            html += '<div><span class="search-info-text">' + 'Coursework: </span>' + course.value + '</div>';
                        }
                    });
                }

                if (propertyName == 'internships') {
                    hit._highlightResult[propertyName].forEach(function (internship) {
                        if (internship.matchLevel == 'full') {
                            html += '<div><span class="search-info-text">' + 'Internship: ' + "</span>" + internship.value + '</div>';
                        }
                    });
                }

                if (propertyName == 'experience') {
                    hit._highlightResult[propertyName].forEach(function (experience) {
                        if (experience.matchLevel == 'full') {
                            html += '<div><span class="search-info-text">' + 'Experience: ' + "</span>" + experience.value + '</div>';
                        }
                    });
                }

                if (propertyName == 'skills') {
                    hit._highlightResult[propertyName].forEach(function (skill) {
                        if (skill.matchLevel == 'full') {
                            html += '<div><span class="search-info-text">' + 'Skill: ' + "</span>" + skill.value + '</div>';
                        }
                    });
                }

            }
            html += '</td>';
        }
    }
}

$(document).ready(function () {
    var $inputfield = $("#q");
    var hits = $("#hits");

    // Replace the following values by your ApplicationID and ApiKey.
    var algolia = new AlgoliaSearch('HUQVU8F87J', 'd9d3382a1a7c6473104fb3a64d87c179');
    // replace YourIndexName by the name of the index you want to query.
    var index = algolia.initIndex('Search');


    $inputfield.keyup(function () {
        hits.show();
        index.search($inputfield.val(), searchCallback);
        if ($inputfield.val() == '') {
            hits.hide();
        }
    }).focus(function () {
        hits.show();
        if ($inputfield.val() != '') {
            index.search($inputfield.val(), searchCallback);
        } else {
            hits.hide();
        }
    }).closest('form').on('submit', function () {
        // on form submit, store the query string in the anchor
        location.replace('#q=' + encodeURIComponent($inputfield.val()));
        return false;
    }).focusout(function () {
    });


    // check if there is a query in the anchor: http://example.org/#q=my+query
    if (location.hash && location.hash.indexOf('#q=') === 0) {
        var q = decodeURIComponent(location.hash.substring(3));
        $inputfield.val(q).trigger('keyup');
    }
});



$(document).mouseup(function (e)
{
    var container = $("#hits");

    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        container.hide();
    }
});