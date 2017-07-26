<ul class="dropdown-menu">
    <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
        <li ><a href="?lang=${it}"><span class="locale">${it.toString().substring(0,2)}</span> ${message(code: "language."+it)}</a></li>
    </g:each>
</ul>
