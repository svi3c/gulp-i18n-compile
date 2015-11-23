module.exports = (mixedTranslations) ->
  traverse = (obj, absKey = [], translations = {}) ->
    for key, value of obj
      if value? && typeof value == "object"
        traverse value, absKey.concat(key), translations
      else
        trans = translations
        for key in [key].concat absKey[0..-2]
          trans = trans[key] ?= {}
        trans[absKey[absKey.length - 1]] = value
    translations
  traverse mixedTranslations