(function( $ ){

    $.fn.panZoom = function(method) {
        if ( methods[method] ) {
            return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist' );
        }
    };

    $.fn.panZoom.defaults = {
        active            : true,
        zoomIn            : false,
        zoomOut           : false,
        panUp             : false,
        panDown           : false,
        panLeft           : false,
        panRight          : false,
        fit               : false,
        destroy           : false,
        out_x1            : false,
        out_y1            : false,
        out_x2            : false,
        out_y2            : false,
        min_width         : 20,
        min_height        : 20,
        zoom_step         : 3,
        pan_step          : 3,
        debug             : false,
        directedit        : false,
        aspect            : true,
        factor            : 1,
        animate           : true,
        animate_duration  : 200,
        animate_easing    : 'linear',
        double_click      : true,
        mousewheel        : true,
        mousewheel_delta  : 1,
        draggable         : true,
        clickandhold      : true,
        startPosition         : null
    };

    var settings = {}

    var methods = {
        'init': function (options) {
            jQuery.extend(settings, $.fn.panZoom.defaults, options);
            setupCSS.apply(this);
            setupData.apply(this);
            setupBindings.apply(this);
            methods.readPosition.apply(this);

            if ($(this).attr("image-height") && $(this).attr("image-width")) {
                var imageHeight = parseInt($(this).attr("image-height"));
                var imageWidth = parseInt($(this).attr("image-width"));
                var data = this.data('panZoom');
                data.target_dimensions.y = imageHeight;
                data.target_dimensions.x = imageWidth;
                data.target_dimensions.ratio = data.target_dimensions.x / data.target_dimensions.y;
                methods.fit.apply(this);
            }

            if (settings.startPosition) {
                data.position.x1 = settings.startPosition.x1;
                data.position.y1 = settings.startPosition.y1;
                data.position.x2 = settings.startPosition.x2;
                data.position.y2 = settings.startPosition.y2;
                methods.updatePosition.apply(this);
            }

        },

        'destroy': function () {
            var data = this.data('panZoom');
            data.bound_elements.unbind('.panZoom');
            if (settings.draggable && typeof(this.draggable) == 'function') {
                this.draggable('destroy');
            }
            this.removeData('panZoom');
        },

        'loadImage': function () {
            var data = this.data('panZoom');
            loadTargetDimensions.apply(this);
            methods.updatePosition.apply(this);
            if (data.last_image != null && data.last_image != this.attr('src')) {
                methods.fit.apply(this);
            }
            data.last_image = this.attr('src');
            data.loaded = true;
        },

        'readPosition': function () {
            var data = this.data('panZoom');
            if (settings.out_x1) { data.position.x1 = settings.out_x1.val()*settings.factor }
            if (settings.out_y1) { data.position.y1 = settings.out_y1.val()*settings.factor }
            if (settings.out_x2) { data.position.x2 = settings.out_x2.val()*settings.factor }
            if (settings.out_y2) { data.position.y2 = settings.out_y2.val()*settings.factor }
            methods.updatePosition.apply(this);
        },

        'updatePosition': function(centreIfSmall) {
            validatePosition.apply(this, [centreIfSmall]);
            writePosition.apply(this);
            applyPosition.apply(this);
        },

        'fit': function () {
            var data = this.data('panZoom');
            data.position.x1 = 0;
            data.position.y1 = 0;
            data.position.x2 = data.viewport_dimensions.x;
            data.position.y2 = data.viewport_dimensions.y;
            methods.updatePosition.apply(this);
        },

        'zoomIn': function (steps) {
            var data = this.data('panZoom');
            if (typeof(steps) == 'undefined') {
                var steps = getStepDimensions.apply(this);
            }

            data.position.x1 = data.position.x1*1 - steps.zoom.x;
            data.position.x2 = data.position.x2*1 + steps.zoom.x;
            data.position.y1 = data.position.y1*1 - steps.zoom.y;
            data.position.y2 = data.position.y2*1 + steps.zoom.y;
            methods.updatePosition.apply(this);
        },

        'zoomOut': function (steps) {
            var data = this.data('panZoom');
            if (typeof(steps) == 'undefined') {
                var steps = getStepDimensions.apply(this);
            }
            data.position.x1 = data.position.x1*1 + steps.zoom.x;
            data.position.x2 = data.position.x2*1 - steps.zoom.x;
            data.position.y1 = data.position.y1*1 + steps.zoom.y;
            data.position.y2 = data.position.y2*1 - steps.zoom.y;
            methods.updatePosition.apply(this, [ true ]);
        },

        'panUp': function () {
            var data = this.data('panZoom');
            var steps = getStepDimensions.apply(this);
            data.position.y1 -= steps.pan.y;
            data.position.y2 -= steps.pan.y;
            methods.updatePosition.apply(this);
        },

        'panDown': function () {
            var data = this.data('panZoom');
            var steps = getStepDimensions.apply(this);
            data.position.y1 = data.position.y1*1 + steps.pan.y;
            data.position.y2 = data.position.y2*1 + steps.pan.y;
            methods.updatePosition.apply(this);
        },

        'panLeft': function () {
            var data = this.data('panZoom');
            var steps = getStepDimensions.apply(this);
            data.position.x1 -= steps.pan.x;
            data.position.x2 -= steps.pan.x;
            methods.updatePosition.apply(this);
        },

        'panRight': function () {
            var data = this.data('panZoom');
            var steps = getStepDimensions.apply(this);
            data.position.x1 = data.position.x1*1 + steps.pan.x;
            data.position.x2 = data.position.x2*1 + steps.pan.x;
            methods.updatePosition.apply(this);
        },

        'mouseWheel': function (delta) {
            // first calculate how much to zoom in/out
            var steps = getStepDimensions.apply(this);
            steps.zoom.x = steps.zoom.x * (Math.abs(delta) / settings.mousewheel_delta);
            steps.zoom.y = steps.zoom.y * (Math.abs(delta) / settings.mousewheel_delta);

            // then do it
            if (delta > 0) {
                methods.zoomIn.apply(this, [steps]);
            } else if (delta < 0) {
                methods.zoomOut.apply(this, [steps]);
            }
        },

        'dragComplete': function() {
            var data = this.data('panZoom');
            data.position.x1 = this.position().left;
            data.position.y1 = this.position().top;
            data.position.x2 = this.position().left*1 + this.width();
            data.position.y2 = this.position().top*1 + this.height();
            methods.updatePosition.apply(this);
        },

        'mouseDown': function (action) {
            methods[action].apply(this);

            if (settings.clickandhold) {
                var data = this.data('panZoom');
                methods.mouseUp.apply(this);
                data.mousedown_interval = window.setInterval(function (that, action) {
                    that.panZoom(action);
                }, settings.animate_duration, this, action);
            }
        },

        'mouseUp': function() {
            var data = this.data('panZoom');
            window.clearInterval(data.mousedown_interval);
        },
        'disable': function() {
            settings.active = false;
            if (settings.draggable && typeof(this.draggable) == 'function') {
                this.draggable('disable');
                this.removeClass('ui-state-disabled');
            }
        },
        'enable': function() {
            settings.active = true;
            if (settings.draggable && typeof(this.draggable) == 'function') {
                this.draggable('enable');
            }
        },
        'getPosition': function() {
            var data = this.data('panZoom');
            var pos = {
                x1: data.position.x1,
                y1: data.position.y1,
                x2: data.position.x2,
                y2: data.position.y2
            };
            return pos
        },
        'notifyResize': function() {
            var data = this.data('panZoom');
            data.viewport_dimensions = { x: data.target_element.parent().width(), y: data.target_element.parent().height() };
        }
    }; // Methods

    function setupBindings() {

        eventData = { target: this }
        var data = this.data('panZoom');

        if (!data) {
            return;
        }

        // bind up controls
        if (settings.zoomIn) {
            settings.zoomIn.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault(); event.data.target.panZoom('mouseDown', 'zoomIn');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault(); event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault()
                    }
                } );
            data.bound_elements = data.bound_elements.add(settings.zoomIn);
        }

        if (settings.zoomOut) {
            settings.zoomOut.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('mouseDown', 'zoomOut');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault();
                        event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault();
                    }
                });
            data.bound_elements = data.bound_elements.add(settings.zoomOut);
        }

        if (settings.panUp) {
            settings.panUp.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('mouseDown', 'panUp');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault(); event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault();
                    }
                } );
            data.bound_elements = data.bound_elements.add(settings.panUp);
        }

        if (settings.panDown) {
            settings.panDown.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('mouseDown', 'panDown');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault();
                        event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault();
                    }
                });
            data.bound_elements = data.bound_elements.add(settings.panDown);
        }

        if (settings.panLeft) {
            settings.panLeft.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('mouseDown', 'panLeft');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault();
                        event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault();
                    }
                });
            data.bound_elements = data.bound_elements.add(settings.panLeft);
        }

        if (settings.panRight) {
            settings.panRight.bind('mousedown.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('mouseDown', 'panRight');
                }
            }).bind('mouseleave.panZoom mouseup.panZoom', eventData, function(event) {
                    if (settings.active) {
                        event.preventDefault();
                        event.data.target.panZoom('mouseUp');
                    }
                }).bind('click.panZoom', function (event) {
                    if (settings.active) {
                        event.preventDefault();
                    }
                });
            data.bound_elements = data.bound_elements.add(settings.panRight);
        }

        if (settings.fit) {
            settings.fit.bind('click.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('fit');
                }
            });
            data.bound_elements = data.bound_elements.add(settings.fit);
        }

        if (settings.destroy) {
            settings.destroy.bind('click.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.preventDefault();
                    event.data.target.panZoom('destroy');
                }
            });
            data.bound_elements = data.bound_elements.add(settings.destroy);
        }

        // double click
        if (settings.double_click) {
            this.bind('dblclick.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.data.target.panZoom('zoomIn')
                }
            });
            // no need to record in bound elements array - gets done anyway when imageload is bound
        }

        // mousewheel
        if (settings.mousewheel && typeof(this.mousewheel) == 'function') {
            this.parent().bind('mousewheel.panZoom', function(event, delta) {
                if (settings.active) {
                    event.preventDefault();
                    $(this).find('img').panZoom('mouseWheel', delta);
                }
            });
            data.bound_elements = data.bound_elements.add(this.parent());
        } else if (settings.mousewheel) {
            alert('Mousewheel requires jquery-mousewheel by Brandon Aaron (https://github.com/brandonaaron/jquery-mousewheel) - please include it or disable mousewheel to remove this warning.')
        }

        // direct form input
        if (settings.directedit) {
            $(settings.out_x1).add(settings.out_y1).add(settings.out_x2).add(settings.out_y2).bind('change.panZoom blur.panZoom', eventData, function(event) {
                if (settings.active) {
                    event.data.target.panZoom('readPosition');
                }
            });
            data.bound_elements = data.bound_elements.add($(settings.out_x1).add(settings.out_y1).add(settings.out_x2).add(settings.out_y2));
        }

        if (settings.draggable && typeof(this.draggable) == 'function') {
            this.draggable({
                stop: function () { $(this).panZoom('dragComplete'); }
            });
        } else if (settings.draggable) {
            alert('Draggable requires jQuery UI - please include jQuery UI or disable draggable to remove this warning.')
        }

        // image load
        $(this).bind('load.panZoom', eventData, function (event) {
            if (settings.active) {
                event.data.target.panZoom('loadImage');
            }
        });
        data.bound_elements = data.bound_elements.add(this);

    }

    function setupData() {
        var data = {
            target_element: this,
            target_dimensions: { x: null, y: null },
            viewport_element: this.parent(),
            viewport_dimensions: { x: this.parent().width(), y: this.parent().height() },
            position: { x1: null, y1: null, x2: null, y2: null },
            last_image: null,
            loaded: false,
            mousewheel_delta: 0,
            mousedown_interval: false,
            bound_elements: $()
        };

        this.data('panZoom', data);

        data = this.data('panZoom');

        $(window).resize(function(e) {
            // reset the parent dimensions
            data.viewport_dimensions = { x: data.target_element.parent().width(), y: data.target_element.parent().height() };
        });
    }

    function setupCSS() {
        if (this.parent().css('position') == 'static') {
            this.parent().css('position', 'relative');
        }
        this.css({
            'position': 'absolute',
            'top': 0,
            'left': 0
        });
        if (settings.draggable) {
            this.css({
                'cursor': 'move'
            });
        }
    }

    function validatePosition(centreIfSmall) {
        var data = this.data('panZoom');
        // if dimensions are too small...
        if ( data.position.x2 - data.position.x1 < settings.min_width/settings.factor || data.position.y2 - data.position.y1 < settings.min_height/settings.factor ) {
            // and second co-ords are zero (IE: no dims set), fit image
            if (data.position.x2 == 0 || data.position.y2 == 0) {
                methods.fit.apply(this);
            } else {
                if (data.position.x2 - data.position.x1 < settings.min_width/settings.factor) {
                    data.position.x2 = data.position.x1*1 + settings.min_width/settings.factor;
                }
                if (data.position.y2 - data.position.y1 < settings.min_height/settings.factor) {
                    data.position.y2 = data.position.y1*1 + settings.min_height/settings.factor;
                }
            }
        }

        if (settings.aspect) {
            var target = data.target_dimensions.ratio;
            var current = getCurrentAspectRatio.apply(this)

            if (current > target) {
                var new_width = getHeight.apply(this) * target;
                var diff = getWidth.apply(this) - new_width;
                data.position.x1 = data.position.x1*1 + (diff/2);
                data.position.x2 = data.position.x2*1 - (diff/2);
            } else if (current < target) {
                var new_height = getWidth.apply(this) / target;
                var diff = getHeight.apply(this) - new_height;
                data.position.y1 = data.position.y1*1 + (diff/2);
                data.position.y2 = data.position.y2*1 - (diff/2);
            }

            var width = data.position.x2 - data.position.x1;
            var allowedX = data.viewport_dimensions.x * 0.9;
            if (width < data.viewport_dimensions.x) {
                if (centreIfSmall) {
                    // center horizontally
                    var centerX = data.viewport_dimensions.x / 2;
                    data.position.x1 = centerX - (width/2);
                    data.position.x2 = centerX + (width/2);
                }
            } else {
                if (data.position.x2 + allowedX < data.viewport_dimensions.x) {
                    data.position.x2 = data.viewport_dimensions.x - allowedX;
                    data.position.x1 = data.viewport_dimensions.x - width - allowedX;
                } else if (data.position.x1 > allowedX) {
                    data.position.x1 = allowedX;
                    data.position.x2 = width + allowedX;
                }
            }

            var height = data.position.y2 - data.position.y1;
            var allowedY = data.viewport_dimensions.y * 0.9;
            if (height < data.viewport_dimensions.y) {
                if (centreIfSmall) {
                    var centerY = data.viewport_dimensions.y / 2;
                    data.position.y1 = centerY - (height/2);
                    data.position.y2 = centerY + (height/2);
                }
            } else {
                if (data.position.y2 + allowedY < data.viewport_dimensions.y) {
                    data.position.y2 = data.viewport_dimensions.y - allowedY;
                    data.position.y1 = data.viewport_dimensions.y - height - allowedY;
                } else if (data.position.y1 > allowedY) {
                    data.position.y1 = allowedY;
                    data.position.y2 = height + allowedY;
                }
            }
        }
    }

    function applyPosition() {

        var data = this.data('panZoom');

        width = getWidth.apply(this);
        height = getHeight.apply(this);
        left_offset = getLeftOffset.apply(this);
        top_offset = getTopOffset.apply(this);

        properties = {
            'top': Math.round(top_offset),
            'left': Math.round(left_offset),
            'width': Math.round(width),
            'height': Math.round(height)
        }

        if (data.loaded && settings.animate) {
            applyAnimate.apply(this, [ properties ]);
        } else {
            applyCSS.apply(this, [ properties ]);
        }

    }

    function applyCSS() {
        this.css( properties );
    }

    function applyAnimate() {
        this.stop().animate( properties , settings.animate_duration, settings.animate_easing);
    }

    function getWidth() {
        var data = this.data('panZoom');
        width = (data.position.x2 - data.position.x1);
        return width;
    }

    function getLeftOffset() {
        var data = this.data('panZoom');
        return data.position.x1;
    }

    function getHeight() {
        var data = this.data('panZoom');
        height = (data.position.y2 - data.position.y1);
        return height;
    }

    function getTopOffset() {
        var data = this.data('panZoom');
        top_offset = data.position.y1;
        return top_offset;
    }

    function getCurrentAspectRatio() {
        return (getWidth.apply(this) / getHeight.apply(this));
    }

    function writePosition() {
        var data = this.data('panZoom');
        if (settings.out_x1) { settings.out_x1.val(Math.round(data.position.x1 / settings.factor)) }
        if (settings.out_y1) { settings.out_y1.val(Math.round(data.position.y1 / settings.factor)) }
        if (settings.out_x2) { settings.out_x2.val(Math.round(data.position.x2 / settings.factor)) }
        if (settings.out_y2) { settings.out_y2.val(Math.round(data.position.y2 / settings.factor)) }
    }

    function getStepDimensions() {
        var data = this.data('panZoom');
        ret = {
            zoom: {
                x: (settings.zoom_step/100 * data.target_dimensions.x),
                y: (settings.zoom_step/100 * data.target_dimensions.y)
            },
            pan: {
                x: (settings.pan_step/100 * data.viewport_dimensions.x),
                y: (settings.pan_step/100 * data.viewport_dimensions.y)
            }
        }
        return ret;
    }

    function loadTargetDimensions() {
        var data = this.data('panZoom');
        if (data.target_dimensions.x == 0) {
            var img = document.createElement('img');
            img.src = this.attr('src');
            img.id = "jqpz-temp";
            $('body').append(img);
            data.target_dimensions.x = $('#jqpz-temp').width();
            data.target_dimensions.y = $('#jqpz-temp').height();
            $('#jqpz-temp').remove();
            data.target_dimensions.ratio = data.target_dimensions.x / data.target_dimensions.y;
        }
    }

})( jQuery );

$(document).ready(function() {

    $("#pinImage").click(function (e) {
        e.preventDefault();
        var imageContainer = $("#image-container");

        if (imageContainer.css("position") == 'fixed') {
            imageContainer.css({"position":"relative", top:'inherit', left:'inherit', 'border':'none' });
            $(".pin-image-control").css({'background-image':"url(${resource(dir:'images', file:'pin-image.png')})"});
            $(".pin-image-control a").attr("title", "Fix the image in place in the browser window");
            imageContainer.css("width", "100%");
        } else {
            var pageHeader = $("#page-header");
            var pageHeaderHeight = pageHeader.outerHeight() + pageHeader.position().top;
            var diff = imageContainer.outerHeight() - pageHeaderHeight - 12;

            var currentWidth = imageContainer.width();

            $("#image-parent-container").css("min-height", diff+"px");
            imageContainer.css({"position":"fixed", top:0, left:0, "z-index":600, 'border':'2px solid #535353', 'background':'darkgray' });
            $(".pin-image-control").css("background-image", "url(${resource(dir:'images', file:'unpin-image.png')})");
            $(".pin-image-control a").attr("title", "Return the image to its normal position");

            if (imageContainer.attr("preserveWidthWhenPinned") == 'true') {
                imageContainer.css("width", "" + currentWidth + "px");
            }

        }
    });

});

