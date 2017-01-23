<script type="application/javascript">
    var BVP_JS_URLS = {
                selectProjectFragment: "${createLink(controller: 'project', action: 'findProjectFragment')}",
                slickgridCalendarImagePath: "${asset.assetPath(src: 'slickgrid/images/calendar.gif')}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}",
                unreadValidatedCount: "${createLink(controller:'user', action: 'unreadValidatedTasks')}",
                markersPath: "${resource(dir: 'markers')}/",
                singleMarkerPath: "${asset.assetPath(src: 'mapMarker.png')}"
            };
</script>
