/*
 * GULP build file to automatically prefix CSS files when they change
 */

var gulp = require('gulp');
var autoprefixer = require('gulp-autoprefixer');

gulp.task('styles', function (done) {
  'use strict';
  gulp.src('src/**/*.css')
    .pipe(autoprefixer())
    .pipe(gulp.dest('build'));
  done();
});

gulp.task('watch', function () {
  'use strict';
  gulp.watch('src/**/*.css', gulp.series('styles'));
});
