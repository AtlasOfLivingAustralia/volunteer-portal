var bvp = {};

(function(bvplib) {

    bvplib.showModal = function(options) {

        var opts = {
            backdrop: options.backdrop ? options.backdrop : true,
            keyboard: options.keyboard ? options.keyboard: true,
            url: options.url ? options.url : false,
            id: options.id ? options.id : 'modal_element_id',
            height: options.height ? options.height : 500,
            width: options.width ? options.width : 600,
            title: options.title ? options.title : 'Modal Title',
            hideHeader: options.hideHeader ? options.hideHeader : false,
            onClose: options.onClose ? options.onClose : null,
            onShown: options.onShown ? options.onShown : null
        };

        var html = "<div id='" + opts.id + "' class='modal hide' role='dialog' aria-labelledby='modal_label_" + opts.id + "' aria-hidden='true' style='width: " + opts.width + "px; margin-left: -" + opts.width / 2 + "px;overflow: hidden'>";
        if (!opts.hideHeader) {
            html += "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button><h3 id='modal_label_" + opts.id + "'>" + opts.title + "</h3></div>";
        }
        html += "<div class='modal-body' style='max-height: " + opts.height + "px'>Loading...</div></div>";

        $("body").append(html);

        var selector = "#" + opts.id;

        $(selector).on("hidden", function() {
            $(selector).remove();
            if (opts.onClose) {
                opts.onClose();
            }
        });

        $(selector).on("shown", function() {
            if (opts.onShown) {
                opts.onShown();
            }
        });

        $(selector).modal({
            remote: opts.url,
            keyboard: opts.keyboard,
            backdrop: opts.backdrop
        });

    };

    bvplib.hideModal = function() {
        $("#modal_element_id").modal('hide');
    };

    bvplib.htmlEscape = function(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    };

    bvplib.htmlUnescape = function(value) {
        return String(value)
            .replace(/&quot;/g, '"')
            .replace(/&#39;/g, "'")
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&amp;/g, '&');
    };

    bvplib.bindTooltips = function(selector, width) {

        if (!selector) {
            selector = "a.fieldHelp";
        }
        if (!width) {
            width = 300;
        }
        // Context sensitive help popups
        $(selector).qtip({
            tip: true,
            position: {
                corner: {
                    target: 'topMiddle',
                    tooltip: 'bottomRight'
                }
            },
            style: {
                width: width,
                padding: 8,
                background: 'white', //'#f0f0f0',
                color: 'black',
                textAlign: 'left',
                border: {
                    width: 4,
                    radius: 5,
                    color: '#E66542'// '#E66542' '#DD3102'
                },
                tip: 'bottomRight',
                name: 'light' // Inherit the rest of the attributes from the preset light style
            }
        }).bind('click', function(e){ e.preventDefault(); return false; });
    }

})(bvp);



