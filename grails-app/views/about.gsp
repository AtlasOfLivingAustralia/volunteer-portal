<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!doctype html>
<html>
<head>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="About"/></title>
    <content tag="selectedNavItem">bvp</content>
    <style>
    a[name]:before {
        display: block;
        content: " ";
        margin-top: -83px;
        height: 83px;
        visibility: hidden;
    }
    </style>
</head>
<body>

<cl:headerContent title="${message(code: 'default.about.label', default: 'About DigiVol')}">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<section class="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-8">
                <g:message code="about.about_digivol" />

            </div>
            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats" model="[disableStats: true]"/>
            </div>
        </div>
    </div>
</section>
</body>
</html>
