![build status](https://travis-ci.org/svi3c/gulp-i18n-compile.svg?branch=master)

# Install

    npm install grunt-i18n-compile --save-dev

# The translation format

The format is adopted from the
[grunt-i18n-compile](https://www.npmjs.com/package/grunt-i18n-compile#the-translation-format) task.

The advantages of this format are:

 * The files can be separated without having to create one file for each locale. This is especially useful for projects
 with a lot of keys and many supported languages.
 * All translations of the same message key are kept in the same file. This allows you to be more DRY in your message
 files.

The source files for this plugin must be json formatted. If you wish to use YAML, you can pipe the files through
[gulp-yaml](https://www.npmjs.com/package/gulp-yaml) before applying this compiler.

# Usage

## API

```js
i18nCompile(output, [options])
```

### output

The name of the output file.

### options

An optional configuration with the following properties.

#### options.localePlaceholder

If this placeholder is defined, it will be used to generate one json file per locale.
The `output` argument should contain this placeholder.

## Examples

### With JSON input:
```js
var gulp = require("gulp");
var i18nCompile = require("gulp-i18n-compile");

gulp.task("i18n", function() {
  gulp.src("src/i18n/**/*.json")
    .pipe(i18nCompile("translations.json"))
    .pipe(gulp.dest("dist/i18n"));
});
```

### With YAML input:
```js
var gulp = require("gulp");
var yaml = require("gulp-yaml");
var i18nCompile = require("gulp-i18n-compile");

gulp.task("i18n", function() {
  gulp.src("src/i18n/**/*.json")
    .pipe(yaml())
    .pipe(i18nCompile("translations.json"))
    .pipe(gulp.dest("dist/i18n"));
});
```

### Compile to one JSON file per locale:

```js
var gulp = require("gulp");
var i18nCompile = require("gulp-i18n-compile");

gulp.task("i18n", function() {
  gulp.src("src/i18n/**/*.json")
    .pipe(i18nCompile("[locale].json", {localePlaceholder: "[locale]"}))
    .pipe(gulp.dest("dist/i18n"));
});
```