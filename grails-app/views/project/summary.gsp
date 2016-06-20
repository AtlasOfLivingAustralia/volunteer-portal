<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-main"/>
    <title><cl:pageTitle title="${(stringInstanceMap.project ?: 'Atlas of Living Australia')}"/></title>
</head>

<body class="content">

<cl:headerContent title="${message(code: 'project.summary.label', default: "Expedition Summary - {0}", args: [stringInstanceMap.project])}"
                  selectedNavItem="expeditions">
</cl:headerContent>

<section class="main-content">
    <div class="container">
    <div class="row">
        <div class="span-sm-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <dl>
                        <g:each in="${stringInstanceMap.entrySet()}" var="entry">
                            <dt>${entry.key.capitalize()}</dt>
                            <dd>${entry.value}</dd>
                        </g:each>
                    </dl>
                </div>
            </div>
        </div>
    </div>
    </div>

</section>

</body>
</html>