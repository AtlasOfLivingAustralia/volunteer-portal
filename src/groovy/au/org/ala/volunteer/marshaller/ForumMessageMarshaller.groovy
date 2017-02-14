package au.org.ala.volunteer.marshaller

import au.org.ala.volunteer.ForumMessage
import au.org.ala.volunteer.ForumService
import au.org.ala.volunteer.Project
import au.org.ala.volunteer.ProjectForumTopic
import au.org.ala.volunteer.TaskForumTopic
import au.org.ala.volunteer.UserService
import com.naleid.grails.MarkdownService
import grails.converters.JSON
/*
 * Copyright (C) 2017 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 31/1/17.
 */

class ForumMessageMarshaller {
    MarkdownService markdownService;
    UserService userService;
    ForumService forumService;

    ForumMessageMarshaller(MarkdownService markdownService1, UserService userService, ForumService forumService){
        this.markdownService = markdownService1;
        this.userService = userService;
        this.forumService = forumService
    }

    void register(){
        JSON.registerObjectMarshaller(ForumMessage) { ForumMessage message ->
            Project projectInstance = null

            def text = markdownService.sanitize(message.text ?: "")
            text = markdownService.markdown(text)

            if(message.topic){
                def topic = message.topic
                if (topic.instanceOf(ProjectForumTopic)) {
                    projectInstance = (topic as ProjectForumTopic).project
                } else if (topic.instanceOf(TaskForumTopic)) {
                    projectInstance = (topic as TaskForumTopic).task.project
                }
            }

            def authorIsModerator = !!userService.isUserForumModerator(message.user, projectInstance)
            def timeLeft = forumService.messageEditTimeLeft(message, userService.currentUser)
            def canEdit = forumService.isMessageEditable(message, userService.currentUser)

            return [
                    id: message.id,
                    topicId: message.topic?.id,
                    topicTitle: message.topic?.title,
                    creator: [displayName: message.user.displayName, id: message.user.id, alaId: message.user.userId ],
                    dateCreated: message.date,
                    text: text,
                    deleted: message.deleted,
                    replyTo: message.replyTo?.id,
                    authorIsModerator: authorIsModerator,
                    timeLeft: timeLeft?.minutes,
                    canEdit: canEdit
            ]
        }
    }
}
