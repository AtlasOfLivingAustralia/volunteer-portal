<div class="row" style="padding-bottom: 10px">
    <div class="col-md-10">
        <g:message code="transcribe.mappingTool.find_them_using_the_mapping_tool"/>
    </div>
</div>

<div class="row ${cssClass}" style="padding-bottom: 10px">
    <div class="col-md-4">
        <strong>${field.label ?: message(code: 'transcribe.mappingTool.find_lat_long')}</strong>
    </div>

    <div class="col-md-8">
        <div class="row">
            <div class="col-md-10">
                <button type="button" class="btn btn-info pull-right" id="btnGeolocate"><g:message code="transcribe.mappingTool.mapping_tool"/> <i class="fa fa-map-pin"></i></button>
            </div>

            <div class="col-md-2">
                <g:fieldHelp field="${field}"/>
            </div>
        </div>
    </div>
</div>
