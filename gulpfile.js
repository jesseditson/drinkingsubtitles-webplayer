var gulp = require('gulp');
var riot = require('gulp-riot');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var open = require('gulp-open');
var inject = require('gulp-inject');
var watch = require('gulp-watch');
var bower = require('gulp-bower');
var bowerFiles = require('main-bower-files');
var runSequence = require('run-sequence');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var util = require('gulp-util');
var riotify = require('riotify');
var del = require('del');

var paths = {
  js : 'src/javascripts/**/*.js',
  css : 'src/styles/**/*.scss',
  tags : 'src/tags/**/*.tag',
  js_build : 'build/javascripts/**/*.js',
  css_build : 'build/styles/**/*.css'
};

var getBundleName = function () {
  var version = require('./package.json').version;
  var name = require('./package.json').name;
  return version + '.' + name + '.' + 'min';
};

gulp.task('clean', function (cb) {
  return del([
    paths.js_build,
    paths.css_build
    ], cb);
});

gulp.task('build-styles', function () {
  return gulp.src(paths.css)
    .pipe(sourcemaps.init())
    .pipe(sass())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/styles'));
});

gulp.task('build-javascripts',function(){
  var bundler = browserify({
    entries : ['./src/javascripts/main.js'],
    debug : true
  });

  return bundler
    .transform(riotify)
    .bundle()
    .pipe(source(getBundleName() + '.js'))
    .pipe(buffer())
    .pipe(sourcemaps.init({loadMaps: true}))
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest('build/javascripts/'));
});

gulp.task('build-tags',function(){
  return gulp.src(paths.tags)
    .pipe(riot({
      type : 'none'
    }))
    .pipe(gulp.dest('build/tags'));
});

gulp.task('bower-install', function(){
  return bower()
    .pipe(gulp.dest('build/'));
});

gulp.task('inject-bower',['bower-install'], function(){
  return gulp.src('index.html')
    .pipe(inject(gulp.src(bowerFiles(), {read: false}), {
      name: 'bower',
      relative : true
    }))
    .pipe(gulp.dest('.'));
})

gulp.task('inject-client',function(){
  return gulp.src('./src/index.html')
    .pipe(inject(gulp.src([paths.js_build,paths.css_build],{read: false}),{
      relative:true,
      ignorePath:'build'
    }))
    .pipe(gulp.dest('./build'));
});

// In later versions of grunt, we'll be able to run things in series. But at the time of writing, multiple injects will clobber each other, so we'll use run-sequence to help us out.
gulp.task('inject',function(callback){
  runSequence('inject-bower','inject-client',callback);
});

gulp.task('open-index',function(){
  return gulp.src('./build/index.html')
    .pipe(open());
});

gulp.task('build',['clean','build-styles','build-javascripts','build-tags','inject']);

gulp.task('watch',['build'],function(){
  return watch([
    paths.js,
    paths.css,
    paths.tags
  ],function(){
    gulp.start('build');
  });
});

gulp.task('start',['watch','open-index']);
