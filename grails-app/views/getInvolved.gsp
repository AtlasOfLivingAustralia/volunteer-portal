<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title><g:message code="default.application.name"/> - Atlas of Living Australia</title>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <style>

    #transcribeButton {
        margin-bottom: 5px;
        background: #df4a21;
        color: white;
        /*vertical-align: bottom;*/
    }

    </style>
</head>

<body>

<cl:headerContent title="${message(code: 'default.about.label', default: 'How can I volunteer?')}"
                  selectedNavItem="getinvolved"/>

<p>
    The <a href="http://ala.org.au">Atlas of Living Australia</a>, in collaboration with the <a
        href="http://australianmuseum.net.au/">Australian Museum</a>, developed <g:message
        code="default.application.name"/> to harness the power of online volunteers to digitise biodiversity data that is locked up in biodiversity collections, field notebooks and survey sheets.
</p>

<h3>Registering</h3>

<p>
    You can contribute by registering with the Atlas of Living Australia and transcribing information from photographed labels or documents.
</p>

<p>
    Anyone can register, by providing their email address and a few details <a
        href="http://auth.ala.org.au/userdetails/registration/createAccount">here</a>. This will give you access to <g:message
        code="default.application.name"/> and associated forums, and you’ll receive occasional updates from the Atlas of Living Australia by email.
</p>

<h3>Transcribing</h3>

<p>
    After you’ve registered, you can choose any expedition and click on the
    <span class="btn" id="transcribeButton">
        Start transcribing <img
            src="http://www.ala.org.au/wp-content/themes/ala2011/images/button_transcribe-orange.png" width="37"
            height="18" alt="">
    </span> button.
</p>

<p>
    When you do this, you’ll see a picture of a specimen and its labels or a page from a diary or field notes, and a set of fields to transcribe what you see. Each expedition has a tutorial document that explains the process, and many fields have help text if you hover over the <cl:helpText>Help text icon</cl:helpText>
</p>

<p>
    Once you’ve transcribed all the information from one image, click ‘submit’ and the next task will appear. You can transcribe as many or as few tasks as you like.
</p>

<h3>What happens next?</h3>

<p>
    When an expedition is finished, the data is returned to the institution, checked and processed, and if relevant to Australia is uploaded to the Atlas of Living Australia (ALA), where it can be used by the general public and the research community. Expedition data from non-Australian institutions are uploaded to sites like the <a
        href="http://www.gbif.org/">Global Biodiversity Information Facility</a> (which also receives the data from the ALA) from where it is available to scientists around the world.
</p>

<p>
    If you encounter any problems, you can visit the discussion forums or contact us by <a
        href="mailto:DigiVol@austmus.gov.au">email</a>.
</p>

<p>
    Thank you for joining our team. ALA online volunteers have transcribed tens of thousands of records to date, and have made a valuable contribution to many institutions’ datasets and the science that they underpin.
</p>

<hr/>

<p>

<div>
    An example specimen page:
    <div>
        <img class="img-polaroid" src="${resource(dir: "images/getinvolved", file: "bvp_getinvolved_screen1.png")}"/>
    </div>
</div>
</p>
<p>

<div>
    An example journal:
    <div>
        <img class="img-polaroid" src="${resource(dir: "images/getinvolved", file: "bvp_getinvolved_screen2.png")}"/>
    </div>
</div>
</p>
</body>
</html>
