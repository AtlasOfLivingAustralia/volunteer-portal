<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <link rel="icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>
      <g:javascript library="jquery-1.5.1.min"/>
      <g:javascript library="jquery.tools.min"/>
  </head>
  <body>
    <div id="vp-menu">
        <img alt="ala" src="${resource(dir:'/images/vp',file:'ala-logo.png')}"/>
        <ul>
            <li>
                <g:link controller="user" action="myStats" >
                my stats
            </g:link>
            </li>
            <li style="display:none;">
                <cl:isLoggedIn>
                    <g:link controller="project" action="list">Admin</g:link>
                </cl:isLoggedIn>
            </li>
        </ul>
    </div>
    <div id="vp-header">
        <h1>Volunteer for Australia's Biodiversity</h1>
        <h2>Join one of our virtual expeditions</h2>
        <p>and help capture the wealth of information hidden in our Museums and Herbaria.
        Help turn this information into valuable knowledge that will be used for understanding the relationships
        between organisms, learning where they live and how they might be affected by habitat loss and climate change.</p>
    </div>
    <div id="project-picker">
        <p>Browse our current projects and click on one to start the expedition.</p>
        <ul id="rollovers">
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'cicada-rollover.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'moth-rollover.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'scott-sisters-rollover.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'leafhopper-rollover-coming-soon.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'anic-cicada-rollover-coming-soon.png')}"/></li>
        </ul>
        <div id="description-panes">
            <div>
                <img src="${resource(dir:'images/vp',file:'am-cicadas.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="6306" class="projectLink">Cicada Expedition</g:link>
                <h3>Australian Museum</h3>
                <p>The original and best expedition! Places are limited and the competition is hot. Over 2000 <a href="http://insects.about.com/od/butterfliesmoths/p/sphingidae.htm" target="_blank">cicadas</a>
                to be tracked and transcribed. Can you become the expedition leader?</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'moffs-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="52670" class="projectLink">Moths Expedition</g:link>
                <h3>Australian Museum</h3>
                <p><a href="http://insects.about.com/od/butterfliesmoths/p/sphingidae.htm" target="_blank">Hawk
                moths</a> fly very fast and strong, with rapid wingbeats, and can hover in flight to sip nectar.
                Don’t let their beauty fool you though, the caterpillar stage of their life cycles can do significant
                damage to agricultural crops. Your task is to transcribe the labels so we know who collected them,
                when and where .</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'scott-sisters-logo.jpg')}" class="active""/>
                <g:link controller="project" action="index" id="42780" class="projectLink">Scott Sisters Expedition</g:link>
                <h3>Australian Museum</h3>
                <p>Who were the <a href="http://australianmuseum.net.au/Beauty-from-Nature-art-of-the-Scott-Sisters/" target="_blank">Scott
                Sisters</a>  you ask? Pioneers, artists, collectors, the hottest entomologists of the
                1900 century? – all of these and more! Transcribe their personal diaries and help us unlock the identities
                of the species they so beautifully illustrated! Share their journey; share their most intimate thoughts!</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'leaf-hoppers-logo-coming-soon.jpg')}"/>
                %{--<g:link controller="project" action="index" id="99999" class="projectLink">Leaf Hoppers Expedition</g:link>--}%
                <h2>Leaf Hoppers Expedition</h2>
                <h3>Australian Museum</h3>
                <p>Ever wondered what it's like to leap from leaf to leaf through the steamy undergrowth, and suck the
                sap out of leaves and branches? You might never know; but you can get an idea of what these little
                Tarzan’s look like, transcribe their labels s and make some scientists very happy.</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'anic-cicada-coming-soon.jpg')}"/>
                %{--<g:link controller="project" action="index" id="99999" class="projectLink">ANIC Cicada Expedition</g:link>--}%
                <h2>Cicada Expedition</h2>
                <h3>Australian National Insect Collection</h3>
                <p>For those of you who can't get enough of transcribing cicada labels, here are more, with the extra
                enticement of new species from Australia and around the world</p>
            </div>
        </div>
    </div>
    <div id="vp-footer">
        <div class="copyright">
            <p><a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons" class="left no-pipe">
                <img src="http://www.ala.org.au/wp-content/themes/ala/images/creativecommons.png" width="88" height="31" alt=""></a>
                This site is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons">Creative Commons Attribution 3.0 Australia License</a>
                <span style="padding-left: 15px;">Provider content may be covered by other <span class="asterisk-container"><a href="http://www.ala.org.au/about/terms-of-use/" title="Terms of Use">Terms of Use</a>.</span></span>
            </p>
        </div>
    </div>
    <script type="text/javascript">
        $(function() {
        	$("#rollovers").tabs("#description-panes > div", {event:'mouseover', effect: 'fade', fadeOutSpeed: 400});
        });
        $('#description-panes img.active').click(function() {
            document.location.href = $(this).next('a').attr('href');
        });
    </script>
  </body>
</html>