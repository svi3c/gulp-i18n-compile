sandbox = require "sandboxed-module"

describe "i18nCompile", ->

  i18nCompile = null
  convert = null
  through = null
  gutil = null
  stream = null
  path = null

  class File
    constructor: ({isNull, isStream, @contents}) ->
      @isNull = -> !!isNull
      @isStream = -> !!isStream
    clone: ->
      new File isNull: @isNull(), isStream: @isStream, contents: @contents
    base: "basePath"

  beforeEach ->
    through = jasmine.createSpyObj "through2", ["obj"]
    gutil = jasmine.createSpyObj "gulp-util", ["PluginError"]
    stream = jasmine.createSpyObj "stream", ["push", "emit"]
    path = jasmine.createSpyObj "path", ["join"]
    convert = jasmine.createSpy "convert"
    i18nCompile = sandbox.require "../../src/i18nCompile",
      requires:
        "path": path
        "through2": through
        "gulp-util": gutil
        "./convert": convert

  describe "initialization", ->

    it "should raise an exception if no fileName is specified", ->
      expect(-> i18nCompile()).toThrow jasmine.any(gutil.PluginError)

  describe "collector", ->

    callback = null
    collector = null
    file = null

    beforeEach ->
      callback = jasmine.createSpy "callback"
      i18nCompile "out.json"
      collector = through.obj.argsForCall[0][0]

    invokeCollector = ->
      collector.call stream, file, "utf-8", callback

    it "should add the same vinyl file if it is null", ->
      file = new File isNull: true

      invokeCollector()

      expect(stream.push).toHaveBeenCalledWith file
      expect(callback).toHaveBeenCalled()

    it "should raise an error if the file is a stream", ->
      file = new File isStream: true

      invokeCollector()

      expect(stream.emit).toHaveBeenCalledWith "error", jasmine.any gutil.PluginError

    it "should process the file content if not null and not a stream", ->
      file = new File contents: JSON.stringify foo: "bar"

      invokeCollector()

      expect(convert).toHaveBeenCalledWith foo: "bar"
      expect(callback).toHaveBeenCalled()

    it "should raise an error if the content is not valid json", ->
      file = new File contents: "no json"

      invokeCollector()

      expect(stream.emit).toHaveBeenCalledWith "error", jasmine.any gutil.PluginError
      expect(stream.push).not.toHaveBeenCalled()

  describe "writer", ->

    collectorCallback = null
    writerCallback = null
    collector = null
    writer = null
    files = null
    converted =
      en:
        a: "b"
      de:
        a: "c"

    beforeEach ->
      collectorCallback = jasmine.createSpy "collectorCallback"
      writerCallback = jasmine.createSpy "writerCallback"
      convert.andReturn converted
      files = [new File contents: JSON.stringify a: b: "c"]

    init = ->
      i18nCompile.apply null, arguments
      collector = through.obj.argsForCall[0][0]
      writer = through.obj.argsForCall[0][1]

    invokeCollector = ->
      for file in files
        collector.call stream, file, "utf-8", collectorCallback

    invokeWriter = ->
      writer.call stream, writerCallback

    it "should add a new file with the combined json to the stream", ->
      init "out.json"
      invokeCollector()

      invokeWriter()

      expect(stream.push.argsForCall[0][0].contents.toString()).toEqual JSON.stringify converted

    it "should be able to create one json per locale", ->
      init "[locale].json", localePlaceholder: "[locale]"
      invokeCollector()
      path.join.andCallFake (a, b) -> b

      invokeWriter()

      outFiles = stream.push.argsForCall[0..1].map (args) -> args[0]
      contents = outFiles.map (f) -> f.contents.toString()
      paths = outFiles.map (f) -> f.path
      expect(stream.push.calls.length).toEqual 2
      expect(contents).toContain JSON.stringify a: "b"
      expect(contents).toContain JSON.stringify a: "c"
      expect(paths).toContain "en.json"
      expect(paths).toContain "de.json"

