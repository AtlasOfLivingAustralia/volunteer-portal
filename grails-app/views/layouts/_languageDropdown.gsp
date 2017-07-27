<ul class="dropdown-menu language-dropdown-menu">
    <g:each in="${grailsApplication.config.languages.enabled.tokenize(',')}">
        <li ><a href="?lang=${it}"><span class="locale">${it.toString().substring(0,2)}</span></a></li>
    </g:each>
</ul>
