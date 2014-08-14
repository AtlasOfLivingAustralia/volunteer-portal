function setupInstitutionAutocomplete(jqElement, idFieldSelector, iconSelector, linkSelector, institutions, nameToId, instBaseUrl) {
    var inputElement = $(jqElement);

    function onAutocompleteSelect(event, ui) {
        var idField = $(idFieldSelector);
        var ownerId;
        if (ui && ui.item && nameToId[ui.item.label]) {
            ownerId = nameToId[ui.item.label];
            idField.val(ownerId);
        } else if (event && event.target && event.target.value ) {
            ownerId = nameToId[event.target.value];
            idField.val(ownerId);
        } else {
            idField.val('');
        }
        showHideIcon();
    }

    function showHideIcon() {
        var icon = $(iconSelector);
        var linked = $(idFieldSelector).val();
        if (linked) {
            icon.removeClass('hidden');
            $(linkSelector).attr('href', instBaseUrl + '/' + linked);
        } else {
            icon.addClass('hidden');
        }
    }

    var autoCompleteOptions = {
        change: onAutocompleteSelect,
        disabled: false,
        minLength: 1,
        delay: 200,
        select: onAutocompleteSelect,
        source: institutions
    };
    inputElement.change(onAutocompleteSelect)
    inputElement.autocomplete(autoCompleteOptions);
    showHideIcon();
}