/*
 * GULP build file to automatically prefix CSS files when they change
 */

var gulp = require('gulp');
var autoprefixer = require('gulp-autoprefixer');
var cleancss = require('gulp-clean-css');
var purgecss = require('gulp-purgecss');

gulp.task('styles', function (done) {
  'use strict';
  gulp.src('src/**/*.css')
    .pipe(purgecss({
      content: ['src/**/*.html', 'index.html']
    }))
    .pipe(cleancss({
      format: 'beautify',
      level: 2
    }))
    .pipe(autoprefixer())
    .pipe(gulp.dest('build'));
  done();
});

gulp.task('watch', function () {
  'use strict';
  gulp.watch('src/**/*.css', gulp.series('styles'));
});
