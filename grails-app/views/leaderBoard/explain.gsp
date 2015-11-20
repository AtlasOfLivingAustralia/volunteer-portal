<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="Badges"/></title>
    <content tag="selectedNavItem">bvp</content>
</head>
<body>

<cl:headerContent title="${message(code: 'default.leaderboard.explain.label', default: 'Badges')}">
    <%
        pageScope.crumbs = [
        ]
    %>
    <h2>So you think you want badges...</h2>
</cl:headerContent>

<section class="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-8">
                <p class="intro">Badges?  You want badges?</p>
                <div class="embed-responsive embed-responsive-16by9">
                    <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/i4h9xcdtyrE?start=69&end=76"></iframe>
                </div>
                <h2 class="body-heading">I can has badges?</h2>
                <p>Do some transcriptions</p>
                <h2 class="body-heading">What badges can I has?</h2>
                <div class="row">
                    <g:each in="${badges}" var="b" status="i">
                        <div class="col-xs-12 col-sm-6 col-md-4">
                            <div class="thumbnail">
                                <a href="#"><img src="${cl.achievementBadgeUrl(achievement:  b)}"></a>
                                <div class="caption">
                                    <h4><a href="#">${b.name}</a></h4>
                                    <p>You will receive this badge if you have...</p>
                                    <p>${b.description}</p>
                                </div>
                            </div>
                        </div>
                        <g:if test="${(i+1) % 3 == 0}"><div class="clearfix visible-md-block visible-lg-block"></div></g:if>
                        <g:if test="${(i+1) % 2 == 0}"><div class="clearfix visible-sm-block"></div></g:if>
                    </g:each>
                </div>
            </div>
            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats" model="[disableStats: true]"/>
            </div>
        </div>
    </div>
</section>

</body>
</html>