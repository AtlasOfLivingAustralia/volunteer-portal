function labelAutocomplete(input, findUrl, ajaxSpinnerSelector, selectedCallback) {
    var url = findUrl;

    function showSpinner() {
        $(ajaxSpinnerSelector).removeClass('disabled');
    }
    function hideSpinner() {
        $(ajaxSpinnerSelector).addClass('disabled');
    }

    function typeahead(query, process) {
        showSpinner();
        $.getJSON(url, {term: query})
            .done(function(data) {
                var toString = function() {
                    return JSON.stringify(this);
                };
                for (var i = 0; i < data.length; ++i) {
                    data[i].toString = toString;
                }
                process(data);
            })
            .fail(function(e) {
                ajaxFail();
                process([]);
            })
            .always(hideSpinner);
    }

    function ajaxFail() {
        alert("Failed to get label values, please refresh and try again");
    }

    function typeaheadHighlighter(item) {
        var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
        return item.value.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
                return '<strong>' + match + '</strong>';
            }) + ' (' + item.category.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) { return '<strong>' + query + '</strong>'; }) + ')';
    }

    function typeaheadSorter(items) {
        return items;
    }

    function typeaheadMatcher(item) {
        return true;
    }

    function typeaheadUpdate(item) {
        var obj = JSON.parse(item);
        showSpinner();
        $.ajax(updateUrl, {type: 'POST', data: { id: obj.userId }})
            .done(function(data) {
                $( "<li>" )
                    .append(
                    $( "<span>" )
                        .text(obj.displayName)
                )
                    .append(
                    $( "<i>" )
                        .attr("data-user-id", obj.userId)
                        .addClass("icon-remove")
                )
                    .addClass("user")
                    .appendTo(
                    $( "#user-list" )
                );
            })
            .fail(ajaxFail)
            .always(hideSpinner);
        return null;
    }

    //function onDeleteClick(e) {
    //    showSpinner();
    //    $.ajax(deleteUrl, {type: 'POST', data: { id: e.target.dataset.userId }})
    //        .done(function (data) {
    //            var t = $(e.target);
    //            var p = t.parent("li");
    //
    //            p.remove();
    //        })
    //        .fail(ajaxFail)
    //        .always(hideSpinner);
    //}

    $(input).typeahead({
        source: typeahead,
        minLength: 2,
        highlighter: typeaheadHighlighter,
        matcher: typeaheadMatcher,
        sorter: typeaheadSorter,
        updater: selectedCallback
    });
    //$('#user-list').on('click', 'li.user i.icon-remove', onDeleteClick);
}