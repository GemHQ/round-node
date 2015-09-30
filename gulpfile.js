gulp = require('gulp')
source = require("vinyl-source-stream")
browserify = require("browserify")

gulp.task('build', function() {
  var b = browserify('lib/index.js')
  b.bundle()
    .pipe(source('index.js'))
    .pipe(gulp.dest('./lib/browser.js'))
});

