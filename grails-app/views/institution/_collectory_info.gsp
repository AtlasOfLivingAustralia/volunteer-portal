<r:style type="text/css">
    dt, dd { display: inline; margin: 0; }

    dt:after {
        content: ':';
    }
    dd:after {
        content: '\A';
        white-space: pre;
    }

    @media (max-width: 767px) {
        #pop-col-val {
            margin-top: 10px;
            margin-bottom: 10px;
        }
        .icon-arrow-populate {
            background-position: -289px -96px;
        }
    }
    @media (min-width: 768px) {
        #pop-col-val {
            margin-top: 7em;
        }
        .icon-arrow-populate {
            background-position: -240px -96px;
        }
    }
</r:style>
<dl>
    <dt>Name</dt>
    <dd id="collec-dt-name" class="collec-dt"></dd>
    <dt>Description</dt>
    <dd id="collec-dt-desc" class="collec-dt"></dd>
    <dt>Contact Email</dt>
    <dd id="collec-dt-email" class="collec-dt"></dd>
    <dt>Contact Phone</dt>
    <dd id="collec-dt-phone" class="collec-dt"></dd>
</dl>
<r:script>
    jQuery(function($) {
        var apiPrefix = "${createLink(controller: 'ajax', action: 'collectoryObjectDetails')}";
        var model = {};
        var loads = 0;
        (function() {
            var initCid = $('#collectoryUid').val();

            if (initCid) {
                getData(initCid, function(data) {
                    model = data;
                    setValues();
                });
            }
        })();
        $('#collectoryUid').change(function(e) {
            var cid = $( this ).val();
            if (!cid) {
                $( this ).val('');
                clearValues();
                return;
            }

            getData(cid, updateModel).fail(clearValues);
        });
        $('#pop-col-val').click(function(e) {
            setName();
            setDesc();
            setEmail();
            setPhone();
        });
        function getData(id, success) {

            if (++loads == 1) {
                $('#pop-col-val').button('loading');
            }
            var retVal = $.getJSON(apiPrefix+"/"+id, success);
            retVal.complete(function() {
                if (--loads == 0) {
                    $('#pop-col-val').button('reset');
                }
            });
            return retVal;
        }
        function updateModel(data) {
            var oldModel = model;
            model = data;
            setValues();
            condUpdate('name', modelVal(oldModel, 'name'), setName);
            condUpdate('description', modelVal(oldModel, 'pubDescription'), setDesc);
            condUpdate('contactEmail', modelVal(oldModel, 'email'), setEmail);
            condUpdate('contactPhone', modelVal(oldModel, 'phone'), setPhone);
        }
        function modelVal(model, param) { return model[param] || '' };
        function setValues() {

            $('#collec-dt-name').text(modelVal(model, 'name'));
            $('#collec-dt-desc').text(modelVal(model, 'pubDescription'));
            $('#collec-dt-email').text(modelVal(model, 'email'));
            $('#collec-dt-phone').text(modelVal(model, 'phone'));
            // prettyify line breaks;
            $('dd.collec-dt').html(function() { return replaceAll(replaceAll($(this).html(), '\r', ''), '\n', '<br/>');})

        };
        function clearValues() {
            updateModel({});
        };
        function condUpdate(name, oldVal, setFunc) {
            var val = $('#'+name).val();
            if (val === oldVal || normalize(val) == normalize(oldVal)) {
                setFunc();
            }
        };
        function normalize(str) { return replaceAll(str.trim(), '\r', ''); };
        function replaceAll(str, from, to) { return str.split(from).join(to); }
        function setName() { $('#name').val(modelVal(model, 'name')); };
        function setDesc() { $('#description').text(modelVal(model, 'pubDescription')); };
        function setEmail() { $('#contactEmail').val(modelVal(model, 'email')); };
        function setPhone() { $('#contactPhone').val(modelVal(model, 'phone')); };
    });
</r:script>