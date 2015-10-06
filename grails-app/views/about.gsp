<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
</head>

<body>

<cl:headerContent title="${message(code: 'default.about.label', default: 'About DigiVol')}" selectedNavItem="aboutbvp"/>

<div class="row">
    <div class="span12">

        <p>
            The <a href="http://www.ala.org.au">Atlas of Living Australia</a>, in collaboration with the <a
                class="external" href="http://www.australianmuseum.net.au">Australian Museum</a>, developed <g:message
                code="default.application.name"/> to harness the power of online volunteers (also known as crowdsourcing) to digitise biodiversity data that is locked up in biodiversity collections, field notebooks and survey sheets.
        </p>

        <H3>Why capture this data?</H3>

        <span>This data has many uses, including:</span>
        <ul>
            <li>understanding the relationships between species (important in determining potential agricultural pests or potential medical applications);</li>
            <li>the distribution of species (for understanding how best to conserve individual species or ecosystems);</li>
            <li>identification of species from morphological or genetic characters (for example being able to identify birds involved in aircraft incidents).</li>
        </ul>

        <p>
            By helping us capture this information into digital form you are helping scientists and planners better understand, utilise, manage and conserve our precious biodiversity.
        </p>

        <span>
            This data, once captured, becomes available through a broad range of mechanisms that make it accessible to the scientific and broader communities.  These mechanisms include websites such as :
        </span>
        <ul>
            <li><a class="external"
                   href="http://www.australianmuseum.net.au/research-and-collections">Individual institutions collections and associated databases</a>
            </li>
            <li>The <a class="external" href="http://www.ala.org.au">Atlas of Living Australia</a>
            <li>The <a class="external" href="http://www.gbif.org/">Global Biodiversity Information Facility</a>
            </li>
        </ul>

        <h3>Interested in becoming an online volunteer?</h3>

        <p>
            Anyone can contribute by registering with the Atlas of Living Australia and transcribing information from photographed labels or documents.
            You can see more information about volunteering <a href="${createLink(controller: 'getInvolved')}">here</a>.
        </p>

        <h3>Submit an expedition</h3>

        <p>
            <g:message
                    code="default.application.name"/> is open to any institution or individual who has suitable biodiversity
            information that needs transcribing, whether that be in the form of specimen labels, field notes, survey sheets
            or something similar.
        </p>

        <p>
            Any proposed expedition will need to conform to an existing transcription task template, be suitable for an
            existing template with some minor adjustment, or have sufficient funds to enable the development of a new
            transcription task template.
        </p>

        <p>
            So if you think you have some material that would be suitable for creating an expedition in <g:message
                    code="default.application.name"/> please get in touch with me: <strong>paul.flemons at austmus.gov.au</strong>
        </p>

        <H3>Some useful references:</H3>
        <ul>
            <li><a class="external"
                   href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1693343/pdf/15253354.pdf">Biodiversity informatics: managing and applying primary biodiversity data</a>
            </li>
            <li><a class="external"
                   href="http://www.youtube.com/watch?v=x9404is3RJ8">Video showing how data is shared and what it is used for</a>
            </li>
        </ul>
    </div>
</div>
</body>
</html>
