<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      %{--<link rel="icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>--}%
      %{--<g:javascript library="jquery-1.5.1.min"/>--}%
      <g:javascript library="jquery.tools.min"/>
      <style type="text/css">
        body {
            background: #FAF9F8 url(${resource(dir:'images/vp',file:'bkg.jpg')}) top center no-repeat !important;
            text-align: center;
            margin: 0;
        }
        div#wrapper > div#content {
            background-color: transparent !important;
        }
      </style>

  </head>
  <body>
    %{--<div id="vp-menu">--}%
        %{--<img alt="ala" src="${resource(dir:'/images/vp',file:'ala-logo.png')}"/>--}%
        %{--<ul>--}%
            %{--<li>--}%
                %{--<g:link controller="user" action="myStats" >--}%
                %{--my stats--}%
            %{--</g:link>--}%
            %{--</li>--}%
            %{--<li style="display:none;">--}%
                %{--<cl:isLoggedIn>--}%
                    %{--<g:link controller="project" action="list">Admin</g:link>--}%
                %{--</cl:isLoggedIn>--}%
            %{--</li>--}%
        %{--</ul>--}%
    %{--</div>--}%
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
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'cicada-rollover.png')}" class="active" id="6306"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'moth-rollover.png')}" class="active" id="52670"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'scott-sisters-rollover.png')}" class="active" id="42780"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'plume-moth-rollover.png')}" class="active" id="122476"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'leafhoppers-rollover.png')}" class="active" id="147659"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'froghoppers-rollover.png')}" class="active" id="147660"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'treehopper-rollover.png')}" class="active" id="147662"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'planthoppers-rollover.png')}" class="active" id="147661"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'nectar-scarab-beetles-rollover.png')}" class="active" id="147663"/></li>
            %{--<li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'anic-cicada-rollover-coming-soon.png')}"/></li>--}%
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
                <img src="${resource(dir:'images/vp',file:'scott-sisters-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="42780" class="projectLink">Scott Sisters Expedition</g:link>
                <h3>Australian Museum</h3>
                <p>Who were the <a href="http://australianmuseum.net.au/Beauty-from-Nature-art-of-the-Scott-Sisters/" target="_blank">Scott
                Sisters</a>  you ask? Pioneers, artists, collectors, the hottest entomologists of the
                1900 century? – all of these and more! Transcribe their personal diaries and help us unlock the identities
                of the species they so beautifully illustrated! Share their journey; share their most intimate thoughts!</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'plume-moffs-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="122476" class="projectLink">ANIC Plume Moths</g:link>
                <h3>Australian National Insect Collection, CSIRO</h3>
                <p>Some Australian plume moths are common and can be seen at windows by night all over the country.
                Others are rare and little known.  With your help, we can map these moths and find out how they are
                spread across different environments.</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'leaf-hoppers-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="147659" class="projectLink">Australian Museum Leafhoppers Expedition</g:link>
                <h3>Australian Museum</h3>
                <p>One of the largest families of plant-feeding insects, the <a href="http://www.inhs.uiuc.edu/~dietrich/Leafhome.html"
                target="_blank">Leafhoppers</a> are tent-shaped insects which
                resemble small cicadas. Just like their relatives the cicadas, the leafhoppers also have sound producing
                organs, however their songs are too faint to be heard by human ears. </p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'froghoppers-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="147660" class="projectLink">Australian Museum Froghoppers Expedition</g:link>
                <h3>Australian Museum</h3>
                <p><a href="http://gardening.about.com/od/insectpestid/a/Spittlebugs.htm" target="_blank">Froghoppers</a>
                are the insect world’s greatest leaper. Measuring only 6 millimetres long it can launch
                itself up to 70 centimetres into the air. The adults leap between plants in search for food and the developing
                young create a frothy mass of spit on plants to hide from predators such as ants.</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'treehoppers-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="147662" class="projectLink">Australian Museum Treehoppers Expedition</g:link>
                <h3>Australian Museum</h3>
                <p><a href="http://www.inhs.uiuc.edu/~dietrich/treehome.html" target="_blank">Treehoppers</a>
                are a diverse group of plant-feeding insects and they attract attention due to their bizarre forms and
                unusual behaviours. Some treehopper species are attended to by ants which collect the sugary secretions
                that they produce.</p>
            </div>Planthoppers
            <div>
                <img src="${resource(dir:'images/vp',file:'planthoppers-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="147661" class="projectLink">Australian Museum Planthoppers Expedition</g:link>
                <h3>Australian Museum</h3>
                <p><a href="http://www1.dpi.nsw.gov.au/keys/fulgor/fulgorid/index.html" target="_blank">Planthoppers</a>
                have been named because of their resemblance to leaves and other plants and by the way they ‘hop’ for
                quick transportation in a similar way to that of grasshoppers. However, planthoppers generally walk very
                slowly so as not to attract attention. %{-- Some of the most spectacular planthoppers are the group Lantern--}%
                %{--flies. This species was named based on an incorrect report that they produced light when they mated. </p>--}%
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'nectar-scarab-beetles-logo.jpg')}" class="active"/>
                <g:link controller="project" action="index" id="147663" class="projectLink">Australian Museum Nectar Scarab Beetles Expedition</g:link>
                <h3>Australian Museum</h3>
                <p>The <a href="http://www.ento.csiro.au/education/insects/coleoptera_families/scarabaeidae.html" target="_blank">Nectar Scarab Beetles</a>
                are small brown and black beetles also know as chafers. Both the male and the female look the same.
                Some are active during the day and feed on leaves and flowers. Others are active in both the day and
                night and are attracted to the light at night.</p>
            </div>
            %{--<div>
                <img src="${resource(dir:'images/vp',file:'anic-cicada-coming-soon.jpg')}"/>
                <h2>Cicada Expedition</h2>
                <h3>Australian National Insect Collection, CSIRO</h3>
                <p>For those of you who can't get enough of transcribing cicada labels, here are more, with the extra
                enticement of new species from Australia and around the world</p>
            </div>--}%
        </div>
    </div>
    %{--<div id="vp-footer">--}%
        %{--<div class="copyright">--}%
            %{--<p><a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons" class="left no-pipe">--}%
                %{--<img src="http://www.ala.org.au/wp-content/themes/ala/images/creativecommons.png" width="88" height="31" alt=""></a>--}%
                %{--This site is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/au/" title="External link to Creative Commons">Creative Commons Attribution 3.0 Australia License</a>--}%
                %{--<span style="padding-left: 15px;">Provider content may be covered by other <span class="asterisk-container"><a href="http://www.ala.org.au/about/terms-of-use/" title="Terms of Use">Terms of Use</a>.</span></span>--}%
            %{--</p>--}%
        %{--</div>--}%
    %{--</div>--}%
    <script type="text/javascript">
        $(function() {
        	$("#rollovers").tabs("#description-panes > div", {event:'mouseover', effect: 'fade', fadeOutSpeed: 400});
        });
        $('#description-panes img.active').click(function() {
            document.location.href = $(this).next('a').attr('href');
        });
        $('#rollovers img.active').css("cursor","pointer").click(function() {
            document.location.href = "${resource(dir:'project/index/')}" + $(this).attr('id');
        });
    </script>
  </body>
</html>