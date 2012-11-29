<%@ page contentType="text/html;charset=UTF-8"  %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <style type="text/css">

        div#wrapper > div#content {
            background-color: transparent !important;
        }

        .volunteerportal #page-header {
        	background:#f0f0e8 url(${resource(dir:'images/vp',file:'bg_volunteerportal.jpg')}) center top no-repeat;
        	padding-bottom:12px;
        	border:1px solid #d1d1d1;
        }

        .screenshot {
          width: 50%;
        }

    .tutorialText {
      font-size: 1.2em;
    }

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="tutorials" />

    <header id="page-header">
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li><a href="${createLink(controller:'tutorials')}"><g:message code="default.tutorials.label" default="Tutorials"/></a></li>
            <li class="last"><g:message code="default.fieldnotestutorial.label" default="Tutorials - Transcribing Field Notes" /></li>
          </ol>
        </nav>
        <h1>Transcribing Field Notes</h1>
      </div>
    </header>
    <div>
      <div class="inner">

        <h2>Notes on transcribing</h2>
        <p class="tutorialText">Transcribe exactly what is in the image with exceptions to the below notes:</p>
        <ul class="tutorialText">
          <li>In general, parentheses are used when they are part of the original document and square brackets are used for insertions by the transcriber.</li>
          <li>If the author has used symbols and contractions (short way) wherever possible the transciber should type the symbol or contraction and then type the full word in square brackets. Some examples include: if a + has been used put  +[and] or if the author has written Jan. type as Jan[uary] or NP would be N[ational] P[ark].</li>
          <li>If unsure of the word put a [?] in the transcribe box, if unsure of many words use [?][?] for each word, if unsure of letters in a word put a [?] for the letter. For example: lett[?]r. Also use a [?] for illegible handwriting or damaged handwritten pages.</li>
          <li>If the author has written in the margin of the page put this transcribed text at the bottom of the page with [margin] before it.</li>
          <li>If the text has been underlined just transcribe as normal.</li>
          <li>If there are Shorthand symbols , then use [shorthand symbols] within square brackets</li>
          <li>Misspellings can be marked with a * and then spelled the correct way in square brackets. For example: rendersveu*[rendezvous]</li>
          <li>If there is a diagram, then use [diagram] within square brackets</li>
          <li>If a word or sentence has been crossed out or erased put these words between &lt; and &gt; For example: &lt;crossed out&gt;
          <li>If there is text inserted ^ into a sentence, then incorporate into the text without indicator^.</li>
          <li>Put in all species that appear in the text into the fields below the transcription box. Include animals and plants. This information will be used in a database of species observations.</li>
        </ul>


        <hr />

        <h2>How to Transcribe Field Notes</h2>

        <p class="tutorialText">Login to the Biodiversity Volunteer Portal using your email and password.</p>
        <p class="tutorialText">Join a virtual expedition.</p>
        <br />
        <img src="${resource(dir: 'images/tutorials', file:'fieldnotes_01.png')}" />
        <p class="tutorialText">To join a field notes expedition choose an expedition with the field notes icon in the type column.
        Once in the expedition, click on <img src="${resource(dir:'images/tutorials', file:'fieldnotes_02.png')}" />
        </p>

        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_03.png')}" />

        <p class="tutorialText">
          To zoom into the image drag the white square in the zoom image bar to the right. When a page has been zoomed
          in, it can be navigated by either holding the mouse button down and dragging the image or by moving the scroll
          bars. By clicking on the ‘show previous’ or ‘next journal page’ buttons it will bring up the previous or next
          field note page as shown below. The rotate button will rotate the page 180 degrees to the right, this may be
          needed if the author has written on the side of the page.
        </p>

        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_04.png')}" />
        <p></p>
        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_05.png')}" />
        <p class="tutorialText">Transcribe all text into the box as it appears in the image.</p>
        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_06.png')}" />
        <p class="tutorialText">If the field notes are double paged, the template will be as above.</p>
        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_07.png')}" />
        <p class="tutorialText">The two boxes correspond to the pages in the image. Transcribe all the text from the left hand page into the left box and all text from the right hand page into the right hand side.</p>
        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_08.png')}" />
        <p></p>
        <img class="screenshot" src="${resource(dir: 'images/tutorials', file:'fieldnotes_09.png')}" />

        <p class="tutorialText">Some of the pages may have printed text in the image due to the use of optical character recognition (OCR).
        If you open a task with printed text, this text may already appear in your transcribe all text boxes. This text
        needs to be checked with the image and any corrections made. If the OCR’s text is mostly unclear, then delete
        the text and transcribe printed text.If the page has both OCR’s text and handwriting on it, then this will also
        need to be transcribed as the optical character recognition (OCR) software does not recognise handwriting.</p>
        <img src="${resource(dir: 'images/tutorials', file:'fieldnotes_10.png')}" />

        <p class="tutorialText">
          When you have finished the whole transcription, fill out the fields below the transcribe all text box with
          any species or common names that appear in the text. Enter the date in the format YYYY-MM-DD, if you only have
          the year and the month, record it as YYYY-MM. If the date cannot be seen in this page the show previous
          journal button may be used to find the most recent date mentioned, use that. Click on Add row if several species
          appear in the text. If no date can be found, insert the date of the Field Notebook or Diary (if you know it)
          and failing that just leave date blank.
        </p>
        <img src="${resource(dir: 'images/tutorials', file:'fieldnotes_11.png')}" />
        <p class="tutorialText">
          The notes section is for the transcriber to record any comments that may help in validating the task.
          When all transcribing has been complete, click on the submit for validation or save unfinished record to return to it at a later date.
        </p>
      </div>
    </div>
  </body>
</html>
