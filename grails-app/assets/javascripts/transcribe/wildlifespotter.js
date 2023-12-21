//= encoding UTF-8
//  assume jquery
//  assume underscore
//  assume bootbox
//= require mustache
//= require dotdotdot
//= require transitionend
//= require marked
//= require_self
function wildlifespotter(wsParams, imagePrefix, recordValues, placeholders) {
  jQuery(function ($) {

    var filterText;
    var categoryFilters = {};
    var $searchInput = $('#ct-search-input');

    var $filterLinks = $('.category-filter a');

    var selectedIndicies = {};

    // Default save button to disabled until a selection has been made.
    $('#btnSave').attr('disabled', 'disabled');

    // selection
    $('#ct-container').on('click', '.ws-selector', function() {
      var $this = $(this);
      var index = $this.closest('[data-item-index]').data('item-index');
      var validationtype = $this.data('validationType');
      toggleIndex(index, validationtype);
    });

    $('#ct-container').on('click', '.animalDelete', function() {
      var $this = $(this);
      var index = $this.closest('[data-item-index]').data('item-index');
      deselectIndex(index);
    });

    $('input[name=recordValues\\.0\\.noAnimalsVisible]').change(function() {
      checkCheckboxValues();
    });

    $('input[name=recordValues\\.0\\.problemWithImage]').change(function() {
      checkCheckboxValues();
    });

    function checkCheckboxValues() {
      var q1 = $('input[name=recordValues\\.0\\.noAnimalsVisible]:checked').val();
      var q2 = $('input[name=recordValues\\.0\\.problemWithImage]:checked').val();
      if (!q1 && !q2) {
        $('#btnSave').attr('disabled', 'disabled');
      } else {
        $('#btnSave').removeAttr('disabled');
      }
    }

    function toggleIndex(index, validationType = "speciesWithCount") {
      if (selectedIndicies.hasOwnProperty(index)) {
        deselectIndex(index);
      } else {
        selectIndex(index, validationType);
      }
    }

    function selectIndex(index, validationType = "speciesWithCount") {
      var count = 0;
      if (validationType === "speciesOnly") count = 1;
      selectedIndicies[index] = { count: count, notes: '', editorOpen: false, init: true};
      syncSelections();
    }

    function deselectIndex(index) {
      delete selectedIndicies[index];
      syncSelections();
    }

    function syncSelections() {
      var usKeys = _.chain(selectedIndicies).keys().filter(function(idx) {
        return selectedIndicies[idx].count >= 0;
      });
      var dataItemIndexes = usKeys.map(function(v,i,l) { return "[data-item-index='"+v+"']"});
      var wsSelectionIndicator = dataItemIndexes.map(function(v,i,l) { return v + " .ws-selected"; });
      var wsSelectorIndicator = dataItemIndexes.map(function(v,i,l) { return v + " .ws-selector"; });
      $(wsSelectionIndicator.value().join(", ")).addClass('selected');
      $(wsSelectorIndicator.value().join(", ")).attr('aria-selected', 'true');
      $('[data-item-index]:not('+ dataItemIndexes.value().join(',') + ') .ws-selected').removeClass('selected').attr('aria-selected', 'false');
      $('[data-item-index]:not('+ dataItemIndexes.value().join(',') + ') .ws-selector').attr('aria-selected', 'false');

      var length = usKeys.value().length;
      if (length == 0) {
        hideSelectionPanel();
      } else {
        showSelectionPanel();
      }
      generateFormFields();
    }

    function hideSelectionPanel() {
      var parent= $('#classification-status-no-animals-selected');
      var other = $('#classification-status-animals-selected');
      parent.show();
      other.hide();
    }
    function showSelectionPanel() {
      var parent = $('#classification-status-animals-selected');
      var other = $('#classification-status-no-animals-selected');

      var templateObj = {
        selectedAnimals: _.chain(selectedIndicies).keys().map(function (v,i) {

          // var curval = 0;
          // if (!selectedIndicies[v].init) {
          //   curval = selectedIndicies[v].count;
          // } else {
          //   selectedIndicies[v].count = 0;
          //   selectedIndicies[v].init = false;
          // }

          return {
            index: v,
            name: wsParams.animals[v].vernacularName,
            curval: selectedIndicies[v].count,
            //curval: curval,
            // options: _([1,2,3,4,5,6,7,8,9,10]).map(function(opt,i) {
            //   return {
            //     val: opt,
            //     selected: selectedIndicies[v].count == opt ? 'selected' : '',
            //     isSelected: selectedIndicies[v].count == opt ? 'true' : 'false'
            //   };
            // }),
            comment: selectedIndicies[v].comment
          };

        }).sortBy(function(o) { return o.index; }).value()
      };

      mu.replaceTemplate(parent, 'status-detail-list-template', templateObj);

      parent.show();
      other.hide();
    }

    // Comments
    $('#ct-container').on('change keyup paste input propertychange', '.editClassificationComments textarea', function() {
      var $this = $(this);
      var idx = $this.closest('[data-item-index]').data('item-index');
      var comment = $this.val();
      selectedIndicies[idx].comment = comment;
      $('[data-item-index="'+idx+'"] .classificationComments').text(comment);
      generateFormFields();
    });

    //$('#ct-container').on('change', 'select.numAnimals', function() {
    $('#ct-container').on('change', 'input.numAnimals', function() {
      var $this = $(this);
      var idx = $this.closest('[data-item-index]').data('item-index');
      var count = $this.val();
      console.log("value change: " + count);
      selectedIndicies[idx].count = parseInt(count);
      generateFormFields();
    });

    $('.input-group-btn-vertical').click(function() {
      $('#ct-container').trigger("change");
    });

    $('#ct-container').on('click', '.editCommentButton', function() {
      var $this = $(this);
      var idx = $this.closest('[data-item-index]').data('item-index');
      $('[data-item-index="'+idx+'"] .editClassificationComments').show();
      $('[data-item-index="'+idx+'"] .classificationComments').hide();
      $('[data-item-index="'+idx+'"] .saveCommentButton').show();
      $('[data-item-index="'+idx+'"] .editCommentButton').hide();
      selectedIndicies[idx].editorOpen = true;
    });

    $("#ct-container").on('keydown', '.numAnimals', function(e) {
      // Allow: backspace, delete, tab, escape, enter and .
      if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 || (e.keyCode === 65 && e.ctrlKey === true) || (e.keyCode >= 35 && e.keyCode <= 40)) {
        console.log("key " + e.keyCode + " allowed");
        return;
      }

      if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
        console.log("key " + e.keyCode + " not allowed");
        e.preventDefault();
      }
    });

    $('#ct-container').on('click', '.saveCommentButton', function() {
      var $this = $(this);
      var idx = $this.closest('[data-item-index]').data('item-index');
      $('[data-item-index="'+idx+'"] .classificationComments').show();
      $('[data-item-index="'+idx+'"] .editClassificationComments').hide();
      $('[data-item-index="'+idx+'"] .editCommentButton').show();
      $('[data-item-index="'+idx+'"] .saveCommentButton').hide();
      selectedIndicies[idx].editorOpen = false;
    });

    // animal filtration
    function filterAnimals() {
      var animals = wsParams.animals;

      var elements = $('#ct-animals-present').find('[data-item-index]');
      var parts = _.partition(elements, function(e, i) {
        var $e = $(e);
        var index = $e.data('item-index');
        var animal = animals[index];
        var matchesVernacularName = filterText ? animal.vernacularName.toLocaleLowerCase().indexOf(filterText) !== -1 : true;
        var matchesScientificName = filterText ? animal.scientificName.toLocaleLowerCase().indexOf(filterText) !== -1 : true;
        var matchesFilters = true;
        for (var cat in categoryFilters) {
          if (animal.categories[cat] !== categoryFilters[cat]) matchesFilters = false;
        }
        return (matchesScientificName || matchesVernacularName) && matchesFilters;
      });
      $(parts[0]).show(100);
      $(parts[1]).hide(100);
    }

    $filterLinks.on('click', function() {
      var $this = $(this);
      var categories = wsParams.categories;
      var catIdx = $this.data('cat-idx');
      var entryIdx = $this.data('entry-idx');
      var cat = categories[catIdx];
      var ent = cat.entries[entryIdx];

      categoryFilters[cat.name] = ent.name;
      filterAnimals();
      ensureFilterSummary();
    });

    $searchInput.on('change keyup paste input propertychange', function () {
      filterText = $searchInput.val().toLocaleLowerCase();
      filterAnimals();
    });

    function ensureFilterSummary() {
      var other = $('#ct-animals-no-filter');
      var parent = $('#ct-animals-filter');
      var categories = wsParams.categories;
      var model = { categories: [] };
      for (var i=0; i < wsParams.categories.length; ++i) {
        var cat = categories[i];
        var selected = categoryFilters[cat.name];
        if (!selected) selected = 'All';
        model.categories.push({name: cat.name, value: selected});
      }
      parent.empty();
      mu.appendTemplate(parent, 'filter-summary', model);
      other.hide();
      parent.show();
    }

    function setFilterText(text) {
      filterText = text;
      $('#ct-search-input').val(text);
    }

    // clear all filters
    $('#ct-animals-filter').on('click', 'a.clearall', function() {
      for (var cat in categoryFilters) {
        delete categoryFilters[cat];
      }
      setFilterText('');
      var other = $('#ct-animals-no-filter');
      var parent = $('#ct-animals-filter');
      other.show();
      parent.hide();
      filterAnimals();
    });

    // Show info pane

    // Show detail
    function showDetail(index) {
      var $container = $('#ws-dynamic-container');
      $container.empty();

      var animals = wsParams.animals;
      var animal = animals[index];
      var description = animal.description != null ? marked(animal.description) : "";
      var templateObj = {
        animal: {
          selected: selectedIndicies.hasOwnProperty(index) && selectedIndicies[index].count > 0 ? 'selected' : '',
          vernacularName: animal.vernacularName,
          scientificName: animal.scientificName,
          description: description,
          images: _.map(animal.images, function(v, i, l) {
            return {
              idx: i,
              hash: v.hash,
              active: i == 0 ? 'active': ''
            };
          })
        },
        itemIndex: index
      };

      var detail = mu.appendTemplate($container, 'detail-template', templateObj);
      //var carousel = $('#ct-full-image-carousel');
      var carousel = detail.find('.carousel');
      carousel.carousel({interval: false});
      detail.find('[title]').tooltip();

      switchCtPage('#ws-dynamic-container');
    }

    function hideDetail() {
      var $container = $('#ws-dynamic-container');
      $container.empty();
      switchCtPage('#ct-animals-present');
    }

    $('#ct-container').on('click', '.ws-info', function(e) {
      e.stopPropagation();
      var $this = $(this);
      var idxElem = $this.closest('[data-item-index]');
      var idx = idxElem.data('item-index');
      showDetail(idx);
    });

    $('#ct-container').on('click', '.ws-full-image-carousel-close', function(e) {
      e.stopPropagation();
      var $this = $(this);
      hideDetail();
    });


    var $ctq = $('#camera-trap-questions');
    var transitionendname = transitionEnd($ctq).whichTransitionEnd();

    function switchCtPage(to) {
      var $ctq = $('#camera-trap-questions');
      // kill any existing transition
      $ctq.find('.ct-item.fading').removeClass('fading');
      var otherActives = $ctq.find('.ct-item.active')
        .not(to);
      otherActives.removeClass('active');
      if (transitionendname) otherActives.addClass('fading');
      $(to).addClass('active');

      // var $ctqn = $('#ct-questions-nav');
      // $ctqn.find('button.active').removeClass('active');
      // $ctqn.find('button[data-target="'+to+'"]').addClass('active');

      var summary = to == '#ct-animals-summary';
      $('#btnNext').toggleClass('hidden', summary);
    //  $('.bvp-submit-button').toggleClass('hidden', !summary);
    }

    // Cycling Thumbnails
    function cycleImages() {
      $('#ct-animals-list .cycler').filter(function(i) { return $("img", this).length > 1 }).each(function (e) {
        var $this = $(this);
        var $active = $this.find('.active');
        var nextImage = $active.next('img');
        var $next = (nextImage.length > 0) ? nextImage : $this.find('img:first');
        $active.removeClass('active');
        $next.addClass('active');
      });
    }

    setInterval(cycleImages, 7000);

    // Sync save
    function syncSelectionState() {
      generateFormFields();
    }

    function generateFormFields() {
      var $ctFields = $('#ct-fields');
      $ctFields.empty();
      var enableSubmit = true;
      if (_.keys(selectedIndicies).length > 0) {
        $('input[name=recordValues\\.0\\.noAnimalsVisible]').removeAttr('checked');
        $('input[name=recordValues\\.0\\.problemWithImage]').removeAttr('checked');
        if (recordValues && recordValues[0]) {
            delete recordValues[0].noAnimalsVisible;
            delete recordValues[0].problemWithImage;
        }
        _.each(selectedIndicies, function(value, key, list) {
          if (value.count === 0) enableSubmit = false;
        });
      } else {
        if (recordValues && recordValues[0]) {
            delete recordValues[0].vernacularName;
            delete recordValues[0].scientificName;
            delete recordValues[0].individualCount;
        }

        var q1 = $('input[name=recordValues\\.0\\.noAnimalsVisible]:checked').val();
        var q2 = $('input[name=recordValues\\.0\\.problemWithImage]:checked').val();
        if (!q1 && !q2) enableSubmit = false;
      }
      var i = 0;
      _.each(selectedIndicies, function (value, key, list) {
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.vernacularName', value: wsParams.animals[key].vernacularName});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.scientificName', value: wsParams.animals[key].scientificName});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.individualCount', value: value.count});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.comment', value: value.comment});
        ++i;
      });
      console.log("Enable submit button? " + enableSubmit);
      if (enableSubmit) $('#btnSave').removeAttr('disabled');
      else $('#btnSave').attr('disabled', 'disabled');
    }

    function syncRecordValues() {
      var animals = wsParams.animals;
      _.chain(recordValues).keys().sort().each(function(e, i, l) {

        var key = parseInt(e);
        if (isNaN(key)) {
          return;
        }

        var v = recordValues[e];

        var index = _.findIndex(animals, function(a) {
          return a.vernacularName === v.vernacularName || a.scientificName === v.scientificName;
        });

        if (index >= 0) {
          selectedIndicies[index] = {
            comment: v.comment,
            count: v.individualCount,
            editorOpen: false
          };
        }
      });
    }



    transcribeValidation.addCustomValidator(function(errorList) {
      var q1 = $('input[name=recordValues\\.0\\.noAnimalsVisible]:checked').val();
      var q2 = $('input[name=recordValues\\.0\\.problemWithImage]:checked').val();
      var q3 = _.keys(selectedIndicies).length > 0;
      if (!q1 && !q2 && !q3) {

        errorList.push({element: null, message: "You must either indicate that there are no animals, there's a problem with the image or select at least one animal before you can submit", type: "Error" });
      }
    });
    transcribeValidation.setErrorRenderFunctions(function (errorList) {
      },
      function() {
      });

    submitRequiresConfirmation = true;
    postValidationFunction = function(validationResults) {
      if (validationResults.errorList.length > 0) bootbox.alert("<h3>Invalid selection</h3><ul><li>" + _.pluck(validationResults.errorList, 'message').join('</li><li>') + "</li>");
    };

    transcribeWidgets.addBeforeSubmitHook(function (e) {
      generateFormFields();
      // $unlisted.find('input.speciesName').each(function() {
      //   var $this = $(this);
      //   if (!$this.val()) $this.remove();
      // });
      return true;
    });

    // IMAGE SEQUENCE
    var $imgViewer = $("#image-container img");
    var $imgSeq = $('#ct-image-sequence');
    var $defaultImg = $imgSeq.find('.default');
    var $clicked = $defaultImg;

    function loadImage($src) {
      $imgSeq.find('.active').removeClass('active');
      $imgViewer.prop('src', $src.find('img').data('full-src'));
      $imgViewer.panZoom('loadImage');
      $src.addClass('active');
    }

    $imgSeq.on('click', '.film-cell', function(e) {
      var $this = $(this);
      if (!$clicked.is($this)) {
        $clicked = $this;
        loadImage($this);
      } else {
        $clicked = $defaultImg;
        loadImage($defaultImg);
      }
    });

    $imgSeq.on('mouseover', '.film-cell', function(e) {
      var $this = $(this);
      loadImage($this);
    });

    $imgSeq.on('mouseout', '.film-cell', function(e) {
      var $this = $(this);
      loadImage($clicked);
    });

    $('#ct-question-span').click(function(e) {
      $clicked = $defaultImg;
      loadImage($defaultImg);
    });

    // force intial sync of saved values
    syncRecordValues();
    syncSelections();

    // enable tooltips
    $('[title]').tooltip();

  });

}

if (!String.prototype.trim) {
  (function() {
    // Make sure we trim BOM and NBSP
    var rtrim = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
    String.prototype.trim = function() {
      return this.replace(rtrim, '');
    };
  })();
}