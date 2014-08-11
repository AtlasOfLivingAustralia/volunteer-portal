<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'institutions.label', default: 'Institution')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
        <style type="text/css">
        </style>

        <r:script>

            $(document).ready(function() {

                $("#searchbox").keydown(function(e) {
                    if (e.keyCode ==13) {
                        doSearch();
                    }
                });

                $("#btnSearch").click(function(e) {
                    e.preventDefault();
                    doSearch();
                });

                $("a.fieldHelp").qtip({
                    tip: true,
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomLeft'
                        }
                    },
                    style: {
                        width: 400,
                        padding: 8,
                        background: 'white', //'#f0f0f0',
                        color: 'black',
                        textAlign: 'left',
                        border: {
                            width: 4,
                            radius: 5,
                            color: '#E66542'// '#E66542' '#DD3102'
                        },
                        tip: 'bottomLeft',
                        name: 'light' // Inherit the rest of the attributes from the preset light style
                    }
                }).bind('click', function(e) {
                    e.preventDefault();
                    return false;
                });

                $("#searchbox").focus();

            });

            function doSearch() {
                var q = $("#searchbox").val();
                var url = "${createLink(controller: 'institution',action:'list')}?mode=${params.mode}&q=" + encodeURIComponent(q);
                window.location = url;
            }

        </r:script>
    </head>

    <body>

        <cl:headerContent title="${message(code:'default.institutionlist.label', default: "Institutions")}" selectedNavItem="institutions"/>

        <div id="content">
            <div class="row">

                <table class="table table-condensed" style="border: 1px solid gainsboro">
                    <colgroup>
                        <col style="width:165px"/>
                    </colgroup>
                    <thead>
                        <tr>
                            <td colspan="3">
                                <g:if test="${params.q}">
                                    <h4>
                                        <g:if test="${institutions}">
                                            ${totalInstitutions} matching institutions
                                        </g:if>
                                        <g:else>
                                            No matching institutions
                                        </g:else>
                                    </h4>
                                </g:if>
                            </td>
                            <td colspan="2" style="text-align: right">
                                <span>
                                    <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to find institutions"><span class="help-container">&nbsp;</span></a>
                                </span>
                                <g:textField id="searchbox" value="${params.q}" name="searchbox" />
                                <button class="btn" id="btnSearch">Search</button>
                            </td>
                        </tr>
                        <tr>
                            <th><a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'name' ? 'active' : ''}">Name</a></th>
                        </tr>
                    </thead>
                    <tbody>
                        <g:each in="${institutions}" status="i" var="inst">
                            <tr>
                                <th colspan="4" style="border-bottom: none">
                                    <h3><a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">${inst.name}</a></h3>
                                </th>
                            </tr>
                            <tr style="border: none">

                                <td style="border-top: none">
                                    <a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">
                                        <img src="<cl:institutionBannerUrl id="${inst.id}" />" width="147" height="81"/>
                                    </a>
                                </td>

                                <td style="border-top: none">
                                </td>


                                <td style="border-top: none" class="bold centertext"></td>

                                <td style="border-top: none"></td>

                                <td style="border-top: none" class="type">
                                </td>

                            </tr>
                        </g:each>
                    </tbody>
                </table>

                <div class="pagination">
                    <g:paginate total="${totalInstitutions}" prev="" next="" params="${[q:params.q]}" />
                </div>
            </div>
        </div>
    </body>
</html>
