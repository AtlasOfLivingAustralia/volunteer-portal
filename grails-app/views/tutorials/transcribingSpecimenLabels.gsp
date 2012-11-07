<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <g:javascript library="jquery.tools.min"/>
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
            <li><a href="${createLink(uri: '/tutorials.gsp')}"><g:message code="default.tutorials.label" default="Tutorials"/></a></li>
            <li class="last"><g:message code="default.specimenlabelstutorial.label" default="Tutorials - Transcribing Specimen Labels" /></li>
          </ol>
        </nav>
        <h1>Transcribing Specimen Labels</h1>
      </div>
    </header>
    <div>
      <div class="inner">

        <a name="toc"></a>
        <t:p>Table of Contents</t:p>
        <t:toc>
          <t:tocEntry anchor="Points to remember when transcribing specimen labels">
            <t:tocEntry anchor="Specimen Information"/>
            <t:tocEntry anchor="Transcribe all text" />
            <t:tocEntry anchor="Collection event" />
            <t:tocEntry anchor="Miscellaneous" />
          </t:tocEntry>
          <t:tocEntry anchor="How to Transcribe Specimen Labels">
            <t:tocEntry anchor="Specimen Information[2]" />
            <t:tocEntry anchor="Transcribe All Text[2]" />
            <t:tocEntry anchor="Collection Event[2]">
              <t:tocEntry anchor="Abbreviations" />
            </t:tocEntry>
            <t:tocEntry anchor="Miscellaneous[2]" />
            <t:tocEntry anchor="Identification[2]" />
            <t:tocEntry anchor="Notes[2]" />
            <t:tocEntry anchor="Finishing or saving a task[2]" />
          </t:tocEntry>
        </t:toc>

        <t:h2>Points to remember when transcribing specimen labels</t:h2>

        <t:h3>Specimen Information</t:h3>
        <t:p>
          If there is a Catalogue No. in the ‘Specimen Information’ section it must match the number that appears on the
          label in the image. If the numbers are different please email the feedback and support tab on the far right of
          the screen.
        </t:p>

        <t:h3>Transcribe all text</t:h3>
        <t:ul>
          <li>Transcribe each line on the label on a separate line.</li>
          <li>If any label information is duplicated (appears twice) only transcribe this data once. (Provide example with image and resultant text)</li>
          <li>If a match is found in the ‘Copy values from previous’ it will copy over all the transcribed information except the collection event data. So you will need to still complete the collection event details.</li>
        </t:ul>

        <t:h3>Collection event</t:h3>
        <t:ul>
          <li><b>Find existing collection event</b>: When choosing a collection event make sure collector(s), date(s) and place match. If for example the date differs by a day do not choose this collection event.</li>
          <li><b>Find existing locality</b>: If the initial search doesn’t find an existing locality try expanding abbreviations, inserting or removing spaces and commas or simplifying the locality description, eg by deleting the state. Example If “Broome,  WA” doesn’t get a result try “Broome” or “Broome Western Australia”></li>
          <li><b>Use Mapping Tool</b>: Interpret the locality information in the labels into a form that is most likely to result in as accurate geographic coordinates as possible. Expand abbreviations, and remove unnecessary words and punctuation. E.g. &quot;Scott Is. Tweed R. near Tumbulgum NSW&quot; would become &quot;Scott Island, Tweed River, Tumbulgum, NSW&quot;. If the map doesn’t come up with the correct location then try breaking the description up into single words to see if the map tool can find a location then. Where the map tool cannot find a location simply fill in the State/territory and Country fields. A summary of the abbreviations you may encounter with specimen labels is listed below.</li>
          <li>Please choose an uncertainty value that best represents the area described by a circle with radius of that value from the given location. This can be seen as the circle around the point on the map. If in doubt choose a larger area. For example if the location is simply a small town then choose an uncertainty that encompasses the town and some surrounding area. The larger the town the larger the uncertainty would need to be as you will not know exactly where the specimen was collected from.</li>
        </t:ul>

        <t:h3>Miscellaneous</t:h3>
        <t:ul>
          <li>The ‘Collection’ field is typically a persons private collection that has been presented (Pres.) to the museum, for example, Greg Daniels Collection. If Pres. has been written in front of the name put it as this in the ‘Collection’ field.</li>
          <li>The ‘Other numbers’ field is for any other numbers that appear on the labels that is not listed in the as the catalogue number. This includes M numbers, E numbers, private collection numbers and field station numbers. If there is more than one number, separate them with a semicolon (;)making sure that the letter prefix is kept with the number, for example, M561;E6395.</li>
          <li>The ‘Identifier’ is the person who identified the scientific name of the specimen. You may need to use a process of elimination to decide if a name is that of an identifier. If the name doesn’t appear to be a collector or scientific name author then it may be the specimen identifier, sometimes shown as DET, determined or ID.</li>
          <li>The ‘Authorship’ field is used to record the name of the author of the scientific name and the date. The author’s name is always written after the scientific name. See the example below.</li>
        </t:ul>
        <img src="${resource(dir: 'images/tutorials', file:'labels_01.png')}" />
        <t:p>In this example the Collector is G. Daniels, the Identifier is M. J. Fletcher and the Author is Erich.</t:p>

        <t:h2>How to Transcribe Specimen Labels</t:h2>
        <t:p>Login to the Biodiversity Volunteer Portal using your email and password.</t:p>
        <t:p>Join a virtual expedition. </t:p>
        <t:screenshot file ="labels_02.png" />
        <t:p>To join a specimen expedition choose an expedition with the Specimens icon in the type column.</t:p>
        <t:p>Once in the expedition, click on <img src="${resource(dir:"images/tutorials", file:'labels_03.png')}" /></t:p>

        <t:h3>Specimen Information[2]</t:h3>
        <t:screenshot file="labels_04.png" />
        <t:p>The ‘Specimen Information’ section includes the Catalogue No. If present this number must match the number that appears on the label in the image. If the numbers are different please email the feedback and support tab on the far right of the screen.</t:p>
        <t:p>At the top left of the image the + and - will zoom in and out of the image and the arrows will pan up, down, left and right. Alternatively when zoomed in, you can hold the mouse button down to move around the image.</t:p>

        <t:h3>Transcribe All Text[2]</t:h3>
        <t:screenshot file="labels_05.png" />
        <t:p>In the ‘Transcribe All Text’ section, record exactly what appears in the labels in the ‘All text’ box. Then extract out only the location into the ‘Verbatim Locality’ box below.</t:p>
        <t:screenshot file="labels_06.png" />
        <t:p>If the label information has been duplicated (appears more than once) only transcribe this data once.</t:p>
        <t:screenshot file="labels_07.png" />
        <t:p>If a label has symbols in the latitude and longitude, use the symbols at the bottom for your transcription.</t:p>
        <t:p><t:img file="labels_08.png"/>These symbols may be needed when transcribing for degrees, minutes and seconds. Note that in the second example above, degrees and minutes are separated by : but this still means 37 degrees, 59 minutes.</t:p>
        <t:p><t:img file="labels_09.png"/>These symbols may be needed when transcribing if the male and female symbols have been used in the label.</t:p>
        <t:screenshot file="labels_10.png" />
        <t:p>The ‘Copy values from a previous task’ button can be used if the transcriber has a label whose information is exactly the same as one of the previous completed tasks. Clicking on
          <t:img file="labels_11.png"/> will bring up the below window.
        </t:p>
        <t:screenshot file="labels_12.png" />
        <t:p>This function allows the transcriber to search through previous tasks and copy the information to their current task without having to re-type all the data again. Move the pink box around to zoom into the image.</t:p>
        <t:p>Scroll through the tasks by clicking on Previous and Next or type part of the label text and click on search to see if there are any other matches. Note that you can only scroll through the tasks you have completed in the project that you are in. </t:p>
        <t:screenshot file="labels_13.png" />
        <t:p>If an exact match is found, or one that you would like to use part of, click on ‘Copy’. By doing this it will copy over all the transcribed information except the collection event data. If the details are not an exact match you will need to edit the text in the fields that have been copied. If there is suitable compleltely or partially matching task, click on the cancel button to go back to the current task being worked on.</t:p>
        <t:p>After completing the ‘transcribe all text’ section some of the information will need to be separated out into other different sections.</t:p>

        <t:h3>Collection Event[2]</t:h3>
        <t:screenshot file="labels_14.png" />
        <t:p>The next section is the Collection Event section and is probably the most important section of the template. A Collection Event is used to record details of actual collection activities such as field trips, expeditions and archaeological digs. A collection event is unique in that it is an event that has the same collector(s), on the same date(s), at the same site.</t:p>
        <t:p>To see if a collection event already exists for the label task, first type in either a collector or event date into Step 1. </t:p>
        <t:p>Enter the date in the format YYYY-MM-DD, if you only have the year and the month record it as YYYY-MM, if you have a range of dates it can be recorded as YYYY-MM-DD/YYYY-MM-DD</t:p>
        <t:p>When you start typing into the Collector field, a drop down box will appear. Where possible choose from this list. If you cannot find the name, first remove or add fullstops or spaces to see if you can find a match for the name in your label, if no match is found type the new name in. The format to use when adding new collector names is with only a space between the last initial and last name, for example, &quot;M.S. Moulds&quot;.</t:p>
        <t:p>Once the date and/or collector have been inserted click on <t:img file="labels_15.png"/></t:p>
        <t:screenshot file="labels_16.png" />
        <t:p>In the example above we can match the date, the collector and the locality to the label therefore this is the collection event to choose and you can click on the select event button.</t:p>
        <t:screenshot file="labels_17.png" />
        <t:p>By clicking on the select event button it will blank out the rest of this section and you can go on  to complete the other sections.</t:p>
        <t:screenshot file="labels_18.png" />
        <t:p>In this example the collector and the locality match <b>but the date is not the same</b>. <u>Do not</u> choose this collection event as it is not the same collection event as the one on our label. Close this window.</t:p>
        <t:screenshot file="labels_19.png" />
        <t:p>If no matching Collection Event exists a new collection event will have to be created for this task. Go  to ‘b. Create a new Collection event’.</t:p>
        <t:p>There are 2 parts to creating a new collection event. Firstly, see if you can find an existing locality. Do this by clicking on <t:img file="labels_20.png" /></t:p>
        <t:screenshot file="labels_21.png" />
        <t:p>Type in the locality as it appears on the label and click search. If the locality exists, a list will appear. As you scroll down the list, the red pointers on the map will bounce up and down. Choose a locality that matches your locality in the label. If a locality is close and you know it is the same place, then choose that one. In the example above the label says ‘Middle Claudie Riv’, this is obviously River so you would be able to choose from the list.</t:p>
        <t:screenshot file="labels_22.png" />
        <t:p>If the initial search doesn’t find an existing locality try expanding abbreviations, inserting or removing spaces and commas or simplifying the locality description, eg by deleting the state. Example If &quot;Broome,  WA&quot; doesn’t get a result try &quot;Broome&quot; or &quot;Broome Western Australia&quot;. If you still get no matching result this window can be closed. </t:p>
        <t:screenshot file="labels_23.png" />
        <t:p>If an existing locality does not exist then you will have to go to ‘ii. Create a new locality’.</t:p>
        <t:p>Click on <t:img file="labels_24.png"/></t:p>
        <t:p>The mapping tool is used to find the latitude and longitude for your ‘new’ locality i.e. the one that doesn’t already exist in the database.</t:p>
        <t:screenshot file="labels_25.png" />
        <t:p>The + or – will zoom in and out of the map and the arrows will pan left, right, up and down, alternatively you can hold the mouse button down to move the map. The red marker is pointing to the location and can be moved. The scale is in the bottom left corner and may help with adjusting the uncertainty.</t:p>
        <t:p><i>Locality Search</i>: Interpret the locality information in the labels into a form that is most likely to result in as accurate geographic coordinates as possible. Expand abbreviations, and remove unnecessary words and punctuation. E.g. &quot;Scott Is. Tweed R. near Tumbulgum NSW&quot; would become &quot;Scott Island, Tweed River, Tumbulgum, NSW&quot;. If the map doesn’t come up with the correct location then try breaking the description up into single words to see if the map tool can find a location then. Where the map tool cannot find a location simply fill in the State/territory and Country fields. See below for a summary of the abbreviations you may encounter with specimen labels.</t:p>

        <t:h4>Abbreviations</t:h4>
        <table border="1">
          <tbody>
            <tr><td><strong>Abbreviation</strong></td><td><strong>Enter as</strong></td><td><strong>comments</strong></td></tr>
            <tr><td>5 mi S town</td><td>5 miles South of town</td><td>&nbsp;</td></tr>
            <tr><td>Abo. Res.</td><td>Aboriginal Reserve</td><td>&nbsp;</td></tr>
            <tr><td>Ag, Agric</td><td>Agricultural or Agriculture</td><td>find out correct status before entering</td></tr>
            <tr><td>Approx.</td><td>About</td><td>&nbsp;</td></tr>
            <tr><td>b.</td><td>Beside</td><td>&nbsp;</td></tr>
            <tr><td>Bch</td><td>Beach</td><td>&nbsp;</td></tr>
            <tr><td>Br, Bdg Brdg</td><td>Bridge</td><td>&nbsp;</td></tr>
            <tr><td>btn</td><td>Between</td><td>&nbsp;</td></tr>
            <tr><td>C.S.I.R.O.</td><td>CSIRO</td><td>acronym, do not enter full stops</td></tr>
            <tr><td>ca, c. ~, approx.</td><td>About</td><td>&nbsp;</td></tr>
            <tr><td>Capt.</td><td>Captain</td><td>&nbsp;</td></tr>
            <tr><td>catc.</td><td>Catchment</td><td>&nbsp;</td></tr>
            <tr><td>Ck</td><td>Creek</td><td>&nbsp;</td></tr>
            <tr><td>Cons. Park</td><td>Conservation Park</td><td>&nbsp;</td></tr>
            <tr><td>d/s</td><td>down stream of</td><td>&nbsp;</td></tr>
            <tr><td>Dist.</td><td>District</td><td>&nbsp;</td></tr>
            <tr><td>Div.</td><td>Division</td><td>&nbsp;</td></tr>
            <tr><td>Exp. Stn</td><td>Experimental Station</td><td>&nbsp;</td></tr>
            <tr><td>F.R.</td><td>Fauna Reserve, Flora Reserve, Forest Reserve</td><td>find out correct status before entering</td></tr>
            <tr><td>For. Res.</td><td>Forest Reserve</td><td>&nbsp;</td></tr>
            <tr><td>Ft, ft. &#39;</td><td>Feet or Forest or Fort</td><td>find out correct status before entering</td></tr>
            <tr><td>G.B.R.</td><td>Great Barrier Reef</td><td>&nbsp;</td></tr>
            <tr><td>Harb.</td><td>Harbour</td><td>&nbsp;</td></tr>
            <tr><td>Hds</td><td>Heads</td><td>&nbsp;</td></tr>
            <tr><td>Hiway, Hway,hwy,hy</td><td>Highway</td><td>&nbsp;</td></tr>
            <tr><td>Hmsd, HS, H.S., Hsd</td><td>Homestead</td><td>&nbsp;</td></tr>
            <tr><td>Hts</td><td>Heights</td><td>&nbsp;</td></tr>
            <tr><td>Is., I., Isl., Id</td><td>Island</td><td>&nbsp;</td></tr>
            <tr><td>Jcn, Jctn, Jn</td><td>Junction</td><td>&nbsp;</td></tr>
            <tr><td>K.G.S.</td><td>King George Sound, Western Australia</td><td>&nbsp;</td></tr>
            <tr><td>Lab.</td><td>Laboratory</td><td>&nbsp;</td></tr>
            <tr><td>LHI</td><td>Lord Howe Island</td><td>enter in district field</td></tr>
            <tr><td>Lk. L.</td><td>Lake or Lagoon</td><td>find out correct status before entering</td></tr>
            <tr><td>m,mi, mil, ml</td><td>Miles or Metres</td><td>find out correct status before entering</td></tr>
            <tr><td>M&#39;di</td><td>Murrurundi, NSW (found on Dr. B.L. Middleton labels)</td><td>&nbsp;</td></tr>
            <tr><td>Mt, Mnt, Mtn, Mts</td><td>Mount or Mountain(s)</td><td>find out correct status before entering</td></tr>
            <tr><td>Mus.</td><td>Museum</td><td>&nbsp;</td></tr>
            <tr><td>N, E, W, S</td><td>North of, East of, West of, South of</td><td>retain NE, NNW etc</td></tr>
            <tr><td>N.Q.</td><td>North Queensland</td><td>enter in district field?</td></tr>
            <tr><td>N.W.V.</td><td>North West Victoria</td><td>enter in district field?</td></tr>
            <tr><td>Natl Pk</td><td>National Park</td><td>&nbsp;</td></tr>
            <tr><td>NP, Nat Pk</td><td>National Park or Nature Park</td><td>find out correct status before entering</td></tr>
            <tr><td>nr</td><td>near</td><td>&nbsp;</td></tr>
            <tr><td>NR, Nat. Res.</td><td>Nature Reserve</td><td>&nbsp;</td></tr>
            <tr><td>Nthn</td><td>Northern</td><td>&nbsp;</td></tr>
            <tr><td>P.C.</td><td>Presbyterian Church</td><td>&nbsp;</td></tr>
            <tr><td>P.P.C.</td><td>Parramatta Presbyterian Church</td><td>&nbsp;</td></tr>
            <tr><td>Pen, Penn</td><td>Peninsula or Peninsular</td><td>find out correct status before entering</td></tr>
            <tr><td>Pk</td><td>Park or Peak</td><td>find out correct status before entering</td></tr>
            <tr><td>Prom</td><td>Promontory</td><td>&nbsp;</td></tr>
            <tr><td>Pt</td><td>Point or Port</td><td>find out correct status before entering</td></tr>
            <tr><td>Ra, Rge, Rng</td><td>Range</td><td>&nbsp;</td></tr>
            <tr><td>Rd, rd</td><td>Road or road</td><td>find out correct status before entering</td></tr>
            <tr><td>Rdge</td><td>Ridge</td><td>&nbsp;</td></tr>
            <tr><td>Rec</td><td>Recreation or Recreational</td><td>find out correct status before entering</td></tr>
            <tr><td>Res.</td><td>Reserve or Reservation or Reservoir</td><td>find out correct status before entering</td></tr>
            <tr><td>Riv., R.</td><td>River</td><td>&nbsp;</td></tr>
            <tr><td>S.P.</td><td>State Park</td><td>&nbsp;</td></tr>
            <tr><td>Sd</td><td>Sound</td><td>&nbsp;</td></tr>
            <tr><td>Sect.</td><td>Section</td><td>&nbsp;</td></tr>
            <tr><td>SF, St.For.</td><td>State Forest</td><td>&nbsp;</td></tr>
            <tr><td>St</td><td>St (when =&quot;Saint&quot; in a place or persons name) or State or Street or Station</td><td>find out correct status before entering</td></tr>
            <tr><td>Stn</td><td>Station</td><td>&nbsp;</td></tr>
            <tr><td>t.off, t&#39;off</td><td>Turnoff</td><td>&nbsp;</td></tr>
            <tr><td>T.S.R., TSR</td><td>Travelling Stock Reserve</td><td>&nbsp;</td></tr>
            <tr><td>trib</td><td>Tributary</td><td>&nbsp;</td></tr>
            <tr><td>u/s</td><td>upstream of</td><td>&nbsp;</td></tr>
            <tr><td>V.R.</td><td>&nbsp;</td><td>as in Old Collection Material labelled &quot;Mitchell V.R.&quot;</td></tr>
            <tr><td>vic.</td><td>vicinity</td><td>&nbsp;</td></tr>
            <tr><td>w/land</td><td>Woodland, Wetland</td><td>find out correct status before entering</td></tr>
            <tr><td>x-ing</td><td>Crossing</td><td>&nbsp;</td></tr>
            <tr><td>S.C.A.</td><td>State Conservation Area</td><td>&nbsp;</td></tr>
            <tr><td>Cult.</td><td>Cultured</td><td>eg. bred, sometimes used in place of site on the understanding that the locality where the specimen came from is not really where the species occurs in the wild</td></tr>
          </tbody>
        </table>
        <t:p><i>Coordinate Uncertainty</i>: Please choose an uncertainty value that best represents the area described by a circle with radius of that value from the given location. This can be seen as the circle around the point on the map. If in doubt choose a larger area. For example if the location is simply a small town then choose an uncertainty that encompasses the town and some surrounding area. The larger the town the larger the uncertainty would need to be as you will not know exactly where the specimen was collected from.</t:p>
        <t:p>If you are happy you have located the right location click on ‘Copy values to main form’.</t:p>
        <t:p>By clicking on the ‘Copy values to main form’ this will populate all the remaining fields in the rest of the collection event section.</t:p>
        <t:screenshot file="labels_26.png" />
        <t:p>You are ready to go to the next section and can ‘shrink ‘ this section.</t:p>

        <t:h3>Miscellaneous[2]</t:h3>
        <t:screenshot file="labels_27.png" />
        <t:p>The Miscellaneous section contains a range of fields. Many labels will not contain information for any or all of these fields.</t:p>
        <t:p><i>Collection Method</i>: This is the method in which the specimen has been collected. Some labels will include the collection method. Some examples are pitfall trap, UV lamp, Malaise Trap, yellow pans.</t:p>
        <t:p><i>Collection</i>: This is typically a persons private collection that has been presented to the museum, for example, Greg Daniels Collection.</t:p>
        <t:p><i>Other numbers</i>: This field is for any other numbers that appear on the labels that is not the catalogue number. This includes M numbers, E numbers, private collection numbers and field station numbers. If there is more than one number, separate them with a semicolon (;)making sure that the letter prefix is kept with the number, for example, M561;E6395.</t:p>
        <t:p><i>Sex</i>: If the label has male or female on it, type in full text in this field.</t:p>
        <t:p><i>Habitat</i>: The habitat in which the specimen was found as written on the label, for example, sandy ocean beach.</t:p>
        <t:p><i>Boat details</i>: this field is used for Malacology specimens collected off a boat. These details include the vessel name, vessel type, cruise number etc. Separate each with a semicolon (;).</t:p>
        <t:p><i>Verbatim Latitude</i>: If the labels have a latitude value record it here as is on the label. Latitude is a geographic coordinate that specifies the north-south position of a point on the Earth's surface. Latitude ranges from 0° at the Equator to 90° (North or South)</t:p>
        <t:p><i>Verbatim Longitude</i>: If the labels have a longitude value record it here as is on the label. Longitude is a geographic coordinate that specifies the east-west position of a point.</t:p>
        <t:screenshot file="labels_28.png" />
        <t:p><i>Verbatim Altitude</i>: If the labels have an altitude or elevation, record it here as is on the label (see example below).</t:p>
        <t:screenshot file="labels_29.png" />
        <t:p><i>Depth (from)</i>: This field is used for the minimum depth of water that the specimen was found.</t:p>
        <t:p><i>Depth (to)</i>: This field is used for the maximum depth of water that the specimen was found.</t:p>

        <t:h3>Identification[2]</t:h3>
        <t:screenshot file="labels_30.png" />
        <t:p>If the labels contain information on the name of the organism record its name in the Identification section.</t:p>
        <t:p><i>Scientific Name</i>: the scientific name consists of two words, the first being the Genus and the second the species. Begin entering the Genus name first and an autocomplete list will offer you options as to what the name might be. Choose the one that matches exactly the text on the label (or which you think is the same name). If these do not match then enter the full text yourself.</t:p>
        <t:p><i>Identifier</i>: the person who identified the scientific name of the specimen. You may need to use a process of elimination to decide if a name is that of an identifier. If the name doesn’t appear to be a collector or scientific name author then it may be the specimen identifier, sometimes shown as DET, determined or ID.</t:p>
        <t:p><i>Date Identified</i>: When the identifier determines the scientific name. Enter the date in the format YYYY-MM-DD. If only a year and a month, YYYY-MM, if only the year, YYYY.</t:p>
        <t:p><i>Authorship</i>: Record the name of the author of the scientific name and the date. The author’s name is always written after the scientific name. See example below.</t:p>
        <t:screenshot file="labels_31.png" />
        <t:p>In this example the Collector is G. Daniels, the Identifier is M. J. Fletcher and the Author is Erich.</t:p>
        <t:p><i>Type</i>: a holotype is one particular specimen (or in some cases a group of specimens) of an organism to which the scientific name of that organism is formally attached. While there is only one holotype designated, there can be other ‘type’ specimens. The specimen will be clearly labelled if it is a type specimen and the ‘type’ can be chosen from the drop down box.</t:p>

        <t:h3>Notes[2]</t:h3>
        <t:screenshot file="labels_32.png" />
        <t:p>The notes section is to record any comments that may assist the person who will be validating the transcription of the labels. This notes section is for anything related to the labels. The feedback and support tab is for interface technical issues only.</t:p>

        <t:h3>Finishing or saving a task[2]</t:h3>
        <t:screenshot file="labels_33.png" />
        <t:p><i>Submit for validation</i>: The transcription of the label is finished and can be validated. After clicking on this button it will automatically bring up a new task. If the task that appears is a previously saved unfinished record which is only partially complete, it will need to be reviewed to ensure the information is correct.</t:p>
        <t:p><i>Save unfinished record</i>: The transcription of the labels is not complete and can be saved to be completed at a later date. This saved unfinished record will be returned to the pool of untranscribed specimens.</t:p>
        <t:p><i>Skip</i>: This may be used if the transcriber finds the labels too difficult to transcribe.</t:p>
        <t:screenshot file="labels_34.png" />

      </div>
     </div>
  </body>
</html>