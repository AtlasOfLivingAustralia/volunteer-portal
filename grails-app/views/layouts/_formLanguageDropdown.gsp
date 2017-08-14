<%@ page import="org.springframework.context.i18n.LocaleContextHolder" %>
<asset:javascript src="jquery-ui.js" asset-defer=""/>
<!-- form language selector -->
<asset:script>
    function showLocale(localeString) {
        $(".i18n-field").hide();
        $(".i18n-field-"+localeString).show().effect("highlight", "slow");
        $(".form-locale").html(localeString.substr(0,2)).parent().effect("highlight", "slow");
    }
    $(function() {
        showLocale('${ LocaleContextHolder.getLocale().toString()}')
    });
</asset:script>
<ul class="nav">
    <li class="dropdown language-selection" style="    right: 25px;">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <span class="locale form-locale" >${ LocaleContextHolder.getLocale().getLanguage()}</span>
            <span class="glyphicon glyphicon-chevron-down"></span>
        </a>
        <ul class="dropdown-menu language-dropdown-menu">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <li ><a onclick="showLocale('${it.toString()}')"><span class="locale">${it.toString().substring(0,2)}</span></a></li>
            </g:each>
        </ul>
    </li>
</ul>
<!-- End form language selector -->