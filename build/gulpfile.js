/**
 * IMPORTANTE
 *
 * Si falla la generación de los favicons (gulp-image-resize) seguramente
 * será porque faltan las dependencias de ImageMagick y GraphicsMagick:
 *
 *      sudo dnf install ImageMagick GraphicsMagick
 *
 */

// Dependencias
var gulp              = require('gulp');
var concat            = require('gulp-concat');
let babel             = require('gulp-babel');
var uglify            = require('gulp-uglify');
var rename            = require('gulp-rename');
const sass            = require('gulp-sass')(require('sass'));
var sourcemaps        = require('gulp-sourcemaps');
var cleanCSS          = require('gulp-clean-css');
var imagemin          = require('gulp-imagemin');
var imageResize       = require('gulp-image-resize');
var ico               = require('gulp-to-ico');
var pngcrush          = require('imagemin-pngcrush');
var cache             = require('gulp-cache');
var composer          = require('gulp-composer');
var flatten           = require('gulp-flatten');
var rm                = require('gulp-rm');
var rmdir             = require('rmdir');
var foreach           = require('foreach');
const purgeSourcemaps = require('gulp-purge-sourcemaps');
var autoprefix        = require('gulp-autoprefixer');
var fs                = require('fs');
var exec              = require('child_process').exec;

// Archivos de configuracion
var config_clean = require('./gulp/config-clean.json');
var config_copy  = require('./gulp/config-copy.json');
var config_media = require('./gulp/config-media.json');
var config_fonts = require('./gulp/config-fonts.json');
var config_img   = require('./gulp/config-img.json');
var config_php   = require('./gulp/config-php.json');
var config_js    = require('./gulp/config-js.json');
var config_sass  = require('./gulp/config-sass.json');

/************************************************
 * Instalación fuentes                          *
 ************************************************/
gulp.task('fonts', function(done) {

    gulp.src(config_fonts.src_paths)
        //.pipe(flatten())
        .pipe(gulp.dest(config_fonts.dst_folder));

    done();
});

/************************************************
 * Limpieza de directorios generados desde gulp *
 ************************************************/
gulp.task('clean', function(done) {
    /* GULP 4 */
    foreach(config_clean.paths, function(elem, key, v) {
        console.log("\t\tBorrando "+elem);
        rmdir(elem);
    });

    done();
});

/************************************************
 * Instalación media (imagenes principalmente)  *
 ************************************************/
gulp.task('copy', function(done) {

/*
    OLD:

        gulp.src(config_media.src_paths)
            .pipe(flatten())
            .pipe(gulp.dest(config_media.dst_folder));

    GULP 3:

        config_media.paths.forEach(function(elem, index) {
            console.log("\t\tCopiando "+elem[0]+" en "+elem[1]);
            gulp.src(elem[0])
                .pipe(flatten())
                .pipe(gulp.dest(elem[1]));
    });
*/
    /* GULP 4 */
    foreach(config_copy.paths, function(elem, key, v) {
        console.log("\t\tCopiando "+elem[0]+" en "+elem[1]);
        gulp.src(elem[0])
            .pipe(flatten())
            .pipe(gulp.dest(elem[1]));
    });

    done();
});

/************************************************
 * Instalación media (imagenes principalmente)  *
 ************************************************/
gulp.task('media', function(done) {

/*
    OLD:

        gulp.src(config_media.src_paths)
            .pipe(flatten())
            .pipe(gulp.dest(config_media.dst_folder));

    GULP 3:

        config_media.paths.forEach(function(elem, index) {
            console.log("\t\tCopiando "+elem[0]+" en "+elem[1]);
            gulp.src(elem[0])
                .pipe(flatten())
                .pipe(gulp.dest(elem[1]));
    });
*/
    /* GULP 4 */
    foreach(config_media.paths, function(elem, key, v) {
        console.log("\t\tCopiando "+elem[0]+" en "+elem[1]);
        gulp.src(elem[0])
            .pipe(flatten())
            .pipe(gulp.dest(elem[1]));
    });

    done();
});

/************************************************
 * Optimizacion de archivos javascript          *
 ************************************************/
gulp.task('js', function(done) {

    // Borramos si hubiese un archivo anterior a medias
    gulp.src(config_js.dst_folder+'all.js', { read: false, allowEmpty: true })
        .pipe(rm({ async: false }));

    // Renombramos si hubiese un archivo anterior
    gulp.src(config_js.dst_folder+'all.min.js', { read: false, allowEmpty: true })
        .pipe(rename({ prefix: '_' }))
        .pipe(gulp.dest(config_js.dst_folder));

    // Generamos el nuevo
    gulp.src(config_js.src_files)
        .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(purgeSourcemaps())
        .pipe(concat('all.js'))

        // Guardamos sin minimizar
        /*.pipe(gulp.dest(config_js.dst_folder))

        // Guardamos minimizado (+ sourcemap)
        .pipe(sourcemaps.init())

        .pipe(babel({
            presets: ['@babel/preset-env']
        }).on('error', function(babel) {
            console.log(babel);
            this.emit('end');
        }))

        .pipe(uglify({ mangle: false, compress: true, parse: {} }).on('error', function(uglify) {
            console.error(uglify);
            this.emit('end');
        }))*/

        .pipe(rename({ suffix: '.min' }))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest(config_js.dst_folder));

    done();
});

/************************************************
 * Optimizacion de archivos SASS                *
 ************************************************/
gulp.task('css', function(done) {

    // Renombramos si hubiese un archivo anterior sin comprimir
    gulp.src(config_sass.dst_folder + 'all.css', { read: false, allowEmpty: true })
        .pipe(rm({ async: false }));

    // Renombramos si hubiese un archivo anterior comprimido
    gulp.src(config_sass.dst_folder + 'all.min.css', { read: false, allowEmpty: true })
        .pipe(rename({ prefix: '_' }))
        .pipe(gulp.dest(config_sass.dst_folder));

    gulp.src(config_sass.src_files)
        .pipe(sourcemaps.init({ loadMaps: true }))
        .pipe(purgeSourcemaps())
        .pipe(concat('all.scss'))
        .pipe(sass({
            paths: config_sass.src_paths
        }))
        .pipe(autoprefix(config_sass.prefixerOptions))
        .pipe(rename({basename: 'all'}))

        // Guardamos sin minimizar
        //.pipe(gulp.dest(config_sass.dst_folder))

        // Guardamos minimizado
        .pipe(rename({suffix: '.min'}))
        /*.pipe(cleanCSS({
            keepBreaks:false,
            keepSpecialComments:0,
            noAdvanced:false
        }))*/

        // Sourmap
        //.pipe(sourcemaps.init())
        //.pipe(sourcemaps.write('./'))

        //.pipe(sourcemaps.init())
        .pipe(cleanCSS({
            level: {
                2: {
                    all: true,
                    removeDuplicateRules: true
                }
            }
        }))
        //.pipe(sourcemaps.write('./'))

        .pipe(gulp.dest(config_sass.dst_folder));

    done();
});


/************************************************
 * Optimizacion de imágenes (png,gif,jpeg,svg)  *
 ***********************************************/
gulp.task('img', function(done) {

//    console.log('Imagenes optimizadas correctamente');

    gulp.src(config_img.src)
        .pipe(cache(imagemin({
            optimizationLevel: 7,    // png
            progressive: true,       // jpg
            interlaced: true,        // gif
            svgoPlugins: [{          // svg
                removeViewBox: false,
                removeUselessStrokeAndFill: false,
                removeEmptyAttrs: true
            }],
            use: [pngcrush({         // png
                reduce: true
            })]
        })))
        .pipe(gulp.dest(config_img.dst_folder));

    done();
});

/************************************************
 * Actualización paquetes PHP Composer          *
 ***********************************************/
gulp.task('composer-update', function(done) {
    composer('update', {
        'cwd': config_php.json_dir,
        'bin': config_php.php_exec+' '+config_php.composer_exec,
        'async': false
    });

    done();
});

gulp.task('composer-list', function(done) {
    composer('show', {
        'cwd': config_php.json_dir,
        'bin': config_php.php_exec+' '+config_php.composer_exec,
        'async': false
    });

    done();
});


/************************************************
 * Ejecutar automáticamente las tareas          *
 * anteriores si hay cambios                    *
 ***********************************************/
gulp.task('watch', function(done) {
  // Watch .js files
  gulp.watch(config_js.src_files, ['js']);

  // Watch .less files
  gulp.watch(config_less.src_files, ['css']);

  // Watch img files
  gulp.watch(config_img.src, ['img']);

  done();
});

/************************************************
 * TODO                                         *
 *     - Optimizar HTML                         *
 *     - Actualización phalcon (composer ???)   *
 ***********************************************/

/***********************************************
 * Ejecutamos tareas                           *
 ***********************************************/
gulp.task('all', gulp.series('composer-update', 'media', 'fonts', 'js', 'css', 'img'));

gulp.task('default', gulp.series('all'));
