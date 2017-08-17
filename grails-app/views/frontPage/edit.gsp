<%@ page import="au.org.ala.volunteer.Project; au.org.ala.volunteer.WebUtils" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="frontPage.label" default="Front Page Configuration"/></title>
</head>

<body class="admin">
<input type="hidden" id="selectedProjectId"/>
<div class="container">
    <cl:headerContent title="${message(code: 'default.frontpageoptions.label', default: 'Front Page Options')}" selectedNavItem="bvpadmin">
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
                    <g:hasErrors bean="${frontPage}">
                        <div class="errors">
                            <g:renderErrors bean="${frontPage}" as="list"/>
                        </div>
                    </g:hasErrors>
                    <g:form action="save" class="form-horizontal">
                        <div class="form-group">
                            <label for="projectOfTheDay" class="control-label col-md-3"><g:message code="frontPage.projectOfTheDay.label"
                                                                    default="Project of the day"/></label>
                            <div class="col-md-6">
                                <g:select name="projectOfTheDay" class="form-control" from="${(Project.createCriteria().list {
                                    i18nName {
                                        order( WebUtils.getCurrentLocaleAsString() )
                                    }
                                })
                                }"
                                          optionKey="id" optionValue="i18nName" value="${frontPage.projectOfTheDay?.id}"/>

                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-default" id="btnFindProject"><g:message code="front_page.find_an_expedition"/></button>
                                <g:link class="btn btn-success" action="edit" controller="project"
                                        id="${frontPage.projectOfTheDay?.id}"><g:message code="front_page.edit_project"/></g:link>
                            </div>
                        </div>

                        %{--<div class="form-group" ${hasErrors(bean: frontPage, field: 'useGlobalNewsItem', 'has-error')}>--}%
                            %{--<label for="useGlobalNewsItem" class="control-label col-md-3"><g:message code="frontPage.useGlobalNewsItem.label"--}%
                                                                                                   %{--default="Use global news item"/></label>--}%
                            %{--<div class="col-md-6">--}%
                                %{--<g:checkBox i18nName="useGlobalNewsItem" class="form-control" value="${frontPage.useGlobalNewsItem}"/>--}%
                                %{--<span class="help-block">(If unchecked the most recent project news item will be used instead)</span>--}%
                            %{--</div>--}%
                        %{--</div>--}%

                        %{--<div class="form-group" ${hasErrors(bean: frontPage, field: 'newsTitle', 'has-error')}>--}%
                            %{--<label for="newsTitle" class="control-label col-md-3"><g:message code="frontPage.newsTitle.label"--}%
                                                                                                     %{--default="News title"/></label>--}%
                            %{--<div class="col-md-6">--}%
                                %{--<g:textField class="form-control" i18nName="newsTitle" value="${frontPage?.newsTitle}"/>--}%
                            %{--</div>--}%
                        %{--</div>--}%

                        %{--<div class="form-group" ${hasErrors(bean: frontPage, field: 'newsBody', 'has-error')}>--}%
                            %{--<label for="newsBody" class="control-label col-md-3"><g:message code="frontPage.newsBody.label"--}%
                                                                                             %{--default="News text"/></label>--}%
                            %{--<div class="col-md-6">--}%
                                %{--<g:textArea class="form-control" rows="4" i18nName="newsBody"--}%
                                            %{--value="${frontPage?.newsBody}"/>--}%
                            %{--</div>--}%
                        %{--</div>--}%

                        %{--<div class="form-group" ${hasErrors(bean: frontPage, field: 'newsCreated', 'has-error')}>--}%
                            %{--<label for="newsCreated" class="control-label col-md-3"><g:message code="frontPage.newsCreated.label"--}%
                                                                                            %{--default="News date"/></label>--}%
                            %{--<div class="col-md-6 grails-date">--}%
                                %{--<g:datePicker i18nName="newsCreated" precision="day" value="${frontPage?.newsCreated}"/>--}%
                            %{--</div>--}%
                        %{--</div>--}%

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'systemMessage', 'has-error')}>
                            <label for="systemMessage" class="control-label col-md-3"><g:message code="frontPage.systemMessage.label"
                                                                                            default="System message"/></label>
                            <div class="col-md-6">
                                <g:textArea class="form-control" rows="4" name="systemMessage"
                                                value="${frontPage?.systemMessage}"/>
                                <span class="help-block"><g:message code="front_page.displayed_on_every_page"/></span>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'showAchievements', 'has-error')}>
                            <label for="useGlobalNewsItem" class="control-label col-md-3"><g:message code="frontPage.showAchievements.label"
                                                                                                     default="Show achievements on User stats page"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="showAchievements" class="form-control" value="${frontPage.showAchievements}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'enableTaskComments', 'has-error')}>
                            <label for="enableTaskComments" class="control-label col-md-3"><g:message code="frontPage.enableTaskComments.label"
                                                                                                     default="Enable task commenting"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="enableTaskComments" class="form-control" value="${frontPage.enableTaskComments}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'enableForum', 'has-error')}>
                            <label for="enableForum" class="control-label col-md-3"><g:message code="frontPage.enableForum.label"
                                                                                                      default="Enable the ${message(code: "default.application.name")} Forum"/></label>
                            <div class="col-md-6">
                                <g:checkBox name="enableForum" class="form-control" value="${frontPage.enableForum}"/>
                            </div>
                        </div>

                        <div class="form-group" ${hasErrors(bean: frontPage, field: 'numberOfContributors', 'has-error')}>
                            <label for="numberOfContributors" class="control-label col-md-3"><g:message code="frontPage.numberOfContributors.label"
                                                                                               default="The number of contributors to show on the front page"/></label>
                            <div class="col-md-6">
                                <g:field name="numberOfContributors" type="number" min="0" max="20" class="form-control" value="${frontPage.numberOfContributors}"/>
                            </div>
                        </div>

                        <div class="form-group ${hasErrors(bean: frontPage, field: 'attributionText', 'has-error')}">
                            <label for="heroImageAttribution" class="control-label col-md-3">
                                <g:message code="frontPage.heroImageAttribution" default="Hero Image Attribution Text" />
                            </label>
                            <div class="col-md-6">
                                <g:field name="heroImageAttribution" type="text" class="form-control" value="${frontPage.heroImageAttribution}" />
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
            <h3 class="panel-title"><g:message code="frontPage.heroImage.label"/></h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-md-12 hero-image">
                    <g:uploadForm id="hero-image-form" controller="frontPage" action="uploadHeroImage" method="post">
                        <div class="form-group">
                            <label for="heroImage" class="control-label col-md-3">
                                <g:message code="frontPage.heroImage.label" default="Hero Image" />
                            </label>
                            <div class="col-md-6">
                                <g:if test="${frontPage.heroImage}">
                                    <img class="img-responsive" src="${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/hero/${frontPage.heroImage}"/>

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
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title"><g:message code="front_page.institutions_using_digivol_logos"/></h3>
        </div>
        <div class="panel-body">
            <div class="row" id="logos">
            </div>
            <div class="row">
                <div class="col-sm-12 logos">
                    <g:uploadForm controller="frontPage" action="addLogoImage">
                        <input id="uploadLogo" name="uploadLogo" type="file" multiple />
                        <g:submitButton name="Upload logos" class="btn btn-primary"/>
                    </g:uploadForm>
                </div>
            </div>
        </div>
    </div>
</div>
<script id="logo-item" type="x-tmpl-mustache">
<div class="col-md-3 col-sm-4 col-xs-6">
    <div class="thumbnail">
      <img style="max-height: 80px;" src="${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/logos/{{src}}" alt="${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}/logos/{{src}}">
      <div class="caption">
        <p><button class="btn btn-danger delete-logo" data-idx="{{idx}}"><i class="fa fa-trash"></i></button></p>
      </div>
    </div>
</div>
</script>
<asset:javascript src="frontpage-edit.js" asset-defer=""/>
<asset:script type="text/javascript">

    $(document).ready(function () {

        $("#btnFindProject").click(function (e) {
            e.preventDefault();
            bvp.selectProjectId(function (projectId) {
                $("#projectOfTheDay").val(projectId);
            });

        });

        $('.grails-date select').each(function() {
            $(this).attr('class', 'form-control');
        });

        var logos = [];
        $('#logos').on('click', 'button.delete-logo', function(e) {
          var newlogos = logos.splice(0);
          var $this = $(this);
          var idx = $this.data('idx');
          newlogos.splice(idx, 1);
          updateLogos(newlogos);
        });


        $.get({
          url: "${createLink(controller: 'frontPage', action: 'getLogos')}",
          dataType: 'json'
        }).done(function(data, textStatus, jqXHR) {
          logos = data;
          setLogos(data);
        }).fail(function(jqXHR, textStatus, errorThrown) {
          alert("error gettings logos"); //todo
        });

        // var $form = $('#logoform');
        // $('#uploadLogo').on('change', function(e) {
        //   $.ajax( {
        //     url: $form.attr('action'),
        //     type: 'POST',
        //     data: new FormData( $form[0] ),
        //     processData: false,
        //     contentType: false,
        //     headers: {
        //       Accept: "application/json",
        //     }
        //   }).done(function(data, textStatus, jqXHR) {
        //     logos = data;
        //     setLogos(data);
        //   }).fail(function(jqXHR, textStatus, errorThrown) {
        //     alert("Error uploading images");
        //   });
        // });

        function updateLogos(logos) {
          $.post({
            url: "${createLink(controller: 'frontPage', action: 'updateLogoImages')}",
            data: JSON.stringify(logos),
            contentType: 'application/json; charset=utf-8',
            dataType: 'json'
          }).done(function(data, textStatus, jqXHR) {
            logos = data;
            setLogos(data);
          }).fail(function(jqXHR, textStatus, errorThrown) {
            alert('error updating logos'); // todo
          });
        }

        function setLogos(logos) {
          var $logos = $('#logos');
          $logos.empty();
          $.each(logos, function(i, logo) {
            mu.appendTemplate($logos, 'logo-item', { src: logo, idx: i });
          });
        }
    });

</asset:script>

</body>
</html>
