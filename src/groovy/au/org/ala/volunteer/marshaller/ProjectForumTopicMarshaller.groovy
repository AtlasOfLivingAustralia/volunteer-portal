package au.org.ala.volunteer.marshaller

import au.org.ala.volunteer.ForumMessage
import au.org.ala.volunteer.MultimediaService
import au.org.ala.volunteer.ProjectForumTopic
import au.org.ala.volunteer.UserService
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
 * Created by Temi on 23/1/17.
 */

class ProjectForumTopicMarshaller {
    MultimediaService multimediaService
    UserService userService

    void register() {
        JSON.registerObjectMarshaller(ProjectForumTopic) { ProjectForumTopic topic ->
            return [
                    id: topic.id,
                    creator: [displayName: topic.creator.displayName, id: topic.creator.id, alaId: topic.creator.userId ],
                    replies: ForumMessage.countByTopic(topic) - 1,
                    title: topic.title,
                    views: topic.views,
                    dateCreated: topic.dateCreated,
                    lastReplyDate: topic.lastReplyDate,
                    featured: topic.featured,
                    sticky: topic.sticky,
                    locked: topic.locked,
                    image: topic.project.featuredImage,
                    isModerator: userService?.isForumModerator(),
                    project: topic.project?.featuredLabel,
                    priority: topic.priority.toString()
            ]
        }
    }
}
