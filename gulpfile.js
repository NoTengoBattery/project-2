/*
 * GULP build file to automatically prefix CSS files when they change
 */

var gulp = require('gulp');
var autoprefixer = require('gulp-autoprefixer');

gulp.task('styles', function (done) {
  'use strict';
  gulp.src('src/css/**/*.css')
    .pipe(autoprefixer())
    .pipe(gulp.dest('build/css'));
  done();
});

gulp.task('watch', function () {
  'use strict';
  gulp.watch('css/**/*.css', gulp.series('styles'));
});
