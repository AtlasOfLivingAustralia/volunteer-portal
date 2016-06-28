<%@ page import="au.org.ala.volunteer.AchievementDescription" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-main"/>
    <meta name="section" content="home"/>
    <title><cl:pageTitle title="About"/></title>
    <content tag="selectedNavItem">bvp</content>
    <style>
    a[name]:before {
        display: block;
        content: " ";
        margin-top: -83px;
        height: 83px;
        visibility: hidden;
    }
    </style>
</head>
<body>

<cl:headerContent title="${message(code: 'default.about.label', default: 'About DigiVol')}">
    <%
        pageScope.crumbs = [
        ]
    %>
</cl:headerContent>

<section class="main-content">
    <div class="container">
        <div class="row">
            <div class="col-sm-8">
                <h1>About DigiVol.</h1>
                <h2 class="body-heading"><a name="what-is-digivol">What is DigiVol.</a></h2>
                <p>
                    DigiVol is a crowdsourcing platform that was developed by the Australian Museum in collaboration with the Atlas of Living Australia.
                </p>
                <p>
                    DigiVol is used by many institutions around the world as a way of combining the efforts of many volunteers to digitise their data.
                </p>
                <p>
                    This data may be in the form of museum object labels, field notebooks and diaries, recording sheets, registers or photographs.
                </p>
                <p>
                    There are many ways of extracting information or data from images depending on what the end use will be. Some data can be extracted from museum labels and
                    field notebooks by transcribing (or typing out) the handwritten words. Other forms of collecting data may be by tagging images or identifying animals and
                    their behaviour in the images.
                </p>
                <p>
                    DigiVol uses several approaches of data collection in its website. Online volunteers are presented with tutorials to help them get started in joining a
                    project (virtual expedition).
                </p>
                <h2 class="body-heading"><a name="why-capture-this-data">Why capture this data</a></h2>
                <p>
                    Capturing data into a digital form is important as it helps researchers to have access to data that can be used for a whole variety of studies.
                </p>
                <p>
                    An example of this is by helping scientists and planners better understand, utilise, manage and conserve biodiversity. They can use data extracted from
                    museum specimen labels and field note books for many uses, including:
                </p>
                <ul>
                    <li>Understanding the relationships between species (important in determining potential agricultural pests or potential medical applications);</li>
                    <li>The distribution of species (for understanding how best to conserve individual species or ecosystems);</li>
                    <li>Identification of species from morphological or genetic characters (for example being able to identify birds involved in aircraft incidents).</li>
                </ul>
                <p>
                    This data, once captured, becomes available through a broad range of mechanisms that make it accessible to the scientific and broader communities. These
                    mechanisms might include websites such as:
                </p>
                <ul>
                    <li><a href="http://australianmuseum.net.au/research-and-collections">Individual institutions collections and associated databases</a></li>
                    <li><a href="http://www.ala.org.au">The Atlas of Living Australia</a></li>
                    <li><a href="http://www.gbif.org/">The Global Biodiversity Information Facility</a></li>
                </ul>
                <h2 class="body-heading"><a name="submit-an-expedition">Submit an expedition</a></h2>
                <p>
                    DigiVol is open to any institution or individual who has a project that would be well suited to DigiVol volunteers.
                </p>
                <p>
                    Any proposed expedition will need to conform to an existing DigiVol template (fields may be added or removed) or have sufficient funds to enable the
                    development of a new task template.
                </p>
                <p>
                    If you are interested in posting an expedition on DigiVol and you have material that would be suitable please contact us (<a href="mailto:DigiVol@austmus.gov.au">DigiVol@austmus.gov.au</a>)
                </p>
                <h2 class="body-heading"><a name="useful-references">Useful references</a></h2>
                <div class="embed-responsive embed-responsive-16by9">
                    <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/x9404is3RJ8"></iframe>
                </div>

                <h3>Papers:</h3>

                <ul>
                    <li><a href="http://bioscience.oxfordjournals.org/content/early/2015/02/19/biosci.biv005.abstract">Accelerating the Digitization of Biodiversity Research Specimens through Online Public Participation</a></li>
                    <li><a href="http://mwa2015.museumsandtheweb.com/paper/transcribing-between-the-lines-crowd-sourcing-historic-data-collection/">Transcribing between the lines: crowd-sourcing historic data collection</a></li>
                </ul>

                <p>
                    <a href="http://australianmuseum.net.au/digivol">Australian Museum DigiVol resources</a>
                </p>
                <h1>How can I help?</h1>
                <h2 class="body-heading"><a name="registering">Become an online volunteer</a></h2>
                <p>
                    Anyone can become a DigiVol volunteer, all you need is a computer, internet access and an email address.
                </p>
                <p>
                    To become a volunteer you must register on DigiVol before you can join an expedition. To do so you need to provide your email address and a few details
                    <a href="https://auth.ala.org.au/cas/login?service=http://volunteer.ala.org.au/">here</a>. By registering you will be given access to DigiVol and associated forums. You
                    will also receive occasional updates and newsletters.
                </p>
                <h2 class="body-heading"><a name="transcribing">How to get started.</a></h2>
                <p>
                    Once you have registered, you can join any expedition in the list on the front page of the website. After choosing an expedition, click on the 'Get
                    Started' button.
                </p>
                <p>
                    When you do this, you will be presented with your first task. For museum specimen labels you will see a picture of a specimen and its labels and you will
                    need to transcribe the information from the labels into the set of fields in the template below the image. Each expedition has a tutorial attached that
                    explains the process and how to fill out the template. We HIGHLY recommend that all users read the tutorial for an expedition before starting transcribing.
                </p>
                <p>
                    Once you have completed filling out the template of your task, click 'Submit for validation' and you can go to your next task. You can transcribe as many
                    or as few tasks as you like.
                </p>
                <p>
                    If you have any questions about a task you can visit the discussion forums or contact us by email. To see your progress and your contribution you can visit
                    your 'Notebook' through the 'My Profile' tab.
                </p>
                <h2 class="body-heading"><a name="what-happens-next">What happens next.</a></h2>
                <p>
                    When an expedition is finished, the tasks will be validated by an experienced volunteer. The data will then be returned to the institution, checked and
                    processed. Data can then be uploaded to the relevant data sharing portal such as Atlas of Living Australia (https://www.ala.org.au/), where it can be used
                    by the general public and the research community.
                </p>
                <h2 class="body-heading"><a name="examples">Examples</a></h2>
                <p>
                    <asset:image src="digivol-example.png" class="img-responsive"/>
                </p>

            </div>
            <div class="col-sm-4">
                <g:render template="/leaderBoard/stats" model="[disableStats: true]"/>
            </div>
        </div>
    </div>
</section>
</body>
</html>
