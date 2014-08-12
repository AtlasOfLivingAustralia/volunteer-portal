<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'institutions.label', default: 'Institution')}"/>
        <title><g:message code="default.list.label" args="[entityName]"/></title>
        <style type="text/css">
            tr.institution-details-row, .institution-details-row td {
                border-top: none;
            }
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
                <div class="span12">
                    <table class="table table-condensed" style="border: 1px solid gainsboro">
                        <colgroup>
                            <col style="width:165px"/>
                        </colgroup>
                        <thead>
                            <tr>
                                <td>
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

                                <td colspan="2" style="text-align: right;max-width: 400px">
                                    <span>
                                        <a style="vertical-align: middle;" href="#" class="fieldHelp" title="Enter search text here to find institutions"><span class="help-container">&nbsp;</span></a>
                                    </span>
                                    <g:textField id="searchbox" value="${params.q}" name="searchbox" />
                                    <button class="btn" id="btnSearch">Search</button>
                                </td>
                            </tr>
                            <tr>
                                <th><a href="?sort=name&order=${params.sort == 'name' && params.order != 'desc' ? 'desc' : 'asc'}&offset=0&q=${params.q}" class="btn ${params.sort == 'name' ? 'active' : ''}">Name</a></th>
                                <th></th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <g:each in="${institutions}" status="i" var="inst">
                                <tr>
                                    <th colspan="2" style="border-bottom: none">
                                        <h3><a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">${inst.name}</a>&nbsp;<small>${inst.acronym}</small></h3>
                                    </th>
                                    <th style="text-align: right; width: 100px">
                                        <cl:ifInstitutionAdmin institution="${inst}">
                                            <a class="btn btn-warning btn-small" href="${createLink(controller:'institutionAdmin', action:'edit', id: inst.id)}"><i class="icon-cog icon-white"></i>&nbsp;Settings</a>
                                        </cl:ifInstitutionAdmin>
                                    </th>
                                </tr>
                                <tr class="institution-details-row">

                                    <td style="width: 300px">
                                        <a href="${createLink(controller: 'institution', action: 'index', id: inst.id)}">
                                            <img src="<cl:institutionBannerUrl id="${inst.id}" />"/>
                                        </a>
                                    </td>

                                    <td colspan="2">
                                        <div class="row-fluid">
                                            <div class="span12">
                                                <markdown:renderHtml>${inst.shortDescription}</markdown:renderHtml>
                                            </div>
                                        </div>
                                        <div class="row-fluid">
                                            <div class="span12">
                                                <g:set var="projectCount" value="${projectCounts[inst] ?: 0}" />
                                                <strong>${projectCount} Expedition${projectCount == 1 ? '' : 's'}</strong>

                                            </div>
                                        </div>
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
        </div>
    </body>
</html>
