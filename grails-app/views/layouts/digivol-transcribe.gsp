<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --%>
    <cl:addApplicationMetaTags/>
    <meta name="description" content="Atlas of Living Australia"/>
    <meta name="author" content="Atlas of Living Australia"/>
    %{--<r:external dir="images/" file="favicon.ico"/>--}%
    <asset:link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>

    <title><g:layoutTitle default="DIGIVOL | Home"/></title>

    %{--<r:require module="digivol"/>--}%
    <g:layoutHead/>
    %{--<r:layoutResources/>--}%

    <g:render template="/layouts/commonCss" />
    <g:render template="/layouts/jsUrls" />

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>

<body class="${pageProperty(name: 'body.class')?:'digivol'} ng-cloak" data-ng-app="${pageProperty(name: 'body.data-ng-app', default: 'digivol')}">

<g:render template="/layouts/condensedNav" />

<g:set var="containerClass" value="container"/>
<g:if test="${pageProperty(name:'page.useFluidLayout')}">
    <g:set var="containerClass" value="container-fluid"/>
</g:if>

<div class="${containerClass}">
    <g:layoutBody/>
</div>

<g:render template="/layouts/associatedBrands" />

<g:render template="/layouts/notifications" />

<g:render template="/layouts/ga" />


<!-- JS resources-->
%{--<r:layoutResources/>--}%

</body>
</html>