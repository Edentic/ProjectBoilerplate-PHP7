var gulp = require('gulp'),
    livereload = require('gulp-livereload'),
    prefix = require('gulp-autoprefixer'),
    minifyCSS = require('gulp-cssnano'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify'),
    exec = require('gulp-exec'),
    sass = require('gulp-sass'),
    imagemin = require('gulp-imagemin'),
    gulpBowerFiles = require('main-bower-files'),
    gulpFilter = require('gulp-filter'),
    shell = require('gulp-shell'),
    runSequence = require('run-sequence'),
    stripDebug = require('gulp-strip-debug'),
    browserify = require('browserify'),
    es = require('event-stream'),
    source = require('vinyl-source-stream'),
    buffer = require('vinyl-buffer'),
    sourcemaps = require('gulp-sourcemaps'),
    combiner = require('stream-combiner2');

var themeDir = 'public/';
var scssDir = 'sass/';
var jsDir = themeDir + 'js/';
var cssDir = themeDir + 'css/';
var assetDir = themeDir + 'assets/img/';
var mainSassFiles = 'sass/output/*.scss';
var componentFiles = [
  {
    main: 'resources/assets/js/app.js',
    output: 'app.js'
  }
];
var sassComponentFile = 'sass/_vueComponents.scss';
var production = false;

function handleError(err) {
  console.log(err.toString());
  this.emit('end');
}

var filter = gulpFilter('**/**.js');

gulp.task('update', shell.task([
  'bower install --allow-root'
]));

gulp.task('setProduction', function() {
  production = true;
  return process.env.NODE_ENV = 'production';
});

gulp.task('vuejs', function() {
  var combines = componentFiles.map(function(item) {
    var b = browserify({
      entries: item.main,
      debug: true
    });
    b.transform('aliasify');
    b.transform('vueify', {global: true});
    b.plugin('bundlify-scss', {
      output: sassComponentFile
    });
    b.transform('babelify', {presets: ["latest"]});

    return [b, item.output];
  });

  es.merge(combines.map(function(item, key) {
    var combineArr = [ ];
    if(production) {
      combineArr = [
        item[0].bundle(),
        source(item[1]),
        buffer(),
        stripDebug(),
        sourcemaps.init({loadMaps: true}),
        uglify(),
        sourcemaps.write('./'),
        gulp.dest(jsDir)
      ];
    } else {
      combineArr = [
        item[0].bundle(),
        source(item[1]),
        buffer(),
        sourcemaps.init({loadMaps: true}),
        sourcemaps.write('./'),
        gulp.dest(jsDir)
      ];
    }

    var combined = combiner.obj(combineArr);
    combined.on('error', handleError);
    return combined;
  }));
});

gulp.task('bower', function() {
  var bowerFlow = gulp.src(gulpBowerFiles({debugging: !production}))
      .pipe(filter).on('error', handleError)
      .pipe(concat('bower.js')).on('error', handleError);

  if(production) {
    bowerFlow.pipe(uglify({mangle: false})).on('error', handleError);
  }

  bowerFlow.pipe(filter.restore()).on('error', handleError)
      .pipe(gulp.dest(jsDir));

  return bowerFlow;
});

gulp.task('jssrc', function() {
  var jsSrc = gulp.src('jsSrc/*.js');
  if(production) {
    jsSrc.pipe(uglify());
  }

  return jsSrc.pipe(gulp.dest(jsDir));
});

gulp.task('js', [
  'bower',
  //'vuejs',
  'jssrc'
]);

gulp.task('compass', function() {
  var sassFLow = gulp.src(mainSassFiles)
      .pipe(sass()).on('error', handleError)
      .pipe(prefix({ cascade: true }));

  //if(production) {
  sassFLow.pipe(minifyCSS());
  //}

  return sassFLow.pipe(gulp.dest(cssDir))
      .pipe(livereload());
});

gulp.task('imageoptim', function() {
  return gulp.src('img/**/*')
    .pipe(imagemin({
      svgoPlugins: [{removeUselessStrokeAndFill: false}]
    }))
    .pipe(gulp.dest(assetDir));
});

gulp.task('watch', function() {
  livereload.listen();
  gulp.watch(scssDir + '**/**.scss', ['compass']);
  gulp.watch(['resources/assets/js/*.js', 'resources/components/**.vue', 'resources/components/**/**.vue'], ['vuejs']);
  gulp.watch(['jsSrc/*.js'], ['jssrc']);
});

gulp.task('default', ['setProduction'], function(callback) {
  return runSequence('update',
      ['js', 'compass', 'imageoptim'],
      callback);
});