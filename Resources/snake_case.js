/**
 * Test whether a string is camel-case.
 */

var hasSpace = /\s/
var hasSeparator = /(_|-|\.|:)/
var hasCamel = /([a-z][A-Z]|[A-Z][a-z])/

/**
 * Remove any starting case from a `string`, like camel or snake, but keep
 * spaces and punctuation that may be important otherwise.
 *
 * @param {String} string
 * @return {String}
 */

function toNoCase(string) {
  if (hasSpace.test(string)) return string.toLowerCase()
  if (hasSeparator.test(string)) return (unseparate(string) || string).toLowerCase()
  if (hasCamel.test(string)) return uncamelize(string).toLowerCase()
  return string.toLowerCase()
}

var clean = toNoCase;

/**
 * Separator splitter.
 */

var separatorSplitter = /[\W_]+(.|$)/g

/**
 * Un-separate a `string`.
 *
 * @param {String} string
 * @return {String}
 */

function unseparate(string) {
  return string.replace(separatorSplitter, function (m, next) {
    return next ? ' ' + next : ''
  })
}

/**
 * Camelcase splitter.
 */

var camelSplitter = /(.)([A-Z]+)/g

/**
 * Un-camelcase a `string`.
 *
 * @param {String} string
 * @return {String}
 */

function uncamelize(string) {
  return string.replace(camelSplitter, function (m, previous, uppers) {
    return previous + ' ' + uppers.toLowerCase().split('').join(' ')
  })
}

var toSpace = function toSpaceCase(string) {
  return clean(string).replace(/[\W_]+(.|$)/g, function (matches, match) {
    return match ? ' ' + match : ''
  }).trim()
}

var snakeCase = function toSnakeCase(string) {
  return toSpace(string).replace(/\s/g, '_')
}



// Customized for this use-case
const isObject = x =>
	typeof x === 'object' &&
	x !== null &&
	!(x instanceof RegExp) &&
	!(x instanceof Error) &&
	!(x instanceof Date);

var map = function mapObj(object, fn, options, seen) {
	options = Object.assign({
		deep: false,
		target: {}
	}, options);

	seen = seen || new WeakMap();

	if (seen.has(object)) {
		return seen.get(object);
	}

	seen.set(object, options.target);

	const {target} = options;
	delete options.target;

	const mapArray = array => array.map(x => isObject(x) ? mapObj(x, fn, options, seen) : x);
	if (Array.isArray(object)) {
		return mapArray(object);
	}

	/// TODO: Use `Object.entries()` when targeting Node.js 8
	for (const key of Object.keys(object)) {
		const value = object[key];
		let [newKey, newValue] = fn(key, value, object);

		if (options.deep && isObject(newValue)) {
			newValue = Array.isArray(newValue) ?
				mapArray(newValue) :
				mapObj(newValue, fn, options, seen);
		}

		target[newKey] = newValue;
	}

	return target;
};



// SNAKECASE KEYS


var snakeCaseKeys = function (obj, options) {
  options = Object.assign({ deep: true, exclude: [] }, options)

  return map(obj, function (key, val) {
    return [
      matches(options.exclude, key) ? key : snakeCase(key),
      val
    ]
  }, options)
}

function matches (patterns, value) {
  return patterns.some(function (pattern) {
    return typeof pattern === 'string'
      ? pattern === value
      : pattern.test(value)
  })
}

function sn(val) {
  return JSON.stringify(snakeCaseKeys(JSON.parse(val)));
}
