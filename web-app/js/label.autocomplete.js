function labelAutocomplete(input, findUrl, ajaxSpinnerSelector, selectedCallback, listTextKey) {
    var url = findUrl;

    function showSpinner() {
        $(ajaxSpinnerSelector).removeClass('hidden');
    }
    function hideSpinner() {
        $(ajaxSpinnerSelector).addClass('hidden');
    }

    var bh = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace(listTextKey || 'value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        identify: function(obj) { return obj.category + obj[listTextKey || 'value']; },
        remote: {
            url: url + '?term=%QUERY',
            wildcard: '%QUERY'
        }
    });

    var $input = $(input);
    $input.typeahead({
        minLength: 2
    }, {
        source: bh,
        async: true,
        display: listTextKey || 'value'
    });

    $input.on('typeahead:select', function(e, obj) {
        selectedCallback(obj);
    });
    $input.on('typeahead:asyncrequest', function(e) {
       showSpinner();
    });
    $input.on('typeahead:asynccancel, typeahead:asyncreceive', function(e) {
        hideSpinner();
    })
}