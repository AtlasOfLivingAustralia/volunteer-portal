<%@ page import="au.org.ala.volunteer.AchievementService; au.org.ala.volunteer.FrontPageService" %>
<cl:isLoggedIn>
<r:script>
    digivolNotify({
        eventSourceUrl: "${createLink(uri: '/es')}",
        acceptAchievementsUrl: "${createLink(controller: 'ajax', action: 'acceptAchievements')}",
        alertMessageType: '${FrontPageService.ALERT_MESSAGE}',
        achievmentAwardedMessageType: '${AchievementService.ACHIEVEMENT_AWARDED}',
        achievmentViewedMessageType: '${AchievementService.ACHIEVEMENT_VIEWED}',
        alertType: 'danger',
        alertIconClass: "fa fa-exclamation-circle",
        achievementType: 'success'
    });
</r:script>
</cl:isLoggedIn>