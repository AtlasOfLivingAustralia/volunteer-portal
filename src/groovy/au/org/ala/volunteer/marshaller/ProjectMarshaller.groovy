package au.org.ala.volunteer.marshaller

import au.org.ala.volunteer.Project
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

class ProjectMarshaller {
    void register() {
        JSON.registerObjectMarshaller(Project) { Project project ->
            return [
                    id: project.id,
                    user: project.createdBy.collect{ [it.userId, it.displayName]},
                    name: project.name,
                    featuredImage: project.featuredImage,
                    featuredLabel: project.featuredLabel,
                    featuredOwner: project.featuredOwner,
                    description: project.description,
                    inactive: project.inactive,
                    featuredImageCopyright: project.featuredImageCopyright
            ]
        }
    }
}
