angular.module('util', ['forumConfig']).factory('util', ['config', '$location', function (config, $location) {
    var self = this;
    var publicFunctions = {
        getContext: function () {
            return config.contextPath;
        },
        goToForum: function (type) {
            $location.url(publicFunctions.getForumLink(type, true));
        },
        goToTask: function (taskId) {
            if(taskId != undefined && taskId != null){
                window.location = config.contextPath + '/task/show/' +taskId;
            }
        },
        goToTopic: function (topicId) {
            $location.url(publicFunctions.getTopicForumLink(topicId, true));
        },
        goToTopicSettings: function (topicId) {
            $location.url(publicFunctions.getTopicSettingsLink(topicId, true));
        },
        goToProjectForum: function (projectId) {
            $location.url(publicFunctions.getProjectForumLink(projectId, true));
        },
        goToEditMessage: function (topicId, messageId) {
            $location.url(publicFunctions.goToEditMessageLink(topicId, messageId, true));
        },
        goToTopicReply: function (topicId) {
            $location.url(publicFunctions.getTopicReplyLink(topicId, true));
        },
        goToSearch: function (text) {
            $location.url(publicFunctions.getSearchLink(text, true));
        },
        getSearchLink: function (text, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/search/'+text;
        },
        goToEditMessageLink: function (topicId, messageId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/topic/'+topicId+'/message/'+messageId;
        },
        getProjectForumLink: function (projectId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/expedition-forum/'+projectId
        },
        getProjectLink: function (projectId) {
            return config.contextPath + '/project/index/' + projectId;
        },
        getTaskLink: function (taskId) {
            return config.contextPath + '/task/show/' + taskId;
        },
        getTopicForumLink: function (topicId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/topic/'+topicId;
        },
        getTopicSettingsLink: function (topicId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/topic/settings/'+topicId;
        },
        getTopicReplyLink: function (topicId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/topic/reply/'+topicId;
        },
        getForumLink: function (type, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;

            type = type || 'featured';
            switch (type){
                case 'featured':
                    return prefix + '/forum-dashboard/featured';
                    break;
                case 'general':
                    return prefix + '/forum-dashboard/general';
                    break;
                case 'watched':
                    return prefix + '/forum-dashboard/watched';
                    break;
                case 'expedition':
                    return prefix + '/forum-dashboard/expedition';
                    break;

            }
        },
        getCreateTopicForProjectLink: function (projectId, removePrefix) {
            var prefix = removePrefix? '':config.urlPrefix;
            return prefix + '/topic/create/project/'+projectId;
        },
        goToCreateTopicForProject: function (projectId) {
            $location.url(publicFunctions.getCreateTopicForProjectLink(projectId, true));
        },
        isValidValue: function (value) {
            if(value != undefined && value != null && value != ""){
                return true;
            } else {
                return false;
            }

        },
        setBreadcrumbs: function (crumbs) {
            var bc = config.breadcrumbs;
            bc.splice(0, bc.length);
            crumbs.unshift({href: config.contextPath, title: 'Home'});
            bc.push.apply(bc, crumbs);
        },
        getNavigationLinks: function (projectInstance, taskInstance, topic, lastLabel, lastItems) {
            var crumbs = [];
            lastItems = lastItems || [];
            if (projectInstance) {
                crumbs.push({href: publicFunctions.getProjectLink(projectInstance.id), title: projectInstance.featuredLabel});
                crumbs.push({href: publicFunctions.getProjectForumLink(projectInstance.id), title: 'Expedition Forum'});
            }

            if (taskInstance) {
                crumbs.push({href: publicFunctions.getProjectForumLink(taskInstance.project.id), title: 'Expedition Forum'});
                crumbs.push({href: publicFunctions.getTaskLink(taskInstance.id), title: "Task - " + taskInstance.externalIdentifier});
            }

            if (!projectInstance && !taskInstance) {
                crumbs.push({href: publicFunctions.getForumLink('featured'), title: "Forum"});
                crumbs.push({href: publicFunctions.getForumLink('general'), title: "General Discussion"});
            }

            if (lastLabel) {
                if (topic) {
                    crumbs.push({href: "#!/topic/" + topic.id, title: topic.title});
                }
            }

            if(lastItems){
                crumbs.push.apply(crumbs, lastItems);
            }

            return crumbs;
        },
        updateBreadcrumbs: function (projectInstance, taskInstance, topicInstance, lastLabel, lastItems) {
            var crumbs = publicFunctions.getNavigationLinks(projectInstance, taskInstance, topicInstance, lastLabel, lastItems);
            publicFunctions.setBreadcrumbs(crumbs);
        },
        setBreadcrumbForDashboard: function (type) {
            type = type || 'featured';
            switch (type){
                case 'featured':
                    publicFunctions.setBreadcrumbs([{href: publicFunctions.getForumLink('featured'), title: 'Forum'}]);
                    break;
                case 'general':
                    publicFunctions.setBreadcrumbs([{href: publicFunctions.getForumLink('featured'), title: 'Forum'}, {href: publicFunctions.getForumLink('general'), title: 'General Discussion'}]);
                    break;
                case 'expedition':
                    publicFunctions.setBreadcrumbs([{href: publicFunctions.getForumLink('featured'), title: 'Forum'}, {href: publicFunctions.getForumLink('expedition'), title: 'Expedition Forum'}]);
                    break;
                case 'watched':
                    publicFunctions.setBreadcrumbs([{href: publicFunctions.getForumLink('featured'), title: 'Forum'}, {href: publicFunctions.getForumLink('watched'), title: 'Watched topics'}]);
                    break;
            }
        },
        getSelectedText: function () {
            var t = '';
            var replyTo
            if (window.getSelection) {
                t = window.getSelection();
            } else if (document.getSelection) {
                t = document.getSelection();
            } else if (document.selection) {
                t = document.selection.createRange().text;
            }

            if (t.anchorNode) {
                var author = $(t.anchorNode).parents("div[author]").attr("author")
                replyTo = author;
            }

            return {author: replyTo, element: t }
        }
    };

    return publicFunctions;
}]);