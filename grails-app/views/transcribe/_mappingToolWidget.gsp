<div class="row" style="padding-bottom: 10px">
    <div class="col-md-10">
        If the Latitude/Longitude do not appear on the label, find them using the mapping tool below
    </div>
</div>

<div class="row ${cssClass}" style="padding-bottom: 10px">
    <div class="col-md-4">
        <strong>${field.label ?: 'Find Lat/Long'}</strong>
    </div>

    <div class="col-md-8">
        <div class="row">
            <div class="col-md-10">
                <button type="button" class="btn btn-info pull-right" id="btnGeolocate">Mapping tool <i class="fa fa-map-pin"></i></button>
            </div>

            <div class="col-md-2">
                <g:fieldHelp field="${field}"/>
            </div>
        </div>
    </div>
</div>
