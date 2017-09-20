<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.springframework.context.i18n.LocaleContextHolder" %>
<asset:javascript src="jquery-ui.js" asset-defer=""/>
<!-- form language selector -->
<asset:script>
    function showLocale(localeString) {
        $(".i18n-field").hide();
        $(".i18n-field-"+localeString).show().effect("highlight", "slow");
        $(".form-locale").html(localeString.substr(0,2)).parent().effect("highlight", "slow");
        checkIfAllFieldsAreTranslated(localeString);
    }
    function checkIfAllFieldsAreTranslated(localeString) {
        $(".i18n-field-"+localeString).each(function() {
            var valid = true;
            var mceChild = $(this).find(".mce");
            if(mceChild.length>0) {
                // long description with mce editor - check if all language versions have a value
                mceChild.parent().parent().find(".mce").each(function() {
                    var thisMce = tinyMCE.get($(this).attr("id"));
                    if(thisMce != null && !thisMce.getContent()) {
                        $(this).parents(".form-group").addClass("has-error");
                        valid = false;
                    }
                });
                if(valid) {
                    $(this).parents(".form-group").removeClass("has-error");
                }
            }else {
                // input field - check if all language versions have a value
                $(this).parent().children().each(function() {
                    if(!$(this).val()) {
                        $(this).parents(".form-group").addClass("has-error");
                        valid = false;
                    }
                });

                if(valid) {
                    $(this).parents(".form-group").removeClass("has-error");
                }
            }
        });
    }
    $(function() {
        // Checks fields when clicking out of an input field
        $(".i18n-field").focusout(function() { checkIfAllFieldsAreTranslated('${ LocaleContextHolder.getLocale().toString()}'); });

        showLocale('${ LocaleContextHolder.getLocale().toString()}')

        setTimeout(function() { checkIfAllFieldsAreTranslated('${ LocaleContextHolder.getLocale().toString()}') }, 2000);
    });
</asset:script>
<ul class="nav">
    <li class="dropdown language-selection" style="    right: 25px;">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <span class="locale form-locale locale" >${ LocaleContextHolder.getLocale().getLanguage()}</span>
            <span class="glyphicon glyphicon-chevron-down"></span>
        </a>
        <ul class="dropdown-menu language-dropdown-menu">
            <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
                <li><a class="selectable"  onclick="showLocale('${it.toString()}')"><span class="locale">${it.toString().substring(0,2)}</span></a></li>
            </g:each>
        </ul>
    </li>
</ul>
<!-- End form language selector -->