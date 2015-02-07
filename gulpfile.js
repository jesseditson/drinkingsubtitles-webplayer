var gulp = require('gulp');
var browserify = require('gulp-browserify');
var riot = require('gulp-riot');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var open = require('gulp-open');
var inject = require('gulp-inject');
var watch = require('gulp-watch');

var paths = {
  js : 'src/javascripts/**/*.js',
  css : 'src/styles/**/*.scss',
  tags : 'src/tags/**/*.tag',
  tags_build : 'build/tags/**/*.js',
  js_build : 'build/javascripts/main.js',
  css_build : 'build/styles/**/*.css'
}

gulp.task('build-styles', function () {
  gulp.src(paths.css)
    .pipe(sourcemaps.init())
    .pipe(sass())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/styles'));
});

gulp.task('build-javascripts',function(){
  gulp.src('src/javascripts/main.js')
    .pipe(browserify({
      insertGlobals : true,
      debug : !gulp.env.production
    }))
    .pipe(gulp.dest('build/javascripts'));
});

gulp.task('build-tags',function(){
  gulp.src(paths.tags)
  .pipe(riot({
    type : 'none'
  }))
  .pipe(gulp.dest('build/tags'));
});

gulp.task('inject-client',function(){
  gulp.src('index.html')
    .pipe(inject(
      gulp.src([paths.js_build,paths.css_build,paths.tags_build],{read: false}),
      {relative : true}
    ))
    .pipe(gulp.dest('.'));
});

gulp.task('open-index',function(){
  gulp.src('index.html')
    .pipe(open());
});

gulp.task('build',['build-styles','build-javascripts','build-tags','inject-client']);

gulp.task('watch',function(){
  gulp.start('build');
  watch([
    paths.js,
    paths.css,
    paths.tags
  ], function(){
    gulp.start('build');
  });
  gulp.start('open-index');
});
