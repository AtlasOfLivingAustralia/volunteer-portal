<%-- Allow overriding of primary branding colour --%>
<meta name="theme-color" content="${g.pageProperty(name: "page.primaryColour", default: "#d5502a")}"/>
<style>
    :root {
        --brand-primary: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
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