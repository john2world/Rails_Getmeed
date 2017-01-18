function split( val ) {
    return val.split( /,\s*/ );
}
function extractLast( term ) {
    return split( term ).pop();
}

function getData(name) {
    var json = (function() {
        var json = null;
        $.ajax({
            'async': false,
            'global': false,
            'url': name,
            'dataType': "json",
            'success': function (data) {
                json = data;
            }
        });
        return json;
    })();
    return json;
}

// Adding Skills

$(function() {
    var skills = getData('/assets/skills.json');
    // require('/assets/skills.json');
    $("[data-provide='typeahead'],.skills")
        // don't navigate away from the field on tab when selecting an item
        .bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                $( this ).data( "ui-autocomplete" ).menu.active ) {
                event.preventDefault();
            }
        });
});