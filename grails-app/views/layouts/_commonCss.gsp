<%-- Allow overriding of primary branding colour --%>
<meta name="theme-color" content="${g.pageProperty(name: "page.primaryColour", default: "#d5502a")}"/>
<style>
    section#footer .footer-brand,
    section#footer .footer-brand:hover,
    .navbar-brand,
    .navbar-brand:hover,
    .digivol-tab img,
    body .navbar .navbar-brand,
    body .navbar .navbar-brand:hover,
    body .btn-primary,
    body .btn-primary:hover,
    body .btn-primary:focus,
    body .btn-primary:active,
    body .btn-primary.active,
    .progress .progress-bar-transcribed,
    .key.transcribed,
    .pagination > .active > span,
    .pagination > .active > span:hover,
    .transcription-actions .btn.btn-next,
    .transcription-branding .institution-logo-main {
        background-color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }
    .progress .progress-bar-success {
        background-color: rgba( <cl:hexToRbg hex="${g.pageProperty(name:"page.primaryColour", default:"#d5502a")}"/>, .5 );
    }

    body .navbar,
    body.digivol .navbar,
    .pagination > .active > span,
    .pagination > .active > span:hover {
        border-color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }

    body .badge,
    body .badge:hover,
    body .not-a-badge,
    body .not-a-badge:hover,
    .pagination > li > a,
    .primary-color {
        color: <g:pageProperty name="page.primaryColour" default="#d5502a"/>;
    }
</style>