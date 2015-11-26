<%-- Allow overriding of primary branding colour --%>
<meta name="theme-color" content="${g.pageProperty(name: "page.primaryColour", default: "#d5502a")}"/>
<style>
    .navbar-brand,
    .navbar-brand:hover,
    .navbar-brand:focus,
    .navbar-brand:active,
    .digivol-tab img,
    body .navbar .navbar-brand,
    body .navbar .navbar-brand:hover,
    body .navbar .navbar-brand:focus,
    body .navbar .navbar-brand:active,
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