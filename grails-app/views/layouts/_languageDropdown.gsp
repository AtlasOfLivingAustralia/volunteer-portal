
<script type="text/javascript">
    function parseQueryString() {
        var queryString = {};
        var query = window.location.search.substring(1);
        if(query !== "") {
            var vars = query.split("&");
            for (var i=0;i<vars.length;i++) {
                var pair = vars[i].split("=");
                queryString[pair[0]] = pair[1];
            }
        }
        return queryString;
    }
    // Sets the parameter lang=en_US in the URL and keeps the existing parameters as is
    function setLanguage(elementId, language) {
        var link = document.getElementById(elementId);
        var queryStringMap = parseQueryString();
        queryStringMap['lang']=language;
        var search="";
        for (var key in queryStringMap) {
            if (queryStringMap.hasOwnProperty(key)) {
                search += key + "=" + queryStringMap[key] + "&";
            }
        }
        link.setAttribute("href", "?"+search.substr(0,search.length-1));
        return false;
    }
</script>

<ul class="dropdown-menu language-dropdown-menu">
    <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
        <li><a class="selectable" onclick="setLanguage('language-${it.toString()}', '${it.toString()}')" id="language-${it.toString()}"><span class="locale">${it.toString().substring(0,2)}</span></a></li>
    </g:each>
</ul>