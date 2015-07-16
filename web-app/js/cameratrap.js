function cameratrap(smImageInfos, lmImageInfos, reptilesImageInfos, birdsImageInfos, otherImageInfos, smItems, lmItems,
                    reptilesItems, birdsItems, otherItems, recordValues, placeholders) {
  jQuery(function ($) {
    var values = [].concat(_.values(smItems), _.values(lmItems), _.values(reptilesItems), _.values(birdsItems), _.values(otherItems));

    var itemValueMap = _.reduce(_.filter([].concat(smItems, lmItems, reptilesItems, birdsItems, otherItems), function (it) {
      return it != null
    }), function (memo, it) {
      memo[it.value] = it;
      return memo;
    }, {});

    var unlisted = [];

    var selections = {};

    // setup initial selection state from recordValues
    for (var index in recordValues) {
      if (recordValues.hasOwnProperty(index)) {
        var vn = recordValues[index].vernacularName;
        var certainty = recordValues[index].certainty || 1;
        if (vn && itemValueMap[vn]) {
          selections[vn] = {certainty: certainty, key: itemValueMap[vn].key}
        }
      }
    }

    function page(id) {
      return {'page': id};
    }

    if (history.replaceState) {
      history.replaceState(page('ct-landing'), window.document.title);
    }

    $('#ct-step1').find('.btn').click(function (e) {
      e.preventDefault();
      var $this = $(this);
      var value = $this.attr('data-value');
      var label = $this.text();
      $('#recordValues\\.0\\.animalsVisible').val(value);

      if (value != $('#btn-animals-present').data('value')) {
        bootbox.confirm('Are you sure you wish to record "' + label + '" as your answer?', function (result) {
          if (result) {
            $('#btnSave').click();
          }
        });
      }
    });

    var $ctq = $('#camera-trap-questions');
    var transitionendname = transitionEnd($ctq).whichTransitionEnd();

    function switchCtPage(to) {
      var $ctq = $('#camera-trap-questions');
      // kill any existing transition
      $ctq.children('.fading').removeClass('fading');
      var otherActives = $ctq.children('.active:not(' + to + ')');
      otherActives.removeClass('active');
      if (transitionendname) otherActives.addClass('fading');
      $(to).addClass('active');
    }


    if (transitionendname) {
      $ctq.on(transitionendname, '.ct-item', function (e) {
        // only handle the ct-item transition
        if ($(e.target).hasClass('ct-item')) {
          $(e.target).removeClass('fading');
          $('.active .ct-caption').dotdotdot();
        }
      });
    }

    $('#ct-step2-back').click(function (e) {
      if (history.pushState) {
        history.back();
      } else {
        switchCtPage('ct-animals-present');
      }
    });

    $('a[data-toggle="pill"], a[data-toggle="tab"]').on('shown', function (e) {
      $('.ct-caption', this).dotdotdot();
    });

    $('a[data-toggle="pill"], a[data-toggle="tab"]').on('show', function(e) {
      var $toolbar = $('#ct-animals-pill-content').find('.ct-toolbar');
      if ($(this).hasClass('ct-no-toolbar')) $toolbar.hide();
      else $toolbar.show();
    });

    function animalsPresent() {
      switchCtPage('#ct-animals-present');
      if (history.pushState)
        history.pushState(page('ct-animals-present'), window.document.title);
    }

    $('#btn-animals-present').click(function (e) {
      e.preventDefault();
      animalsPresent();
    });

    // zoom in
    $('.ct-thumbnail-image').click(function (e) {
      var key = $(e.target).closest('[data-image-select-key]').data('image-select-key');
      var value = $(e.target).closest('[data-image-select-value]').data('image-select-value');
      var keys = keyToArray(key);
      var $container = $('#ct-full-image-container');
      $container.empty();

      var selectionCertainty = (selections.hasOwnProperty(value) && selections[value].certainty) || 0;
      var sureSelected = selectionCertainty == 1 ? 'selected' : '';
      var uncertainSelected = selectionCertainty == 0.5 ? 'selected' : '';
      var templateObj = {value: value, key: key, sureSelected: sureSelected, uncertainSelected: uncertainSelected};

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

    var ctBadges = {1: 'ct-badge-sure', 0.5: 'ct-badge-uncertain'};
    var badges = {1: 'badge-success', 0.5: 'badge-warning'};
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

    function valueToBadgeSelector(v, i, a) {
      return '[data-image-select-value="' + v + '"] .badge.' + ctBadges[selections[v].certainty]
    }

    function valueToSelector(v, i, a) {
      return '[data-image-select-value="' + v + '"]'
    }

    function addSelectionToContainer(sel, selElem) {
      var certainty = selections[sel].certainty;
      var imageKey = selections[sel].key;
      var firstKey = keyToArray(imageKey)[0];
      var imageUrl = firstInfoWithKey(firstKey).squareThumbUrl;
      var opts = {
        squareThumbUrl: imageUrl,
        value: sel,
        key: imageKey,
        success: certainty == 1,
        uncertain: certainty < 1
      };
      mu.appendTemplate(selElem, 'selected-item-template', opts);
      $('.ct-caption').dotdotdot();
    }

    function syncSelectionState() {
      var ctContainer = $('#ct-container');
      var selectedValues = _.keys(selections);
      var badgeSelector = _.map(selectedValues, valueToBadgeSelector).join(', ');
      var nonSelector = _.map(_.difference(values, selectedValues), valueToSelector).join(', ');

      var selElem = $('#ct-selection-grid');
      var uiSelectedValues = selElem.find('.thumbnail').map(function (i, e) {
        return $(e).data('image-select-value');
      }).toArray();

      var add = _.difference(selectedValues, uiSelectedValues);

      for (var i = 0; i < add.length; ++i) {
        addSelectionToContainer(add[i], selElem);
      }
      selElem.find(nonSelector).parent().remove();

      ctContainer.find('[data-image-select-value] .badge').removeClass('selected ' + _.values(badges).join(' '));
      ctContainer.find(badgeSelector).addClass('selected');

      generateInputFields();
    }

    function syncUnlistedTray() {
      var checked = $('#recordValues\\.0\\.unknown').prop('checked');
      $('#ct-unknown-selections-unknown').find('span').text(checked ? "Unknown checked" : "");
      var unlisted = _.filter($('#unlisted').find('input[type="text"]').map(function (i, e) {
        return $(this).val()
      }), function (o) {
        return o != null && o != "" && o.trim() != ""
      }).join(', ');
      var $unknownSelections = $('#ct-unknown-selections');
      $unknownSelections.find('label').css('display', unlisted ? 'inline-block' : 'none');
      $unknownSelections.find('span').text(unlisted);
    }

    function generateInputFields() {
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
      return (smImageInfos || {})[key] || (lmImageInfos || {})[key] || (reptilesImageInfos || {})[key] || (birdsImageInfos || {})[key] || (otherImageInfos || {})[key];
    }

    var $unlisted = $('#unlisted');

    $unlisted.on('change keyup paste input propertychange', 'input', function (e) {
      syncUnlistedTray();
    });

    $unlisted.on('change keyup paste input propertychange', '.speciesName:last', function (e) {
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
      var $unlisted = $('#unlisted');
      $unlisted.find('.control-group:not(:first)').each(function (i, e) {
        var $this = $(this);
        var attrVal = 'recordValues.' + i + '.unlisted';
        $this.find('input').attr('name', attrVal)
          .attr('id', attrVal);
        $this.find('label').attr('for', attrVal);
      });
    }

    var sorted = false;
    $('#button-sort-items').click(function (e) {
      sorted = !sorted;
      var sortFn;
      if (sorted) {
        sortFn = function (a, b) {
          return ($(a).find('[data-image-select-value]').data('image-select-value') || "").localeCompare($(b).find('[data-image-select-value]').data('image-select-value'));
        }
      } else {
        sortFn = function (a, b) {
          return parseInt($(a).data('item-index')) - parseInt($(b).data('item-index'));
        }
      }
      $('.pill-pane.sortable').each(function () {
        var $this = $(this);
        var parent = $this.find('.itemgrid');
        parent.find('.griditem.bvpBadge').sort(sortFn).appendTo(parent);
      });
    });

    window.onpopstate = function (e) {
      var state = window.history.state;
      if (state.page) {
        switchCtPage('#' + state.page);
      }
    };

    transcribeValidation.addCustomValidator(function(errorList) {
      var q1 = $('#recordValues\\.0\\.animalsVisible').val();


      if (q1 == $('#btn-animals-present').data('value')) {
        var count = _.keys(selections).length;
        count += $unlisted.find('input.speciesName').filter(function(i,e) { return $(this).val() }).length;
        count += $unlisted.find(bvp.escapeId('recordValues.0.unknown')).prop('checked') ? 1 : 0;

        if (count < 1) {
          errorList.push({element: null, message: "You must select at least one animal", type: "Error" });
        }
      }
    });
    transcribeValidation.setErrorRenderFunctions(function (errorList) {
      //bootbox.alert(_.pluck(errorList, 'message').join('.  '));
    },
    function() {

    });



    transcribeWidgets.addBeforeSubmitHook(function (e) {
      generateInputFields();
      $unlisted.find('input.speciesName').each(function() {
        var $this = $(this);
        if (!$this.val()) $this.remove();
      });
      return true;
    });

    // Cycling Thumbnails
    function cycleImages() {
      $('.pill-pane.active .cycler, .tab-pane.active .cycler').filter(function(i) { return $("img", this).length > 1 }).each(function (e) {
        var $this = $(this);
        var $active = $this.find('.active');
        var $next = ($active.next().length > 0) ? $active.next() : $this.find('img:first');
        //if (!$active.is($next)) {
          $active.removeClass('active');
          $next.addClass('active');
        //}
      });
    }

    setInterval(cycleImages, 7000);

    if (recordValues && recordValues['0'] && ('some' === recordValues['0'].animalsVisible)) animalsPresent();

    // force intial sync of saved values
    syncSelectionState();
    syncUnlistedTray();

    // enable tooltips
    $('[title]').tooltip();

    // enable filtering
    var filterText = '';
    var $searchInput = $('#ct-search-input');

    function filterAnimals() {
      var valueElems = $('#ct-animals-present').find('[data-image-select-value]');
      valueElems.filter(function (i, e) {
        return $(this).data('image-select-value').toLocaleLowerCase().indexOf(filterText) == -1;
      }).parent().hide(100);
      valueElems.filter(function (i, e) {
        return $(this).data('image-select-value').toLocaleLowerCase().indexOf(filterText) > -1;
      }).parent().show(100);
    }

    $('#button-filter').click(function () {
      var $search = $('#ct-search');
      $search.toggleClass('hidden');
      if (!$search.hasClass('hidden')) {
        filterText = $searchInput.val().toLocaleLowerCase();
        $searchInput.focus();
      } else {
        filterText = '';
      }
      filterAnimals();
    });
    $searchInput.on('change keyup paste input propertychange', function () {
      filterText = $searchInput.val().toLocaleLowerCase();
      filterAnimals();
    });

    postValidationFunction = function(validationResults) {
      bootbox.alert(_.pluck(validationResults.errorList, 'message').join('.  ') + ".");
    };
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