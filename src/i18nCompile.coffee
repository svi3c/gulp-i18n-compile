through = require "through2"
convert = require "./convert"
gutil = require "gulp-util"
path = require "path"
PLUGIN_NAME = require("../package.json").name
merge = require "merge"

module.exports = (fileName, {localePlaceholder} = {}) ->

  allTranslations = {}
  nothingToWrite = false
  latestFile = null
  if !fileName
    throw new gutil.PluginError PLUGIN_NAME, "fileName of output is missing."

  collector = (file, encoding, callback) ->
    if file.isNull()
      @push file
      nothingToWrite = true
    else if file.isStream()
      @emit 'error', new gutil.PluginError PLUGIN_NAME,  'Streaming not supported.'
    else
      try
        translations = JSON.parse file.contents.toString()
      catch e
        @emit 'error', new gutil.PluginError PLUGIN_NAME, "The file #{file.path} seems not to contain valid JSON."
      fileTranslations = convert translations
      allTranslations = merge.recursive true, allTranslations, fileTranslations
      latestFile = file
    callback()


  writer = (callback) ->
    createOutFile = (fileName, jsonContent) ->
      file = latestFile.clone contents: false
      file.path = path.join latestFile.base, fileName
      file.contents = new Buffer JSON.stringify jsonContent
      file

    if localePlaceholder?
      for locale, translations of allTranslations
        @push createOutFile fileName.replace(localePlaceholder, locale), translations
    else
      @push createOutFile fileName, allTranslations
    callback()

  through.obj collector, writer