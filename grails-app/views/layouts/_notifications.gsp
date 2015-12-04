<%@ page import="au.org.ala.volunteer.AchievementService; au.org.ala.volunteer.FrontPageService" %>
<r:script>
    digivolNotify({
        eventSourceUrl: "${createLink(controller: 'eventSource', action: 'index')}",
        acceptAchievementsUrl: "${createLink(controller: 'ajax', action: 'acceptAchievements')}",
        alertMessageType: '${FrontPageService.ALERT_MESSAGE}',
        achievmentAwardedMessageType: '${AchievementService.ACHIEVEMENT_AWARDED}',
        achievmentViewedMessageType: '${AchievementService.ACHIEVEMENT_VIEWED}',
        alertType: 'danger',
        alertIconClass: "fa fa-exclamation-circle",
        achievementType: 'success'
    });
</r:script>