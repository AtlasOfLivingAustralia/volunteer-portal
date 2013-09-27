<div class="row-fluid" style="margin-bottom: 10px">
    <div class="span10">
        If the Lat/Long do not appear on the label, find them using the mapping tool below
    </div>
</div>
<div class="row-fluid ${cssClass}" style="margin-bottom: 10px">
    <div class="span4">
        <strong>${field.label ?: 'Find Lat/Long'}</strong>
    </div>
    <div class="span8">
        <div class="span10">
            <button class="btn btn-info pull-right" id="btnGeolocate">Use mapping tool</button>
        </div>
        <div class="span2">
            <g:fieldHelp field="${field}" />
        </div>
    </div>
</div>
