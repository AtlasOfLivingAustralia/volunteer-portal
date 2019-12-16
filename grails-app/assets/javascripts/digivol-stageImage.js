//= require compile/resumable/1.1.2/resumable.js
//= require compile/spark-md5/3.0.0/spark-md5.js
//= require mustache
//= require bootbox
//= require_self

function digivolStageFiles (config, self) {

    self.setupListeners = function () {
        $(".btnDeleteImage").click(function (e) {
            var imageName = $(this).attr("imageName");
            if (imageName) {
                window.location = config.unStageImageUrl + imageName;
            }
        });
        $(".btnStageAddFieldDefinition").click(function (e) {
            e.preventDefault();
            var options = {
                title: "Add field definition",
                url: config.addFieldUrl
            };
            bvp.showModal(options);
        });
        $("#btnClearStagingArea").click(function (e) {
            e.preventDefault();
            bootbox.confirm('Are you sure you wish to delete all images from the staging area?', function (result) {
                if (result) {
                    window.location = config.clearStagingUrl;
                }
            });
        });
        $("#btnExportTasksCSV").click(function (e) {
            e.preventDefault();
            window.open(config.exportCSVUrl, "ExportCSV");
        });
        $(".btnEditField").click(function (e) {
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
        $(".btnDeleteField").click(function (e) {
            var fieldId = $(this).parents("[fieldDefinitionId]").attr("fieldDefinitionId");
            if (fieldId) {
                window.location = config.deleteFieldUrl + fieldId;
            }
        });
        $(".btnDeleteShadowFile").click(function (e) {
            var filename = $(this).attr("filename");
            if (filename) {
                window.location = config.unStageImageUrl + filename;
            }
        });
    };

    self.setupListeners();

    function enableControls(enable) {
        var disable = !enable;
        $('#btnLoadTasks').prop('disabled', disable);
        $('.btnAddFieldDefinition').prop('disabled', disable);
        $('#btnUploadDataFile').prop('disabled', disable);
        $('#btnClearDataFile').prop('disabled', disable);
        $('.dropdown-toggle').prop('disabled', disable).toggleClass('disabled', disable);
        $('.btnEditField').prop('disabled', disable);
        $('.btnDeleteField').prop('disabled', disable);
        $('.btnDeleteImage').prop('disabled', disable);
        $('.btnDeleteShadowFile').prop('disabled', disable);
    }

    var query = function (resumableFile, resumableChunk) {
        return {
            'checksum': resumableFile.hashes[resumableChunk.offset],
            'completeChecksum': resumableFile.fullHash
        };
    };

    $('#upload-progress').on('click', '#pause-upload', function () {
        paused = !paused;
        if (paused) {
            r.pause();
        } else {
            r.upload();
        }
    }).on('click', '#cancel-upload', function () {
        r.cancel();
    });


    var errors = [];
    var complete = 0;
    var paused = false;

    function renderProgress() {
        var files = r.files;
        var current = [];
        var total = files.length;
        var progress = r.progress();
        var uploading = complete !== total;

        mu.updateTemplate(document.getElementById('upload-progress'), 'upload-progress-tmpl', {
            currentFiles: current,
            paused: paused,
            complete: complete,
            total: total,
            progress: progress * 100,
            errors: errors.length,
            remaining: total - complete - errors.length,
            uploading: uploading
        });
    }

    function updateStagedImageDisplay() {
        $('#stagedImages').load(config.stagedImagesUrl, {}, function () {
            self.setupListeners();
        });
    }

    function finishUpload() {
        $('#upload-progress').empty();
        complete = 0;
        enableControls(true);
        updateStagedImageDisplay();
    }

    var r = new Resumable({
        target: config.uploadFileUrl,
        query: query,
        chunkRetryInterval: 1000,
        withCredentials: true,
        xhrTimeout: 30000,
        fileType: ['image/jpeg', 'image/png', 'image/gif', 'text/plain'],
        fileTypeErrorCallback: function (file, errorCount) {
            console.log("fileTypeErrorCallback", file, errorCount);
        },
        preprocessFile: function (file) {
            // console.log('preprocessFile', file);
            computeHashes(file);
        }
        // chunkSize: 256 * 1024
    });

    if (!r.support) {
        bootbox.alert("Uploading from this browser is not supported.  Please use a modern browser to upload files.")
    }

    r.assignBrowse(document.getElementById('btnSelectImages'));
    // r.assignDrop(document.getElementById('stagingDropArea'));
    r.on('fileAdded', function (file, event) {
    });
    r.on('filesAdded', function (files, filesSkipped) {
        if (!r.isUploading()) {
            r.upload();
            enableControls(false);
        }
        renderProgress();
    });
    r.on('fileRetry', function (file) {
        console.log("file retry", arguments);
    });
    r.on('fileError', function (file, message) {
        // console.log("file error", arguments);
        errors.push(file);
        bootbox.alert("There was an error uploading " + file.fileName + ".  Please try uploading it again and if the error persists please contact DigiVol support.");
    });
    r.on('complete', function () {
        // remove uploads
        r.files.splice(0, r.files.length);
        finishUpload();
    });
    r.on('progress', function () {
        // console.log("progress", arguments);
        renderProgress();
    });
    r.on('fileSuccess', function (file, message) {
        // console.log("fileSuccess", arguments);
        complete++;
        renderProgress();
        // updateStagedImageDisplay();
    });
    r.on('fileProgress', function (file, message) {
        // console.log("fileProgress", arguments);
        renderProgress();
    });
    r.on('error', function (message, file) {
        console.log("error", arguments);
        bootbox.alert("An error has occurred.  Please try uploading again and if the error persists please contact DigiVol support.");
    });
    r.on('pause', function () {
        // console.log("pause", arguments);
    });
    r.on('beforeCancel', function() {
       // r.files.forEach(function(value, index, array) {
       //     value.progress();
       // });
    });
    r.on('cancel', function() {
        finishUpload();
    });


    var computeHashes = function (resumableFile, offset, fileReader) {
        var round = resumableFile.resumableObj.getOpt('forceChunkSize') ? Math.ceil : Math.floor,
            chunkSize = resumableFile.getOpt('chunkSize'),
            numChunks = Math.max(round(resumableFile.file.size / chunkSize), 1),
            forceChunkSize = resumableFile.getOpt('forceChunkSize'),
            startByte,
            endByte,
            func = (resumableFile.file.slice ? 'slice' : (resumableFile.file.mozSlice ? 'mozSlice' : (resumableFile.file.webkitSlice ? 'webkitSlice' : 'slice'))),
            bytes;

        resumableFile.hashes = resumableFile.hashes || [];
        fileReader = fileReader || new FileReader();
        offset = offset || 0;

        // if (resumableFile.resumableObj.cancelled === false) {
            startByte = offset * chunkSize;
            endByte = Math.min(resumableFile.file.size, (offset + 1) * chunkSize);

            if (resumableFile.file.size - endByte < chunkSize && !forceChunkSize) {
                endByte = resumableFile.file.size;
            }
            bytes  = resumableFile.file[func](startByte, endByte);

            resumableFile.sparkBuff = resumableFile.sparkBuff || new SparkMD5.ArrayBuffer();

            fileReader.onload = function (e) {
                resumableFile.sparkBuff.append(e.target.result);
                var spark = SparkMD5.ArrayBuffer.hash(e.target.result, false);
                resumableFile.hashes.push(spark);

                if (numChunks > offset + 1) {
                    computeHashes(resumableFile, offset + 1, fileReader);
                } else {
                    resumableFile.fullHash = resumableFile.sparkBuff.end(false);
                    resumableFile.sparkBuff.destroy();
                    delete resumableFile.sparkBuff;
                    resumableFile.preprocessFinished();
                }
            };

            fileReader.readAsArrayBuffer(bytes);
        // }
    };

}