<%-- Allow overriding of primary branding colour --%>
<g:set var="primaryColour" value="${g.pageProperty(name: 'page.primaryColour', default: '#d5502a')}"/>
<meta name="theme-color" content="${primaryColour}"/>
<style>
    :root {
        --brand-primary: ${primaryColour};
    }

    .navbar-brand,
    .navbar-brand:hover,
    .navbar-brand:focus,
    .navbar-brand:active,
    .digivol-tab img,
    body .navbar .navbar-brand,
    body .navbar .navbar-brand:hover,
    body .navbar .navbar-brand:focus,
    body .navbar .navbar-brand:active,
    .progress .progress-bar-transcribed,
    .key.transcribed,
    .transcription-branding .institution-logo-main {
        background-color: var(--brand-primary);
    }

    .progress {
        .progress-bar-success {
            background-color: color-mix(in srgb, var(--brand-primary) 50%, transparent);
        }
    }

    body .navbar,
    body.digivol .navbar {
        border-color: var(--brand-primary);
    }

    @media (max-width: 991.98px) {
        .navbar .navbar-collapse.show {
            display: block;
            visibility: visible;
            opacity: 1;
        }

        .navbar {
            overflow: visible;
        }

        .navbar .navbar-nav {
            position: static;
        }
    }
</style>