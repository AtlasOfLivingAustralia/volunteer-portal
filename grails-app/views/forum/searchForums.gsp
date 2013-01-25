<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Volunteer Portal - Atlas of Living Australia</title>
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'vp.css')}"/>
        <link rel="stylesheet" href="${resource(dir: 'css', file: 'forum.css')}"/>
        <script type="text/javascript" src="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.pack.js')}"></script>
        <link rel="stylesheet" href="${resource(dir: 'js/fancybox', file: 'jquery.fancybox-1.3.4.css')}"/>

        <style type="text/css">
        </style>

    </head>

    <body class="sublevel sub-site volunteerportal">

        <script type="text/javascript">

            $(document).ready(function() {
            });

        </script>

        <cl:navbar selected="forum"/>

        <header id="page-header">
            <div class="inner">
                <cl:messages/>
                <vpf:forumNavItems lastLabel="Search results" />
            </div>
        </header>

        <div class="inner">
            <h2>Search Results</h2>
            <p>
                You searched for "${query}".
                <br />
                <strong>${results.totalCount} message(s) found.</strong>
            </p>
            <section id="searchResults">
                <vpf:searchResultsTable searchResults="${results}"/>
            </section>
        </div>

    </body>
</html>
