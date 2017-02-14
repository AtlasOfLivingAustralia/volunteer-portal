angular.module('forumService', ['util']).factory('forumService', ['$http', '$log', '$httpParamSerializerJQLike', 'util', function ($http, $log, $httpParamSerializerJQLike, util) {
    return {
        getGeneralTopics: function (sort, order, max, offset) {
            sort = sort || 'lastReplyDate';
            order = order || 'asc';
            max = max || 10;
            offset = offset || 0;

            $log.debug('Fetching general topics.');
            var promise = $http.get(util.getContext() + '/forum/ajaxGeneralTopicsList', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    sort: sort,
                    order: order,
                    max: max,
                    offset: offset
                }
            });
            promise.then(function (response) {
                $log.debug('General topics retrieved with status ' + response.status);
            });

            return promise;
        },
        getFeaturedTopics: function (sort, order, max, offset) {
            sort = sort || 'lastReplyDate';
            order = order || 'asc';
            max = max || 10;
            offset = offset || 0;

            $log.debug('Fetching featured topics.');
            var promise = $http.get(util.getContext() + '/forum/ajaxRecentTopicsList', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    sort: sort,
                    order: order,
                    max: max,
                    offset: offset
                }
            });
            promise.then(function (response) {
                $log.debug('Featured topics retrieved with status ' + response.status);
            });

            return promise;
        },
        getWatchedTopics: function (sort, order) {
            $log.debug('Fetching watched topics.');
            var promise = $http.get(util.getContext() + '/forum/ajaxWatchedTopicsList', { headers: {
                    'Accept': 'application/json'
                }, params: {
                    sort: sort,
                    order: order
                }
            });
            promise.then(function (response) {
                $log.debug('Watched topics retrieved with status ' + response.status);
            });

            return promise;
        },
        getExpeditionForums: function (sort, order, query, max, offset) {
            sort = sort || 'completed';
            order = order || 'asc';
            query = query || undefined;
            max = max || 10;
            offset = offset || 0;

            $log.debug('Fetching expedition forums.');
            var promise = $http.get(util.getContext() + '/forum/ajaxProjectForumsList', {
                cache: true, headers: {
                    'Accept': 'application/json'
                }, params: {
                    sort: sort,
                    order: order,
                    max: max,
                    offset: offset,
                    q: query
                }
            });
            promise.then(function (response) {
                $log.debug('Expedition forums retrieved with status ' + response.status);
            });

            return promise;
        },
        deleteTopic: function (topicId) {
            var promise = $http.get(util.getContext() + '/forum/deleteTopic', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    topicId: topicId
                }
            });

            promise.then(function (response) {
                $log.debug('Topic deleted - ' + topicId);
            }, function (response) {
                $log.debug('Could not delete topic - ' + topicId);
            });

            return promise;
        },
        setTopicWatchStatus: function (topicId, watch) {
            var promise = $http.get(util.getContext() + '/forum/ajaxWatchTopic', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    topicId: topicId,
                    watch: watch
                }
            });

            promise.then(function (response) {
                $log.debug('Topic watch status set to '+ watch +'-'+ topicId);
            }, function (response) {
                $log.debug('Could not set watch on topic - ' + topicId);
            });

            return promise;
        },
        getTopicSettings: function (topicId) {
            var promise = $http.get(util.getContext() + '/forum/editTopic', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    topicId: topicId
                }
            });

            promise.then(function (response) {
                $log.debug('topic setting retrieved - '+ topicId);
            }, function (response) {
                $log.debug('Could not get topic settings - ' + topicId);
            });

            return promise;
        },
        updateTopicSettings: function (topicId, params) {
            params.topicId = topicId;
            var promise = $http.get(util.getContext() + '/forum/updateTopic', {
                headers: {
                    'Accept': 'application/json'
                }, params: params
            });
            promise.then(function (response) {
                $log.debug('Topic settings saved - '+ topicId);
            }, function (response) {
                $log.debug('Could not save topic settings - ' + topicId);
            });

            return promise;
        },
        getForumTopicCreationPrerequisiteInfo: function (topicId, projectId, taskId) {
            var promise = $http.get(util.getContext() + '/forum/addForumTopic', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    topicId: topicId,
                    projectId: projectId,
                    taskId: taskId
                }
            });

            promise.then(function (response) {
                $log.debug('Prerequisite information received.');
            }, function (response) {
                $log.debug('Could not retrieve prerequisite information.');
            });

            return promise;
        },
        createNewForumTopic: function (topicId, projectId, taskId, data) {
            if(topicId){
                data.topicId = topicId;
            }

            projectId ? data.projectId = projectId : '';
            taskId ? data.taskId = taskId : '';

            var promise = $http.post(util.getContext() + '/forum/insertForumTopic',$httpParamSerializerJQLike(data),  {
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            });

            promise.then(function (response) {
                $log.debug('Created new forum topic.');
            }, function (response) {
                $log.debug('Could not create new forum topic.');
            });

            return promise;
        },
        getForumTopic: function (topicId) {
            var promise = $http.get(util.getContext() + '/forum/viewForumTopic', {
                headers: {
                    'Accept': 'application/json'
                },
                params: {
                    id : topicId
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved forum topic - ' + topicId);
            }, function (response) {
                $log.debug('Could not retrieve forum topic - ' + topicId);
            });

            return promise;
        },
        getProjectForum: function (projectId, sort, order, max, offset) {
            sort = sort || 'lastReplyDate';
            order = order || 'asc';
            max = max || 10;
            offset = offset || 0;
            var promise = $http.get(util.getContext() + '/forum/projectForum', {
                headers: {
                    'Accept': 'application/json'
                },
                params: {
                    projectId : projectId,
                    sort: sort,
                    order: order,
                    max: max,
                    offset: offset
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved project forum - ' + projectId);
            }, function (response) {
                $log.debug('Could not retrieve project forum - ' + projectId);
            });

            return promise;
        },
        setProjectWatchStatus: function (projectId, watch) {
            var promise = $http.get(util.getContext() + '/forum/ajaxWatchProject', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    projectId: projectId,
                    watch: watch
                }
            });

            promise.then(function (response) {
                $log.debug('Project watch status set to '+ watch +'-'+ projectId);
            }, function (response) {
                $log.debug('Could not set watch on project - ' + projectId);
            });

            return promise;
        },
        getProjectTaskTopics: function (projectId, sort, order, max, offset) {
            sort = sort || 'lastReplyDate';
            order = order || 'asc';
            max = max || 10;
            offset = offset || 0;
            var promise = $http.get(util.getContext() + '/forum/ajaxProjectTaskTopicList', {
                headers: {
                    'Accept': 'application/json'
                },
                params: {
                    projectId : projectId,
                    sort: sort,
                    order: order,
                    max: max,
                    offset: offset
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved project forum - ' + projectId);
            }, function (response) {
                $log.debug('Could not retrieve project forum - ' + projectId);
            });

            return promise;
        },
        getMessagesForTopic: function (topicId) {
            var promise = $http.get(util.getContext() + '/forum/postMessage', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    topicId: topicId
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved topic messages - '+ topicId);
            }, function (response) {
                $log.debug('Could not get topic messages - ' + topicId);
            });

            return promise;
        },
        getMessagePreview: function (topicId, replyTo, messageText) {
            var data = {
                topicId: topicId,
                replyTo: replyTo,
                messageText: messageText
            };
            var promise = $http.post(util.getContext() + '/forum/previewMessage', $httpParamSerializerJQLike(data),{
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved messages preview - '+ topicId);
            }, function (response) {
                $log.debug('Could not get message preview - ' + topicId);
            });

            return promise;
        },
        saveNewMessage: function (topicId, replyTo, data) {
            var data = data ||{};
            data.topicId = topicId;
            data.replyTo = replyTo;

            var promise = $http.post(util.getContext() + '/forum/saveNewTopicMessage', $httpParamSerializerJQLike(data),{
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            });

            promise.then(function (response) {
                $log.debug('Saved new message - '+ topicId);
            }, function (response) {
                $log.debug('Could not get message preview - ' + topicId);
            });

            return promise;
        },
        getMessageForId: function (messageId) {
            var promise = $http.get(util.getContext() + '/forum/editMessage', {
                headers: {
                    'Accept': 'application/json'
                }, params: {
                    messageId: messageId
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved topic message - '+ messageId);
            }, function (response) {
                $log.debug('Could not get topic message - ' + messageId);
            });

            return promise;
        },
        getEditMessagePreview: function (messageId, messageText) {
            var data = {
                messageId: messageId,
                messageText: messageText
            };
            var promise = $http.post(util.getContext() + '/forum/previewMessageEdit', $httpParamSerializerJQLike(data),{
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            });

            promise.then(function (response) {
                $log.debug('Retrieved messages preview - '+ messageId);
            }, function (response) {
                $log.debug('Could not get message preview - ' + messageId);
            });

            return promise;
        },
        updateMessage: function (messageId, data) {
            var data = data ||{};
            data.messageId = messageId;

            var promise = $http.post(util.getContext() + '/forum/updateTopicMessage', $httpParamSerializerJQLike(data),{
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            });

            promise.then(function (response) {
                $log.debug('Saved new message - '+ messageId);
            }, function (response) {
                $log.debug('Could not save message - ' + messageId);
            });

            return promise;
        },
        deleteMessage: function (messageId) {
            var promise = $http.get(util.getContext() + '/forum/deleteTopicMessage', {
                headers: {
                    'Accept': 'application/json',
                },
                params: {
                    messageId: messageId
                }
            });

            promise.then(function (response) {
                $log.debug('Deleted message - '+ messageId);
            }, function (response) {
                $log.debug('Could not delete message - ' + messageId);
            });

            return promise;
        },
        searchTextInForums: function (text, max, offset) {
            var promise = $http.get(util.getContext() + '/forum/searchForums', {
                headers: {
                    'Accept': 'application/json',
                },
                params: {
                    query: text,
                    max: max,
                    offset: offset
                }
            });

            promise.then(function (response) {
                $log.debug('Found results for search - '+ text);
            }, function (response) {
                $log.debug('Could not find results for search - ' + text);
            });

            return promise;
        }
    }
}]);