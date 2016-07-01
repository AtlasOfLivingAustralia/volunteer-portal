<script type="application/javascript">
    var BVP_JS_URLS = {
                selectProjectFragment: "${createLink(controller: 'project', action: 'findProjectFragment')}",
                webappRoot: "${resource(dir: '/')}",
                picklistAutocompleteUrl: "${createLink(action: 'autocomplete', controller: 'picklistItem')}",
                unreadValidatedCount: "${createLink(controller:'user', action: 'unreadValidatedTasks')}",
                markersPath: "${resource(dir: 'markers')}/",
                singleMarkerPath: "${asset.assetPath(src: 'mapMarker.png')}"
            };
</script>