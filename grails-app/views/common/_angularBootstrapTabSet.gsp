<script id="notebookTabSet.html" type="text/ng-template">
<div>
    <div class="container">
        <ul class="nav nav-{{tabset.type || 'tabs'}}" ng-class="{'nav-stacked': vertical, 'nav-justified': justified}"
            ng-transclude></ul>
    </div>

    <div class="tab-content-bg">
        <div class="container">
            <div class="tab-content">
                <div class="tab-pane"
                     ng-repeat="tab in tabset.tabs"
                     ng-class="{active: tabset.active === tab.index}"
                     uib-tab-content-transclude="tab">
                </div>
            </div>
        </div>
    </div>
</div>
</script>