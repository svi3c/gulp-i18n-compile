i18nCompile = require "../../src/i18nCompile"
streamify = require "stream-array"
through = require "through2"
File = require("gulp-util").File

loadFixtures = (fixtures...) ->
  contents = for name in fixtures
    new File
      base: "./fixtures"
      path: "#{name}.json"
      contents: new Buffer JSON.stringify require "./fixtures/#{name}.json"
  streamify contents

describe "i18nCompile", ->

  it "should convert a single file", ->
    loadFixtures("foo")
      .pipe(i18nCompile("out.json"))
      .pipe through.obj (file, encoding, callback) ->
        expect(JSON.parse file.contents.toString()).toEqual
          en:
            foo: "bar"
          de:
            foo: "baz"
        callback()

  it "should convert multiple files", ->
    loadFixtures("foo", "hello", "hello2")
      .pipe(i18nCompile("out.json"))
      .pipe through.obj (file, encoding, callback) ->
        expect(JSON.parse file.contents.toString()).toEqual
          en:
            foo: "bar"
            hello:
              world: "Hello world! (update)"
          de:
            foo: "baz"
            hello:
              world: "Hallo Welt!"
        callback()

  it "should provide conversion to one file per locale", () ->
    files = {}
    loadFixtures("foo")
      .pipe(i18nCompile("[locale].json", localePlaceholder: "[locale]"))
      .pipe through.obj (file, encoding, callback) ->
        files[file.path] = file
        callback()
      , (callback) ->
        expect(JSON.parse files["fixtures/en.json"].contents.toString()).toEqual
          foo: "bar"
        expect(JSON.parse files["fixtures/de.json"].contents.toString()).toEqual
          foo: "baz"
        callback()