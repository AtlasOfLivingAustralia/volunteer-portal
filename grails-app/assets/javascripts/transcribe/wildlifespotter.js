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

    // selection
    $('#ct-container').on('click', '.ws-selector', function() {
      var $this = $(this);
      var index = $this.closest('[data-item-index]').data('item-index');
      toggleIndex(index);
    });

    $('#ct-container').on('click', '.animalDelete', function() {
      var $this = $(this);
      var index = $this.closest('[data-item-index]').data('item-index');
      deselectIndex(index);
    });

    function toggleIndex(index) {
      if (selectedIndicies.hasOwnProperty(index)) {
        deselectIndex(index);
      } else {
        selectIndex(index);
      }
    }

    function selectIndex(index) {
      selectedIndicies[index] = { count: 1, notes: '', editorOpen: false};
      syncSelections();
    }

    function deselectIndex(index) {
      delete selectedIndicies[index];
      syncSelections();
    }

    function syncSelections() {
      var usKeys = _.chain(selectedIndicies).keys().filter(function(idx) { return selectedIndicies[idx].count > 0; });
      var dataItemIndexes = usKeys.map(function(v,i,l) { return "[data-item-index='"+v+"']"});
      var wsSelectionIndicator = dataItemIndexes.map(function(v,i,l) { return v + " .ws-selected"; });
      $(wsSelectionIndicator.value().join(", ")).addClass('selected');
      $('[data-item-index]:not('+ dataItemIndexes.value().join(',') + ') .ws-selected').removeClass('selected');
      var length = usKeys.value().length;
      if (length == 0) {
        hideSelectionPanel();
      } else {
        showSelectionPanel();
      }
      generateFormFields();
      // for (index in selectedIndicies) {
      //   if (selectedIndicies[index]) {
      //     $('[data-item-index="'+index+'"] .ws-selection-indicator').addClass('selected');
      //   }
      // }
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

          return {
            index: v,
            name: wsParams.animals[v].vernacularName,
            options: _([1,2,3,4,5,6,7,8,9,10]).map(function(opt,i) {
              return {
                val: opt,
                selected: selectedIndicies[v].count == opt ? 'selected' : ''
              };
            }),
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

    $('#ct-container').on('change', 'select.numAnimals', function() {
      var $this = $(this);
      var idx = $this.closest('[data-item-index]').data('item-index');
      var count = $this.val();
      selectedIndicies[idx].count = parseInt(count);
      generateFormFields();
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
      var templateObj = {
        animal: {
          selected: selectedIndicies.hasOwnProperty(index) && selectedIndicies[index].count > 0 ? 'selected' : '',
          vernacularName: animal.vernacularName,
          scientificName: animal.scientificName,
          description: marked(animal.description),
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

    $('#ct-container').on('click', '.ct-full-image-carousel-close', function(e) {
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
      $('.bvp-submit-button').toggleClass('hidden', !summary);
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
      var i = 0;
      _.each(selectedIndicies, function (value, key, list) {
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.vernacularName', value: wsParams.animals[key].vernacularName});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.scientificName', value: wsParams.animals[key].scientificName});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.individualCount', value: value.count});
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.comment', value: value.comment});
        ++i;
      });
    }

    function syncRecordValues() {
      var animals = wsParams.animals;
      _.chain(recordValues).each(function(v,k,l) {
        var index = _.findIndex(animals, function(a) {
          return a.vernacularName === v.vernacularName || a.scientificName === v.scientificName;
        });

        if (index) {
          selectedIndicies[index] = {
            comment: v.comment,
            count: v.individualCount,
            editorOpen: false
          };
        }
      });
    }

    transcribeWidgets.addBeforeSubmitHook(function (e) {
      generateFormFields();
      // $unlisted.find('input.speciesName').each(function() {
      //   var $this = $(this);
      //   if (!$this.val()) $this.remove();
      // });
      return true;
    });

    // // restore filter
    // var lastFilter = amplify.store('bvp_ct_last_filter');
    // if (lastFilter) $('#'+lastFilter).click();

    // force intial sync of saved values
    syncRecordValues();
    syncSelectionState();
    // syncUnlistedTray();

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