#!/bin/sh
# TODO Replace this with asset pipeline and use plugin bootstrap variables in main.scss
set -e
sass --scss --stop-on-error --update web-app/scss/main.scss:grails-app/assets/stylesheets/main.css
