<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Sample VP home page</title>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <g:javascript library="jquery-1.5.1.min"/>
      <g:javascript library="jquery.tools.min"/>
  </head>
  <body>
    <div id="vp-menu">
        <img alt="ala" src="${resource(dir:'/images/vp',file:'ala-logo.png')}"/>
        <ul>
            <li><a href="#">my stats</a></li>
            <li><a href="http://volunteer.ala.org.au/task/projectAdmin/6306">admin</a></li>
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
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'scott-sisters-rollover.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'cicada-rollover.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'leafhopper-rollover-coming-soon.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'moth-rollover-coming-soon.png')}"/></li>
            <li class="rollover-tab"><img src="${resource(dir:'images/vp',file:'anic-cicada-rollover-coming-soon.png')}"/></li>
        </ul>
        <div id="description-panes">
            <div>
                <img src="${resource(dir:'images/vp',file:'am-scott-sisters.jpg')}"/>
                <a href="http://volunteer.ala.org.au/project/index/42780">Scott Sisters Expedition</a>
                <h3>Australian Museum</h3>
                <p>Want to read the personal diaries of two of Australia's hottest collectors and illustrators?
                You get to transcribe never before seen pages of their field notes. Share their journey;
                share their most intimate thoughts!</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'am-cicadas.jpg')}"/>
                <a href="http://volunteer.ala.org.au/project/index/6306">Cicada Expedition</a>
                <h3>Australian Museum</h3>
                <p>The original and best expedition! Places are limited and the competition is hot.
                Over 2000 cicadas to be tracked and transcribed. Sign up while you still can!</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'leaf-hoppers-logo-coming-soon.jpg')}"/>
                <a href="#">Leaf Hoppers Expedition</a>
                <h3>Australian Museum</h3>
                <p>Ever wondered what it's like to leap from leaf to leaf through the steamy undergrowth?
                You might never know; but you can help to label these Tarzan-like specimens and make some
                scientists very happy.</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'moffs-logo-coming-soon.jpg')}"/>
                <a href="#">Moths Expedition</a>
                <h3>Australian Museum</h3>
                <p>Drawers A246 - A252 hold specimens of Australian moths collected between 1890 and 1998.
                Your task is to transcribe the labels so we know who collected them, when and where.</p>
            </div>
            <div>
                <img src="${resource(dir:'images/vp',file:'anic-cicada-coming-soon.jpg')}"/>
                <a href="#">Cicada Expedition</a>
                <h3>Australian National Insect Collection</h3>
                <p>Sick of doing all the drudge work the for AM? How about refreshing yourself with some
                drudge work for ANIC instead. If you do well we might let you have a go at the butterflies!</p>
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
        $('#description-panes img').click(function() {
            document.location.href = $(this).next('a').attr('href');
        });
    </script>
  </body>
</html>