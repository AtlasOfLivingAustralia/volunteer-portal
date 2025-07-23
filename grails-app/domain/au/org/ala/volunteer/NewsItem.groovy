package au.org.ala.volunteer

import au.org.ala.volunteer.sanitizer.SanitizedHtml
import org.apache.commons.lang3.builder.ToStringBuilder

/**
 * News Item Domain class.
 */
class NewsItem {

    long id
    String title
    @SanitizedHtml
    String content
    Boolean isActive
    Date dateExpires
    ForumTopic topic

    Date dateCreated
    Date lastUpdated
    User createdBy
    User updatedBy

    static constraints = {
        title nullable: false, maxSize: 60
        content nullable: false
        isActive nullable: false
        dateExpires nullable: false
        topic nullable: true
        dateCreated nullable: false
        lastUpdated nullable: true
        createdBy nullable: false
        updatedBy nullable: true
    }

    static mapping = {
        autoTimestamp(true)
        isActive defaultValue: true
    }


    @Override
    String toString() {
        return new ToStringBuilder(this)
                .append("title", title)
                .append("content", "${content.length() > 40 ? content.substring(0, 40) + "..." : content}")
                .append("isActive", isActive)
                .append("dateExpires", dateExpires)
                .append("dateCreated", dateCreated)
                .append("createdBy", createdBy.displayName)
                .append("topic", topic?.title)
                .toString();
    }

    /**
     * Truncate the content of the news item to a specified length.
     * @param length The maximum length of the content to return.
     * @param truncate The method of truncation, either 'words' or 'characters'.
     * @return Truncated content, either by words or characters.
     */
    String truncateContent(int length, String truncate = 'words') {
        if (content) {
            if (truncate == 'words') {
                def words = content.split(/\s+/)
                return words.length > length ? words.take(length).join(' ') + '... [linktag]' : content
            } else {
                return content.length() > length ? content.substring(0, length) + '... [linktag]' : content
            }
        }
        return ''
    }
}
