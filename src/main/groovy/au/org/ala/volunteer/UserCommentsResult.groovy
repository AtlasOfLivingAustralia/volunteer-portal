package au.org.ala.volunteer

import grails.orm.PagedResultList


class UserCommentsResult {
    User userInstance
    PagedResultList messages;
}
