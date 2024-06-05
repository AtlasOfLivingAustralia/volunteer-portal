package au.org.ala.volunteer

public class SettingDefinition<T> {

    public static def ForumMessageEditWindow = new SettingDefinition("forum.messageEditWindowSeconds", 15 * 60, "(Seconds) The amount of time someone has to edit their forum messages from the time they posted")
    public static def ForumNotificationsEnabled = new SettingDefinition("forum.notifications.enabled", true, "Whether or not notifications are sent out")
    public static def BatchForumNotificationMessages = new SettingDefinition("forum.notifications.batched", false, "Whether or not notifications are batch sent periodically or sent out directly on posting")
    public static def EnableMyNotebook = new SettingDefinition("dashboard.enabled", false, "Enable the user notebook tab")
    public static def EnableAchievementCalculations = new SettingDefinition("achievements.enabled", false, "Enable calculating achievements after each task change")
    public static def PicklistCollectionCodes = new SettingDefinition("picklist.collection.codes", new ArrayList<String>(), "List of collection codes used to partition picklist items")
    public static def InstitutionsEnabled = new SettingDefinition("institutions.enabled", true, "Whether or not the institutions tab is displayed")
    public static def IneligibleLeaderBoardUsers = new SettingDefinition<List<String>>("leaderboard.ineligibleUsers", new ArrayList<String>(), "The list of users not eligible for the leaderboard")
    public static def LabelCategories = new SettingDefinition<List<String>>("project.label.categories", ['country', 'subject'], "The list of users not eligible for the leaderboard")
    public static def FrontPageLogos = new SettingDefinition<List<String>>('frontpage.logos', [], "The list of insitution logos.")
    public static def EnableWelcomeEmail = new SettingDefinition("welcome.email.enabled", true, "Enable welcome emails to new users.")
    public static def WelcomeEmailSyncText = new SettingDefinition<String>('welcome.email.sync', "Welcome to DigiVol!", "The welcome email content for when the user hasn't yet transcribed a task.")
    public static def WelcomeEmailTranscribedText = new SettingDefinition<String>('welcome.email.transcribed', "Welcome to DigiVol!", "The welcome email content for when the user has transcribed their first task.")
    public static def ReportCleanupEnabled = new SettingDefinition("report.cleanup.enabled", true, "Enable the cleanup job to delete old reports.")
    public static def ReportCleanupAge = new SettingDefinition("report.cleanup.ageToDelete", 5, "The age of reports in weeks to delete in the cleanup job")

//    public static def NotificationEmailServerName = new SettingDefinition("notifications.emailServer.name", "localhost", "The name or address of the SMTP server to user to send out notifications")
//    public static def NotificationEmailServerPort = new SettingDefinition("notifications.emailServer.port", 25, "The port that the SMTP server is listening on")
//    public static def NotificationEmailServerUsername = new SettingDefinition("notifications.emailServer.username", "", "SMTP Server username")
//    public static def NotificationEmailServerPassword = new SettingDefinition("notifications.emailServer.password", "", "SMTP Server password")

    public String key
    public T defaultValue
    public String description

    public SettingDefinition(String key, T defaultValue, String description) {
        this.key = key
        this.defaultValue = defaultValue
        this.description = description
    }
}
