
function digivolStageFiles (config, self) {

     var batchSize = 200;

     self.submitStagingFiles = function (projectId, files) {

       // var batchSize = 200;

        if (files.length > 0) {
            $("#uploadProgress").css("display", "block");
        }

        for (index = 0; index < files.length; index += batchSize) {
            var fileBatch = files.slice(index, index + batchSize);

            var formData = appendFormDataInBatches(projectId, fileBatch);
            //console.log(formData);
            sendFile(projectId, formData, files.length);
        }

    }

    self.setupListeners = function() {
        $(".btnDeleteImage").click(function(e) {
            var imageName = $(this).attr("imageName");
            if (imageName) {
                window.location = config.unStageImageUrl + imageName;
            }
        });
        $("#btnClearStagingArea").click(function(e) {
            e.preventDefault();
            bootbox.confirm('Are you sure you wish to delete all images from the staging area?', function(result) {
                if (result) {
                    window.location = config.clearStagingUrl;
                }
            });
        });
        $("#btnExportTasksCSV").click(function(e) {
            e.preventDefault();
            window.open(config.exportCSVUrl, "ExportCSV");
        });
        $(".btnEditField").click(function(e) {
            e.preventDefault();
            var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
            if (fieldId) {
                var options = {
                    title: "Edit field definition",
                    url: config.editFieldUrl + fieldId
                };
                bvp.showModal(options);
            }
        });
        $(".btnDeleteField").click(function(e) {
            var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
            if (fieldId) {
                window.location = config.deleteFieldUrl + fieldId;
            }
        });
    }

    function updateProgress(processed, totalToBeUploaded, totalFiles) {

       /* var stagedFiles = parseInt($('#totalUploaded').val()) + processed;
        //  var totalImages = parseInt($('#totalImages').text());
        //  var totalStaged = stagedFiles + totalImages;
      //  $('#totalImagesDisplay').text($('#totalImages').val());
        $('#totalUploaded').val(stagedFiles);*/
//    debugger;

        var percentComplete = processed / totalToBeUploaded;

        var percentCompleteText = Math.round(percentComplete * 100) + '%';

        if (totalFiles == totalToBeUploaded) {
            $('#uploadedProgressText').text("Files are being staged in batches. (" + processed + ' out of ' + totalFiles + ' successfully staged)');
        } else {
            $('#uploadedProgressText').text(percentCompleteText + ' successfully staged');
        }

        $('#uploadedProgressPercentage').text(percentCompleteText);
            console.log(percentCompleteText);
        $('.progress-bar').css({
            width: percentCompleteText //percentComplete * 100 + '%'

        });
        if (percentComplete === 1) {
            $('#uploadedProgressText').text(totalFiles + ' successfully staged');
            $('.progress').addClass('hide');
        }
    }

    function appendFormDataInBatches(projectId, filesBatch) {
        var formData = new FormData();

        formData.append('projectId', projectId);

        filesBatch.forEach(function (file) {
            formData.append('imageFile', file)
        });

        return formData;
    }

    function sendFile(projectId, files, totalFiles) {
       // console.log('Sending files: ');
        $.ajax({
            type: 'POST',
            url: "stageImage",
            data: files,
            cache: false,
            contentType: false,
            processData: false,
            xhr: function () {
                     var myXhr = $.ajaxSettings.xhr();
                     if (totalFiles <= batchSize) {
                         if (myXhr.upload) {
                             console.log('addEventListener');
                             myXhr.upload.addEventListener('progress', function(evt){
                                 if (evt.lengthComputable) {
                                     updateProgress(evt.loaded, evt.total, totalFiles)
                                     //var percentComplete = evt.loaded / evt.total;
                                     //Do something with download progress
                                    // console.log(percentComplete);
                                 }
                             }, false);
                         }
                     }
                     return myXhr;
                 },
            success: function (data) {
                console.log(data);
                var processed = data.processed;
                if (totalFiles > batchSize) {
                    var stagedFiles = parseInt($('#totalUploaded').val()) + processed;
                    //  var totalImages = parseInt($('#totalImages').text());
                    //  var totalStaged = stagedFiles + totalImages;
                    //  $('#totalImagesDisplay').text($('#totalImages').val());
                    $('#totalUploaded').val(stagedFiles);
                    updateProgress(stagedFiles, totalFiles, totalFiles);
                }
                $('#stagedImages').load("/task/stagedImages", {projectId: projectId}, function () {
                    self.setupListeners ();
                });
            },
            error: function (data) {
                console.log(data);
            }
        });
    }
}