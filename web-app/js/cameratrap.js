function cameratrap(smImageInfos, smItems, recordValues, placeholders) {
  jQuery(function ($) {
    var values = _.pluck([].concat(_.values(smItems)), 'value');

    var itemValueMap = smItems;

    var unlisted = [];

    var selections = {};

    // setup initial selection state from recordValues
    for (var index in recordValues) {
      if (recordValues.hasOwnProperty(index)) {
        var vn = recordValues[index].vernacularName;
        var certainty = recordValues[index].certainty || 1;
        if (vn && itemValueMap[vn]) {
          selections[vn] = {certainty: certainty, key: itemValueMap[vn].imageIds}
        }
      }
    }

    $('#ct-questions-nav').find('[data-toggle="nav"]').click(function(e) {
      e.preventDefault();
      var $this = $(this);
      switchCtPage($this.attr('data-target'));
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

      var $ctqn = $('#ct-questions-nav');
      $ctqn.find('button.active').removeClass('active');
      $ctqn.find('button[data-target="'+to+'"]').addClass('active');

      var summary = to == '#ct-animals-summary';
      $('#btnNext').toggleClass('hidden', summary);
      $('.bvp-submit-button').toggleClass('hidden', !summary);
    }

    $('#btnNext').click(function(e) {
      var $ctqn = $('#ct-questions-nav');
      var nextPage = $ctqn.find('button.active').next().attr('data-target') || '#ct-animals-present';
      switchCtPage(nextPage);
    });

    var yes = $('#btn-animals-present').attr('value');
    $('#ct-animals-question input').change(function(e) {
      var $this = $(this);
      var answer = $this.val();
      var $btnSave = $('#btnSave');
      if (answer != yes && $btnSave) {
        // check if we're don't confirm and confirm
        var dontConfirm = amplify.store("bvp_transcribe_dontconfirm");
        if (dontConfirm) {
          bootbox.confirm('Do you wish to record "' + answer + '" as your answer?', function(confirm) {
            if (confirm) {
              $btnSave.click();
            }
          });
        } else {
          $btnSave.click();
        }
      } else {
        switchCtPage('#ct-animals-present');
      }
    });

    // switch back to regular camera trap transcribing when clicking any button:
    var $ctToolbarBtns = $('#ct-animals-btn-group, #ct-sort-btn-group').find('.btn');

    function switchCtSubPage(isOther) {
      var to = isOther ? '#ct-unlisted' : '#ct-animals-list';

      var $sic = $('.ct-sub-item-container');
      $sic.find('.ct-sub-item.fading').removeClass('fading');
      var otherActives = $sic.find('.ct-sub-item.active')
        .not(to);
      otherActives.removeClass('active');
      if (transitionendname) otherActives.addClass('fading');
      $(to).addClass('active');

    }

    $ctToolbarBtns.click(function(e) {
      switchCtSubPage(false);
      $('#ct-other-btn').toggleClass('active', false);
    });

    $('#ct-other-btn').click(function(e) {
      switchCtSubPage(!$(this).hasClass('active'));
    });

    if (transitionendname) {
      $ctq.on(transitionendname, '.ct-item', function (e) {
        // only handle the ct-item transition
        if ($(e.target).hasClass('ct-item')) {
          $(e.target).removeClass('fading');
          $('.ct-item.active .ct-caption').dotdotdot();
        }
      });
      $ctq.on(transitionendname, '.ct-sub-item', function(e) {
        if ($(e.target).hasClass('ct-sub-item')) {
          $(e.target).removeClass('fading');
          $('.ct-sub-item.active .ct-caption').dotdotdot();
        }
      });
    }

    // zoom in
    $('.ct-thumbnail-image').click(function (e) {
      var key = $(e.target).closest('[data-image-select-key]').data('image-select-key');
      var value = $(e.target).closest('[data-image-select-value]').data('image-select-value');
      var keys = keyToArray(key);
      var $container = $('#ct-full-image-container');
      $container.empty();

      var selectionCertainty = (selections.hasOwnProperty(value) && selections[value].certainty) || 0;
      var selected = selectionCertainty == 1 ? 'ct-selected ct-certain-selected' : selectionCertainty == 0.5 ? 'ct-selected ct-uncertain-selected' : '';
      var similarSpecies = itemValueMap[value].similarSpecies.join(', ');
      var templateObj = {value: value, key: key, selected: selected, similarSpecies: similarSpecies};

      var urls = _.map(_.filter(_.zip(keys, _.map(keys, function(key, i) { return firstInfoWithKey(key); })), function(keyAndInfo, i) {
        if (keyAndInfo[1] == null && window.console) console.warn('Missing info ' + keyAndInfo[0]);
        return keyAndInfo[1] != null;
      }), function(keyAndInfo, i) {
        return {
          key: keyAndInfo[0],
          url: keyAndInfo[1].imageUrl,
          idx: i,
          active: function() {
            return i == 0 ? 'active' : '';
          }
        }
      });
      var change = false;
      if (urls.length > 1) {
        var carousel = mu.appendTemplate($container, 'carousel-template', _.extend({imgs: urls}, templateObj));
        //var carousel = $('#ct-full-image-carousel');
        carousel.carousel({interval: false});
        carousel.find('[title]').tooltip();
        change = true;
      } else if (urls.length == 1) {
        var $img = mu.appendTemplate($container, 'single-image-template', _.extend({url: urls[0].url}, templateObj));
        $img.find('[title]').tooltip();
        change = true;
      }
      if (change) switchCtPage('#ct-full-image-container');
    });

    // zoom out
    $('#ct-full-image-container').on('click', 'img, .ct-full-image-carousel-close', function (e) {
      switchCtPage('#ct-animals-present');
      var $container = $('#ct-full-image-container');
      $container.find('[title]').tooltip('hide');
      $container.empty();
    });

    $('.btn-ct-landing').click(function (e) {
      e.preventDefault();
    });

    $('#ct-container')
      .on('click', '.ct-badge-sure', function (e) {
        ctBadgeClick(e, 1);
      })
      .on('click', '.ct-badge-uncertain', function (e) {
        ctBadgeClick(e, 0.5);
      });

    function ctBadgeClick(e, selectionCertainty) {
      var t = $(e.target);
      var badge = t.closest('.badge');

      var selectedThumbnail = t.closest('[data-image-select-value]');//.closest('.thumbnail');
      var value = selectedThumbnail.data('image-select-value');
      var imageKey = selectedThumbnail.data('image-select-key');
      if (selections.hasOwnProperty(value) && selections[value].certainty == selectionCertainty) {
        delete selections[value];
      } else {
        selections[value] = {certainty: selectionCertainty, key: imageKey};
      }
      syncSelectionState();
    }

    function valueToSelector(v, i, a) {
      return '[data-image-select-value="' + v + '"]'
    }

    function addSelectionToContainer(sel, selElem) {
      var certainty = selections[sel].certainty;
      var imageKey = selections[sel].key;
      var firstKey = keyToArray(imageKey)[0];
      var imageInfo = firstInfoWithKey(firstKey);
      var imageUrl = imageInfo ? imageInfo.squareThumbUrl : null;
      var selected = (certainty > .5) ? 'ct-certain-selected' : 'ct-uncertain-selected';
      var opts = {
        squareThumbUrl: imageUrl,
        value: sel,
        key: imageKey,
        selected: selected
      };
      mu.appendTemplate(selElem, 'selected-item-template', opts);
      $('.ct-caption').dotdotdot();
    }

    function syncSelectionState() {
      var ctContainer = $('#ct-container');
      var selectedValues = _.keys(selections);
      //var badgeSelector = _.map(selectedValues, valueToBadgeSelector).join(', ');
      var nonSelector = _.map(_.difference(values, selectedValues), valueToSelector).join(', ');

      var selElem = $('.ct-selection-grid');
      var uiSelectedValues = selElem.find('.thumbnail').map(function (i, e) {
        return $(e).data('image-select-value');
      }).toArray();

      var add = _.difference(selectedValues, uiSelectedValues);

      for (var i = 0; i < add.length; ++i) {
        addSelectionToContainer(add[i], selElem);
      }
      selElem.find(nonSelector).parent().remove();

      //ctContainer.find('[data-image-select-value] .badge').removeClass('selected');
      //ctContainer.find(badgeSelector).addClass('selected');

      ctContainer.find(nonSelector).removeClass('ct-selected ct-uncertain-selected ct-certain-selected');
      ctContainer.find(_.map(selectedValues, valueToSelector).join(', ')).each(function() {
        var $this = $(this);
        var certain = selections[$this.data('image-select-value')].certainty == 1;
        $this.addClass('ct-selected ct-'+(certain ? 'certain' : 'uncertain') +'-selected');
        $this.removeClass('ct-' + (certain ? 'uncertain' : 'certain') +'-selected');
      });

      generateFormFields();
    }

    function syncUnlistedTray() {
      var checked = $unlisted.find('input[name=recordValues\\.0\\.unknown]').is(':checked');
      $('.ct-unknown-selections-unknown').find('span').text(checked == true ? "Unknown animal in the image" : "");
      var unlisted = _.filter($('#ct-unlisted').find('input[type="text"]').map(function (i, e) {
        return $(this).val()
      }), function (o) {
        return o != null && o != "" && o.trim() != ""
      }).join(', ');
      var $unknownSelections = $('.ct-unknown-selections');
      $unknownSelections.find('label').css('display', unlisted ? 'inline-block' : 'none');
      $unknownSelections.find('span').text(unlisted);
    }

    function generateFormFields() {
      var $ctFields = $('#ct-fields');
      $ctFields.empty();
      var i = 0;
      _.each(selections, function (value, key, list) {
        mu.appendTemplate($ctFields, 'input-template', {id: 'recordValues.' + i + '.vernacularName', value: key});
        mu.appendTemplate($ctFields, 'input-template', {
          id: 'recordValues.' + i + '.certainty',
          value: value.certainty
        });
        ++i;
      });
    }

    function keyToArray(key) {
      var r = new RegExp('([^\\[\\]\\,]+)', 'g');
      var matches = [];
      var match;
      while (match = r.exec(key)) {
        match = match[0];
        if (match) match = match.trim();
        matches.push(match);
      }
      return matches;
    }

    function firstInfoWithKey(key) {
      return (smImageInfos || {})[key];
    }

    var $unlisted = $('#ct-unlisted');

    $unlisted.on('change keyup paste input propertychange autocompletechange', 'input', function (e) {
      syncUnlistedTray();
    });

    $unlisted.on('change keyup paste input propertychange autocompletechange', '.speciesName:last', function (e) {
      var $this = $(this);
      if ($this.val()) {
        var index = $unlisted.children().length;
        var input = mu.appendTemplate($unlisted, 'new-unlisted-template', {
          placeholder: placeholders[index % placeholders.length],
          index: index
        });
        fixUnlisted();
        bindAutocompleteToElement(input.find('input.autocomplete')); // task.gsp
      }
    });

    $unlisted.on('blur', '.speciesName:not(:last)', function (e) {
      var $this = $(this);
      if (!$this.val()) {
        $this.closest('.control-group').remove();
        fixUnlisted();
      }
    });

    function fixUnlisted() {
      var $unlisted = $('#ct-unlisted');
      $unlisted.find('.control-group:not(:first)').each(function (i, e) {
        var $this = $(this);
        var attrVal = 'recordValues.' + i + '.unlisted';
        $this.find('input').attr('name', attrVal)
          .attr('id', attrVal);
        $this.find('label').attr('for', attrVal);
      });
    }

    $('#ct-animals-question input').change(function(e) {
      var $this = $(this);
      $('#ct-animals-question-summary').text($this.val());
    });
    $('#ct-bnw-question input').change(function(e) {
      var $this = $(this);
      $('#ct-bnw-question-summary').text($this.val());
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

    $imgSeq.on('click', '.faux-img-cell', function(e) {
      var $this = $(this);
      if (!$clicked.is($this)) {
        $clicked = $this;
        loadImage($this);
      } else {
        $clicked = $defaultImg;
        loadImage($defaultImg);
      }
    });

    $imgSeq.on('mouseover', '.faux-img-cell', function(e) {
      var $this = $(this);
      loadImage($this);
    });

    $imgSeq.on('mouseout', '.faux-img-cell', function(e) {
      var $this = $(this);
      loadImage($clicked);
    });

    $('#ct-question-span').click(function(e) {
      $clicked = $defaultImg;
      loadImage($defaultImg);
    });

    // SORT BUTTONS
    var $ctSortBtns = $('#ct-sort-btn-group');
    $ctSortBtns.on('change', 'input[type="radio"]', function (e) {
      var $this = $(this);
      var alreadyActive = $this.hasClass('active');
      var sortType = $this.data('sort-fn');
      var sortFn;
        if (sortType == 'alpha') {
          sortFn = function (a, b) {
            return ($(a).find('[data-image-select-value]').data('image-select-value') || "").localeCompare($(b).find('[data-image-select-value]').data('image-select-value'));
          }
        } else if (sortType == 'common') {
          sortFn = function (a, b) {
            // reverse order in difference below, so popularity is sorted descending instead of ascending
            var bIdx = parseInt($(a).find('[data-image-select-value]').data('popularity'));
            var aIdx = parseInt($(b).find('[data-image-select-value]').data('popularity'));
            if (aIdx == bIdx) {
              aIdx = parseInt($(a).data('item-index'));
              bIdx = parseInt($(b).data('item-index'));
            }
            return (aIdx - bIdx);
          }
        } else if (sortType == 'previous') {
          sortFn = function (a, b) {
            // reverse order in difference below, so last-used is sorted descending instead of ascending
            var bIdx = parseInt($(a).find('[data-image-select-value]').data('last-used'));
            var aIdx = parseInt($(b).find('[data-image-select-value]').data('last-used'));
            if (aIdx == bIdx) {
              aIdx = parseInt($(a).data('item-index'));
              bIdx = parseInt($(b).data('item-index'));
            }
            return (aIdx - bIdx);
          }
        } else {
          sortFn = function (a, b) {
            return parseInt($(a).data('item-index')) - parseInt($(b).data('item-index'));
          }
        }
      $('.sortable').each(function () {
        var $this = $(this);
        var parent = $this.find('.itemgrid');
        parent.find('.griditem.bvpBadge').sort(sortFn).appendTo(parent);
      });
    });

    // Store last filter used
    $ctSortBtns.on('change', 'input[type="radio"]', function(e) {
      var id = $(e.target).attr('id');
      amplify.store('bvp_ct_last_filter', id);
    });

    // FILTERING
    // text filtering
    var filterText = '';
    var filterTags = {};
    var $searchInput = $('#ct-search-input');

    function filterAnimals() {
      var hasFilterTags = _.keys(filterTags).length > 0;
      var valueElems = $('#ct-animals-present').find('[data-image-select-value]');
      var parts = _.partition(valueElems, function (e,i) {
        var $e = $(e);
        var matchesText = $e.data('image-select-value').toLocaleLowerCase().indexOf(filterText) !== -1;
        var matchesTags = !hasFilterTags || _.any(keyToArray($e.data('tags')), function(tag) { return filterTags.hasOwnProperty(tag); });
        return matchesText && matchesTags;
      });
      $(parts[0]).parent().show(100);
      $(parts[1]).parent().hide(100);
    }

    $searchInput.on('change keyup paste input propertychange', function () {
      filterText = $searchInput.val().toLocaleLowerCase();
      filterAnimals();
    });

    $('#ct-animals-btn-group').on('change', 'input[type="radio"]', function(e) {
      var $this = $(this);
      var selectedTags = keyToArray($this.data('filter-tag'));
      filterTags = {}; // remove for checkbox style filter buttons
      _.each(selectedTags, function(selectedTag) {
        if (filterTags.hasOwnProperty(selectedTag)) {
          delete filterTags[selectedTag];
        } else {
          filterTags[selectedTag] = true;
        }
      });
      filterAnimals();
    });

    // VALIDATION
    transcribeValidation.addCustomValidator(function(errorList) {
      var q1 = $('input[name=recordValues\\.0\\.animalsVisible]:checked').val();
      //var q2 = $('input[name=recordValues\\.0\\.photoBlackAndWhite]:checked').val()

      if (!q1) errorList.push({element: null, message: "You must indicate whether animals are present on Step 1", type: "Error"});
      //if (!q2) errorList.push({element: null, message: "You must indicate whether the photo is black and white or not on Step 1", type: "Error"});

      if (q1 == $('#btn-animals-present').val()) {
        var count = _.keys(selections).length;
        count += $unlisted.find('input.speciesName').filter(function(i,e) { return $(this).val() }).length;
        count += $unlisted.find('input[name=recordValues\\.0\\.unknown]').is(':checked') == true ? 1 : 0;

        if (count < 1) {
          errorList.push({element: null, message: "You must select at least one animal", type: "Error" });
        }
      }
    });
    transcribeValidation.setErrorRenderFunctions(function (errorList) {
    },
    function() {
    });

    submitRequiresConfirmation = true;
    postValidationFunction = function(validationResults) {
      if (validationResults.errorList.length > 0) bootbox.alert("<h3>Invalid choices</h3><ul><li>" + _.pluck(validationResults.errorList, 'message').join('</li><li>') + "</li>");
    };

    transcribeWidgets.addBeforeSubmitHook(function (e) {
      generateFormFields();
      $unlisted.find('input.speciesName').each(function() {
        var $this = $(this);
        if (!$this.val()) $this.remove();
      });
      return true;
    });

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

    // restore filter
    var lastFilter = amplify.store('bvp_ct_last_filter');
    if (lastFilter) $('#'+lastFilter).click();

    // force intial sync of saved values
    syncSelectionState();
    syncUnlistedTray();

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