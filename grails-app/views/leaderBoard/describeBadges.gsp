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

<cl:headerContent title="${message(code: 'default.leaderboard.describeBadges.label', default: 'Badges')}">
    <% pageScope.crumbs = [] %>
</cl:headerContent>

<section class="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-8">
                <div class="row">
                    <g:each in="${badges}" var="b" status="i">
                        <div class="col-sm-12">
                            <div class="thumbnail row-style">
                                <div class="row">
                                    <div class="col-xs-3">
                                        <a name="${b.name}"><img class="img-responsive" src="${cl.achievementBadgeUrl(achievement:  b)}"></a>
                                    </div>

                                    <div class="col-xs-9">

                                        <div class="caption">
                                            <h4>${b.name}</h4>

                                            <p>You will receive this badge when you have...</p>
                                            <p>${b.description}</p>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                        %{--<div class="col-xs-12 col-sm-6 col-md-4">--}%
                            %{--<div class="thumbnail">--}%
                                %{--<a href="#"><img src="${cl.achievementBadgeUrl(achievement:  b)}"></a>--}%
                                %{--<div class="caption">--}%
                                    %{--<h4><a href="#">${b.name}</a></h4>--}%
                                    %{--<p>You will receive this badge if you have...</p>--}%
                                    %{--<p>${b.description}</p>--}%
                                %{--</div>--}%
                            %{--</div>--}%
                        %{--</div>--}%
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