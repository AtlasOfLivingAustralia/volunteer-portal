<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="app.version" content="${g.meta(name:'app.version')}"/>
        <meta name="app.build" content="${g.meta(name:'app.build')}"/>
        <meta name="description" content="Atlas of Living Australia"/>
        <meta name="author" content="Atlas of Living Australia">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title><g:layoutTitle /></title>

        <link rel="icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">
        <link rel="shortcut icon" type="image/x-icon" href="http://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico">

        <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'bootstrap.css', plugin:'ala-web-theme')}">
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bootstrap-responsive.css', plugin:'ala-web-theme')}">
        %{--<link rel="stylesheet" type="text/css" media="screen" href="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/css/jquery.autocomplete.css" />--}%
        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'css', file: 'bvp-bootstrap.css')}" de>

        <script type="text/javascript" src="${grailsApplication.config.ala.baseURL?:'http://www.ala.org.au'}/wp-content/themes/ala2011/scripts/html5.js"></script>

        <r:require module="jquery-ui" />
        <r:require module="qtip" />

        <link rel="stylesheet" type="text/css" media="screen" href="${resource(dir: 'js/jquery-ui-1.9.1.custom/css/smoothness', file: 'jquery-ui-1.9.1.custom.min.css')}"/>
        <link href="http://www.ala.org.au/wp-content/themes/ala2011/css/jquery.autocomplete.css" type="text/css" rel="stylesheet" media="screen, projection" />

        <r:require module="bootstrap-js" />

        <g:layoutHead />
        <r:layoutResources/>

        <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->

        <r:script>
            // initialise plugins
            $(document).ready(function() {

                // show warning if using IE6
                if ($.browser.msie && $.browser.version.slice(0,1) == '6') {
                    $('#header').prepend($('<div style="text-align:center;color:red;">WARNING: This page is not compatible with IE6.' +
                            ' Many functions will still work but layout and image transparency will be disrupted.</div>'));
                }

                $("form#search-form-2011 input#search-2011, form#search-inpage input#search").autocomplete({
                    disabled: false,
                    minLength: 3,
                    delay: 200,
                    select: function(event, ui) { },
                    source: function(request, response) {
                        $.ajax('http://bie.ala.org.au/search/auto.jsonp?limit=100&q=' + request.term, {dataType:'jsonp'}).done(function(data) {
                            var rows = new Array();
                            if (data.autoCompleteList) {
                                var list = data.autoCompleteList;
                                for (var i = 0; i < list.length; i++) {
                                    rows[i] = {
                                        value: list[i].matchedNames[0],
                                        label: list[i].matchedNames[0],
                                        data: list[i]
                                    };
                                }
                            }

                            if (response) {
                                response(rows);
                            }
                        });
                    }
                });

                $("th.sortable > a").addClass("btn")
                $("th.sorted > a").addClass("active")

            });

            function showModal(options) {

                var opts = {
                    url: options.url ? options.url : false,
                    id: options.id ? options.id : 'modal_element_id',
                    height: options.height ? options.height : 500,
                    width: options.width ? options.width : 600,
                    title: options.title ? options.title : 'Modal Title',
                    hideHeader: options.hideHeader ? options.hideHeader : false,
                    onClose: options.onClose ? options.onClose : null,
                    onShown: options.onShown ? options.onShown : null
                }

                var html = "<div id='" + opts.id + "' class='modal hide fade' role='dialog' aria-labelledby='modal_label_" + opts.id + "' aria-hidden='true' style='width: " + opts.width + "px; margin-left: -" + opts.width / 2 + "px;overflow: hidden'>";
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
                    remote: opts.url
                });
            }

            function hideModal() {
                $("#modal_element_id").modal('hide');
            }

            function htmlEscape(str) {
                return String(str)
                        .replace(/&/g, '&amp;')
                        .replace(/"/g, '&quot;')
                        .replace(/'/g, '&#39;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;');
            }

            function htmlUnescape(value) {
                return String(value)
                    .replace(/&quot;/g, '"')
                    .replace(/&#39;/g, "'")
                    .replace(/&lt;/g, '<')
                    .replace(/&gt;/g, '>')
                    .replace(/&amp;/g, '&');
            }

        </r:script>
    </head>
    <body class="${pageProperty(name:'body.class')}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">

        <hf:banner logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"/>

        <cl:navbar selected="${pageProperty(name:'page.selectedNavItem')}" />

        %{--<hf:menu/>--}%

        <g:set var="containerClass" value="container"/>
        <g:if test="${pageProperty(name:'page.useFluidLayout')}">
            <g:set var="containerClass" value="container-fluid"/>
        </g:if>

        <header id="page-header">
            <div class="container">
                <cl:messages />
                <hgroup>
                    <g:pageProperty name="page.page-header" />
                </hgroup>
            </div>
        </header>

        <div class="${containerClass}" id="main-content">
            <g:layoutBody />
        </div><!--/.container-->

    <hf:footer/>

    <script type="text/javascript">
        var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
        document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>

    <script type="text/javascript">
        var pageTracker = _gat._getTracker("UA-4355440-1");
        pageTracker._initData();
        pageTracker._trackPageview();
    </script>

    <!-- JS resources-->
    <r:layoutResources/>

    </body>
</html>