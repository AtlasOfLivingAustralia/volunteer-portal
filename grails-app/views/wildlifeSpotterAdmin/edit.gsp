<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="wildlifeSpotterAdmin.label" default="Wildlife Spotter Configuration"/></title>
</head>

<body class="admin">
<div class="container">
    <cl:headerContent title="${message(code: 'default.wildlifeSpotterOptions.label', default: 'Wildlife Spotter Options')}" selectedNavItem="bvpadmin">
        <%
            pageScope.crumbs = [
                    [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Administration')]
            ]
        %>
    </cl:headerContent>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12">
                    <g:hasErrors bean="${wildlifeSpotter}">
                        <div class="errors">
                            <g:renderErrors bean="${wildlifeSpotter}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form action="save" class="form-horizontal">

                        <div class="form-group" ${hasErrors(bean: wildlifeSpotter, field: 'bodyCopy', 'has-error')}>
                            <label for="bodyCopy" class="control-label col-md-3"><g:message code="wildlifeSpotter.bodyCopy.label"
                                                                                                        default="Wildlife Spotter Landing Page Text"/></label>
                            <div class="col-md-6">
                                <g:textArea name="bodyCopy" class="form-control" placeholder="Markdown..." value="${wildlifeSpotter.bodyCopy}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: wildlifeSpotter, field: 'numberOfContributors', 'has-error')}>
                            <label for="numberOfContributors" class="control-label col-md-3"><g:message code="wildlifeSpotter.numberOfContributors.label"
                                                                                               default="The number of contributors to show on the wildlife spotter landing page"/></label>
                            <div class="col-md-6">
                                <g:field name="numberOfContributors" type="number" min="0" max="20" class="form-control" value="${wildlifeSpotter.numberOfContributors}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: wildlifeSpotter, field: 'heroImageAttribution', 'has-error')}">
                            <label for="heroImageAttribution" class="control-label col-md-3">
                                <g:message code="wildlifeSpotter.heroImageAttribution" default="Hero Image Attribution Text" />
                            </label>
                            <div class="col-md-6">
                                <g:field name="heroImageAttribution" type="text" class="form-control" value="${wildlifeSpotter.heroImageAttribution}" />
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="save" class="save btn btn-primary"
                                            value="${message(code: 'default.button.save.label', default: 'Save')}"/>
                            </div>
                        </div>

                    </g:form>
                </div>
            </div>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Hero Image</h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 hero-image">
                    <g:uploadForm id="hero-image-form" controller="wildlifeSpotterAdmin" action="uploadHeroImage" method="post">
                        <div class="form-group">
                            <label for="heroImage" class="control-label col-md-3">
                                <g:message code="wildlifeSpotter.heroImage.label" default="Hero Image" />
                            </label>
                            <div class="col-md-6">
                                <g:if test="${wildlifeSpotter.heroImage}">
                                    <img class="img-responsive" src="${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/wildlifespotter/${wildlifeSpotter.heroImage}"/>
                                </g:if>
                                <input id="heroImage" name="heroImage" type="file" />
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-9">
                                <g:submitButton name="save-hero" class="save-hero btn btn-primary"
                                                value="${message(code: 'default.button.save.label', default: 'Save')}"/>
                                <g:submitButton name="clear-hero" class="clear-hero btn btn-default"
                                                value="${message(code: 'default.button.reset.label', default: 'Reset')}"/>
                            </div>
                        </div>

                    </g:uploadForm>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
