function labelAutocomplete(input, findUrl, ajaxSpinnerSelector, selectedCallback) {
    var url = findUrl;

    function showSpinner() {
        $(ajaxSpinnerSelector).removeClass('disabled');
    }
    function hideSpinner() {
        $(ajaxSpinnerSelector).addClass('disabled');
    }

    var bh = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        identify: function(obj) { return obj.category + obj.value; },
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
        display: 'value'
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