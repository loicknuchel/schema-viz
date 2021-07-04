(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.ai.aH === region.aw.aH)
	{
		return 'on line ' + region.ai.aH;
	}
	return 'on lines ' + region.ai.aH + ' through ' + region.aw.aH;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.b4,
		impl.dz,
		impl.dn,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		aJ: func(record.aJ),
		a7: record.a7,
		aV: record.aV
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.aJ;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.a7;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.aV) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.b4,
		impl.dz,
		impl.dn,
		function(sendToApp, initialModel) {
			var view = impl.dC;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.b4,
		impl.dz,
		impl.dn,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.ah && impl.ah(sendToApp)
			var view = impl.dC;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.bm);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.dv) && (_VirtualDom_doc.title = title = doc.dv);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.cL;
	var onUrlRequest = impl.cM;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		ah: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.aY === next.aY
							&& curr.aC === next.aC
							&& curr.aT.a === next.aT.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		b4: function(flags)
		{
			return A3(impl.b4, flags, _Browser_getUrl(), key);
		},
		dC: impl.dC,
		dz: impl.dz,
		dn: impl.dn
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { bZ: 'hidden', bs: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { bZ: 'mozHidden', bs: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { bZ: 'msHidden', bs: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { bZ: 'webkitHidden', bs: 'webkitvisibilitychange' }
		: { bZ: 'hidden', bs: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		a4: _Browser_getScene(),
		be: {
			bf: _Browser_window.pageXOffset,
			bg: _Browser_window.pageYOffset,
			dD: _Browser_doc.documentElement.clientWidth,
			bX: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		dD: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		bX: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			a4: {
				dD: node.scrollWidth,
				bX: node.scrollHeight
			},
			be: {
				bf: node.scrollLeft,
				bg: node.scrollTop,
				dD: node.clientWidth,
				bX: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			a4: _Browser_getScene(),
			be: {
				bf: x,
				bg: y,
				dD: _Browser_doc.documentElement.clientWidth,
				bX: _Browser_doc.documentElement.clientHeight
			},
			bK: {
				bf: x + rect.left,
				bg: y + rect.top,
				dD: rect.width,
				bX: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.cp) { flags += 'm'; }
	if (options.br) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.bN.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.bN.b, xhr)); });
		$elm$core$Maybe$isJust(request.bd) && _Http_track(router, xhr, request.bd.a);

		try {
			xhr.open(request.ci, request.dA, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.dA));
		}

		_Http_configureRequest(xhr, request);

		request.bm.a && xhr.setRequestHeader('Content-Type', request.bm.a);
		xhr.send(request.bm.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.aB; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.du.a || 0;
	xhr.responseType = request.bN.d;
	xhr.withCredentials = request.bj;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		dA: xhr.responseURL,
		dj: xhr.status,
		dk: xhr.statusText,
		aB: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			db: event.loaded,
			df: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			cY: event.loaded,
			df: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}


function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.b) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.c),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.c);
		} else {
			var treeLen = builder.b * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.d) : builder.d;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.b);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.c) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.c);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{d: nodeList, b: (len / $elm$core$Array$branchFactor) | 0, c: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = $elm$core$Basics$identity;
var $elm$url$Url$Http = 0;
var $elm$url$Url$Https = 1;
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {ay: fragment, aC: host, aR: path, aT: port_, aY: protocol, aZ: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		0,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		1,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = $elm$core$Basics$identity;
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return 0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0;
		return A2($elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			A2($elm$core$Task$map, toMessage, task));
	});
var $elm$browser$Browser$document = _Browser_document;
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $author$project$Conf$conf = {
	bx: _List_fromArray(
		['red', 'yellow', 'green', 'blue', 'indigo', 'purple', 'pink']),
	bD: {bw: 'gray', c4: 'public'},
	b0: {bL: 'erd', bY: 'help-modal', cg: 'menu', cs: 'new-layout-modal', c6: 'schema-switch-modal', c9: 'search'},
	cd: {de: 20},
	dG: {cf: 5, ck: 0.1, dg: 0.001}
};
var $author$project$Mappers$SchemaMapper$buildRelation = F3(
	function (table, column, fk) {
		return {
			b7: fk.R,
			cZ: {ap: fk.ap, bb: fk.aj},
			dh: {ap: column.ap, bb: table.b_},
			a6: {dd: true}
		};
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $pzp1997$assoc_list$AssocList$values = function (_v0) {
	var alist = _v0;
	return A2($elm$core$List$map, $elm$core$Tuple$second, alist);
};
var $author$project$Mappers$SchemaMapper$buildTableRelations = function (table) {
	return A2(
		$elm$core$List$filterMap,
		function (col) {
			return A2(
				$elm$core$Maybe$map,
				A2($author$project$Mappers$SchemaMapper$buildRelation, table, col),
				col.bW);
		},
		$pzp1997$assoc_list$AssocList$values(table.N));
};
var $author$project$Mappers$SchemaMapper$buildRelations = function (tables) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (table, res) {
				return _Utils_ap(
					$author$project$Mappers$SchemaMapper$buildTableRelations(table),
					res);
			}),
		_List_Nil,
		tables);
};
var $pzp1997$assoc_list$AssocList$D = $elm$core$Basics$identity;
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$Basics$neq = _Utils_notEqual;
var $pzp1997$assoc_list$AssocList$remove = F2(
	function (targetKey, _v0) {
		var alist = _v0;
		return A2(
			$elm$core$List$filter,
			function (_v1) {
				var key = _v1.a;
				return !_Utils_eq(key, targetKey);
			},
			alist);
	});
var $pzp1997$assoc_list$AssocList$insert = F3(
	function (key, value, dict) {
		var _v0 = A2($pzp1997$assoc_list$AssocList$remove, key, dict);
		var alteredAlist = _v0;
		return A2(
			$elm$core$List$cons,
			_Utils_Tuple2(key, value),
			alteredAlist);
	});
var $pzp1997$assoc_list$AssocList$fromList = function (alist) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, result) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($pzp1997$assoc_list$AssocList$insert, key, value, result);
			}),
		_List_Nil,
		alist);
};
var $author$project$Libs$Std$dictFromList = F2(
	function (getKey, list) {
		return $pzp1997$assoc_list$AssocList$fromList(
			A2(
				$elm$core$List$map,
				function (item) {
					return _Utils_Tuple2(
						getKey(item),
						item);
				},
				$elm$core$List$reverse(list)));
	});
var $author$project$Mappers$SchemaMapper$buildSchema = F3(
	function (name, layouts, tables) {
		return {
			cb: layouts,
			R: name,
			c0: $author$project$Mappers$SchemaMapper$buildRelations(tables),
			dp: A2(
				$author$project$Libs$Std$dictFromList,
				function ($) {
					return $.b_;
				},
				tables)
		};
	});
var $author$project$Mappers$SchemaMapper$emptySchema = A3($author$project$Mappers$SchemaMapper$buildSchema, 'No name', _List_Nil, _List_Nil);
var $author$project$Models$Utils$Position = F2(
	function (left, top) {
		return {cc: left, dw: top};
	});
var $author$project$Models$Utils$Size = F2(
	function (width, height) {
		return {bX: height, dD: width};
	});
var $author$project$Models$initCanvas = {
	U: A2($author$project$Models$Utils$Position, 0, 0),
	df: A2($author$project$Models$Utils$Size, 0, 0),
	dG: 1
};
var $zaboco$elm_draggable$Internal$NotDragging = {$: 0};
var $zaboco$elm_draggable$Draggable$State = $elm$core$Basics$identity;
var $zaboco$elm_draggable$Draggable$init = $zaboco$elm_draggable$Internal$NotDragging;
var $author$project$Models$initState = {as: $elm$core$Maybe$Nothing, bJ: $zaboco$elm_draggable$Draggable$init, av: $elm$core$Maybe$Nothing, cr: $elm$core$Maybe$Nothing, c8: ''};
var $author$project$Models$initSwitch = {cd: false};
var $author$project$Models$initModel = {bq: $author$project$Models$initCanvas, c4: $author$project$Mappers$SchemaMapper$emptySchema, a6: $author$project$Models$initState, dl: _List_Nil, X: $author$project$Models$initSwitch};
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Ports$loadSchemas = _Platform_outgoingPort(
	'loadSchemas',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Ports$observeSizes = _Platform_outgoingPort(
	'observeSizes',
	$elm$json$Json$Encode$list($elm$json$Json$Encode$string));
var $author$project$Ports$observeSize = function (id) {
	return $author$project$Ports$observeSizes(
		_List_fromArray(
			[id]));
};
var $author$project$Ports$showModal = _Platform_outgoingPort('showModal', $elm$json$Json$Encode$string);
var $author$project$Main$init = function (_v0) {
	return _Utils_Tuple2(
		$author$project$Models$initModel,
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					$author$project$Ports$observeSize($author$project$Conf$conf.b0.bL),
					$author$project$Ports$loadSchemas(0),
					$author$project$Ports$showModal($author$project$Conf$conf.b0.c6)
				])));
};
var $author$project$Models$DragMsg = function (a) {
	return {$: 21, a: a};
};
var $author$project$Models$FileRead = function (a) {
	return {$: 5, a: a};
};
var $author$project$Models$SchemasReceived = function (a) {
	return {$: 8, a: a};
};
var $author$project$Models$SizesChanged = function (a) {
	return {$: 15, a: a};
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $mpizenberg$elm_file$FileValue$File = F5(
	function (value, name, mime, size, lastModified) {
		return {ca: lastModified, cj: mime, R: name, df: size, dB: value};
	});
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$map5 = _Json_map5;
var $elm$time$Time$Posix = $elm$core$Basics$identity;
var $elm$time$Time$millisToPosix = $elm$core$Basics$identity;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $mpizenberg$elm_file$FileValue$decoder = A6(
	$elm$json$Json$Decode$map5,
	$mpizenberg$elm_file$FileValue$File,
	$elm$json$Json$Decode$value,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'type', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'size', $elm$json$Json$Decode$int),
	A2(
		$elm$json$Json$Decode$map,
		$elm$time$Time$millisToPosix,
		A2($elm$json$Json$Decode$field, 'lastModified', $elm$json$Json$Decode$int)));
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $author$project$Ports$textFileRead = _Platform_incomingPort(
	'textFileRead',
	A2(
		$elm$json$Json$Decode$andThen,
		function (_v0) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (_v1) {
					return $elm$json$Json$Decode$succeed(
						_Utils_Tuple2(_v0, _v1));
				},
				A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$value)));
var $elm$core$Result$withDefault = F2(
	function (def, result) {
		if (!result.$) {
			var a = result.a;
			return a;
		} else {
			return def;
		}
	});
var $author$project$Ports$fileRead = function (callback) {
	return $author$project$Ports$textFileRead(
		function (_v0) {
			var value = _v0.a;
			var content = _v0.b;
			return callback(
				_Utils_Tuple2(
					A2(
						$elm$core$Result$withDefault,
						{
							ca: $elm$time$Time$millisToPosix(0),
							cj: '',
							R: '',
							df: 0,
							dB: $elm$json$Json$Encode$null
						},
						A2($elm$json$Json$Decode$decodeValue, $mpizenberg$elm_file$FileValue$decoder, value)),
					content));
		});
};
var $author$project$Models$Schema$Layout = F3(
	function (name, canvas, tables) {
		return {bq: canvas, R: name, dp: tables};
	});
var $author$project$Models$Schema$CanvasProps = F2(
	function (zoom, position) {
		return {U: position, dG: zoom};
	});
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $author$project$JsonFormats$SchemaFormat$decodePosition = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Models$Utils$Position,
	A2($elm$json$Json$Decode$field, 'left', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'top', $elm$json$Json$Decode$float));
var $author$project$JsonFormats$SchemaFormat$decodeCanvasProps = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Models$Schema$CanvasProps,
	A2($elm$json$Json$Decode$field, 'zoom', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'position', $author$project$JsonFormats$SchemaFormat$decodePosition));
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var $elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		$elm$json$Json$Decode$map,
		$elm$core$Dict$fromList,
		$elm$json$Json$Decode$keyValuePairs(decoder));
};
var $author$project$JsonFormats$SchemaFormat$decodeDict = F2(
	function (buildKey, decoder) {
		return A2(
			$elm$json$Json$Decode$map,
			function (dict) {
				return $pzp1997$assoc_list$AssocList$fromList(
					A2(
						$elm$core$List$map,
						function (_v0) {
							var k = _v0.a;
							var a = _v0.b;
							return _Utils_Tuple2(
								buildKey(k),
								a);
						},
						$elm$core$Dict$toList(dict)));
			},
			$elm$json$Json$Decode$dict(decoder));
	});
var $author$project$Models$Schema$ColumnName = $elm$core$Basics$identity;
var $author$project$Models$Schema$TableProps = F3(
	function (position, color, columns) {
		return {bw: color, N: columns, U: position};
	});
var $author$project$Models$Schema$ColumnProps = function (position) {
	return {U: position};
};
var $author$project$JsonFormats$SchemaFormat$decodeColumnProps = A2(
	$elm$json$Json$Decode$map,
	$author$project$Models$Schema$ColumnProps,
	A2($elm$json$Json$Decode$field, 'position', $elm$json$Json$Decode$int));
var $elm$json$Json$Decode$map3 = _Json_map3;
var $author$project$JsonFormats$SchemaFormat$decodeTableProps = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Models$Schema$TableProps,
	A2($elm$json$Json$Decode$field, 'position', $author$project$JsonFormats$SchemaFormat$decodePosition),
	A2($elm$json$Json$Decode$field, 'color', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		A2($author$project$JsonFormats$SchemaFormat$decodeDict, $elm$core$Basics$identity, $author$project$JsonFormats$SchemaFormat$decodeColumnProps)));
var $author$project$Models$Schema$SchemaName = $elm$core$Basics$identity;
var $author$project$Models$Schema$TableId = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Models$Schema$TableName = $elm$core$Basics$identity;
var $author$project$Views$Helpers$parseTableId = function (id) {
	var _v0 = A2($elm$core$String$split, '.', id);
	if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
		var schema = _v0.a;
		var _v1 = _v0.b;
		var table = _v1.a;
		return A2($author$project$Models$Schema$TableId, schema, table);
	} else {
		return A2($author$project$Models$Schema$TableId, $author$project$Conf$conf.bD.c4, id);
	}
};
var $author$project$JsonFormats$SchemaFormat$decodeLayout = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Models$Schema$Layout,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'canvas', $author$project$JsonFormats$SchemaFormat$decodeCanvasProps),
	A2(
		$elm$json$Json$Decode$field,
		'tables',
		A2($author$project$JsonFormats$SchemaFormat$decodeDict, $author$project$Views$Helpers$parseTableId, $author$project$JsonFormats$SchemaFormat$decodeTableProps)));
var $author$project$Models$Schema$Table = F9(
	function (id, schema, table, columns, primaryKey, uniques, indexes, comment, state) {
		return {N: columns, aq: comment, b_: id, b3: indexes, cX: primaryKey, c4: schema, a6: state, bb: table, dy: uniques};
	});
var $author$project$Models$Schema$TableComment = $elm$core$Basics$identity;
var $author$project$Models$Schema$Column = F7(
	function (index, column, kind, nullable, foreignKey, comment, state) {
		return {ap: column, aq: comment, bW: foreignKey, b2: index, b9: kind, cA: nullable, a6: state};
	});
var $author$project$Models$Schema$ColumnComment = $elm$core$Basics$identity;
var $author$project$Models$Schema$ColumnIndex = $elm$core$Basics$identity;
var $author$project$Models$Schema$ColumnType = $elm$core$Basics$identity;
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $author$project$JsonFormats$SchemaFormat$decodeColumnName = A2($elm$json$Json$Decode$map, $elm$core$Basics$identity, $elm$json$Json$Decode$string);
var $author$project$Models$Schema$ColumnState = function (order) {
	return {cP: order};
};
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$maybe = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder),
				$elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing)
			]));
};
var $author$project$JsonFormats$SchemaFormat$decodeColumnState = A2(
	$elm$json$Json$Decode$map,
	$author$project$Models$Schema$ColumnState,
	A2(
		$elm$json$Json$Decode$field,
		'order',
		$elm$json$Json$Decode$maybe($elm$json$Json$Decode$int)));
var $author$project$Models$Schema$ForeignKey = F5(
	function (tableId, schema, table, column, name) {
		return {ap: column, R: name, c4: schema, bb: table, aj: tableId};
	});
var $author$project$Models$Schema$ForeignKeyName = $elm$core$Basics$identity;
var $author$project$JsonFormats$SchemaFormat$decodeForeignKey = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Models$Schema$ForeignKey,
	A3(
		$elm$json$Json$Decode$map2,
		F2(
			function (schema, table) {
				return A2($author$project$Models$Schema$TableId, schema, table);
			}),
		A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string)),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string)),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'column', $author$project$JsonFormats$SchemaFormat$decodeColumnName),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string)));
var $elm$json$Json$Decode$map7 = _Json_map7;
var $author$project$JsonFormats$SchemaFormat$decodeColumn = A8(
	$elm$json$Json$Decode$map7,
	$author$project$Models$Schema$Column,
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'index', $elm$json$Json$Decode$int)),
	A2($elm$json$Json$Decode$field, 'column', $author$project$JsonFormats$SchemaFormat$decodeColumnName),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'kind', $elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'nullable', $elm$json$Json$Decode$bool),
	A2(
		$elm$json$Json$Decode$field,
		'foreignKey',
		$elm$json$Json$Decode$maybe($author$project$JsonFormats$SchemaFormat$decodeForeignKey)),
	A2(
		$elm$json$Json$Decode$field,
		'comment',
		$elm$json$Json$Decode$maybe(
			A2($elm$json$Json$Decode$map, $elm$core$Basics$identity, $elm$json$Json$Decode$string))),
	A2($elm$json$Json$Decode$field, 'state', $author$project$JsonFormats$SchemaFormat$decodeColumnState));
var $author$project$Models$Schema$Index = F3(
	function (columns, definition, name) {
		return {N: columns, bE: definition, R: name};
	});
var $author$project$Models$Schema$IndexName = $elm$core$Basics$identity;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $author$project$JsonFormats$SchemaFormat$decodeIndex = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Models$Schema$Index,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeColumnName)),
	A2($elm$json$Json$Decode$field, 'definition', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string)));
var $elm$json$Json$Decode$map6 = _Json_map6;
var $author$project$JsonFormats$SchemaFormat$decodeMap9 = function (callback) {
	return function (da) {
		return function (db) {
			return function (dc) {
				return function (dd) {
					return function (de) {
						return function (df) {
							return function (dg) {
								return function (dh) {
									return function (di) {
										return A3(
											$elm$json$Json$Decode$map2,
											F2(
												function (_v0, _v3) {
													var _v1 = _v0.a;
													var a = _v1.a;
													var b = _v1.b;
													var c = _v1.c;
													var _v2 = _v0.b;
													var d = _v2.a;
													var e = _v2.b;
													var f = _v2.c;
													var g = _v3.a;
													var h = _v3.b;
													var i = _v3.c;
													return A9(callback, a, b, c, d, e, f, g, h, i);
												}),
											A7(
												$elm$json$Json$Decode$map6,
												F6(
													function (a, b, c, d, e, f) {
														return _Utils_Tuple2(
															_Utils_Tuple3(a, b, c),
															_Utils_Tuple3(d, e, f));
													}),
												da,
												db,
												dc,
												dd,
												de,
												df),
											A4(
												$elm$json$Json$Decode$map3,
												F3(
													function (g, h, i) {
														return _Utils_Tuple3(g, h, i);
													}),
												dg,
												dh,
												di));
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Models$Schema$PrimaryKey = F2(
	function (columns, name) {
		return {N: columns, R: name};
	});
var $author$project$Models$Schema$PrimaryKeyName = $elm$core$Basics$identity;
var $author$project$JsonFormats$SchemaFormat$decodePrimaryKey = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Models$Schema$PrimaryKey,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeColumnName)),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string)));
var $author$project$Models$Schema$TableState = F5(
	function (status, size, position, color, selected) {
		return {bw: color, U: position, da: selected, df: size, di: status};
	});
var $author$project$JsonFormats$SchemaFormat$decodeSize = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Models$Utils$Size,
	A2($elm$json$Json$Decode$field, 'width', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'height', $elm$json$Json$Decode$float));
var $author$project$Models$Schema$Hidden = 2;
var $author$project$Models$Schema$Initializing = 1;
var $author$project$Models$Schema$Shown = 3;
var $author$project$Models$Schema$Uninitialized = 0;
var $elm$json$Json$Decode$fail = _Json_fail;
var $author$project$JsonFormats$SchemaFormat$decodeTableStatus = A2(
	$elm$json$Json$Decode$andThen,
	function (value) {
		switch (value) {
			case 'Uninitialized':
				return $elm$json$Json$Decode$succeed(0);
			case 'Initializing':
				return $elm$json$Json$Decode$succeed(1);
			case 'Hidden':
				return $elm$json$Json$Decode$succeed(2);
			case 'Shown':
				return $elm$json$Json$Decode$succeed(3);
			default:
				var other = value;
				return $elm$json$Json$Decode$fail('invalid TableStatus \'' + (other + '\''));
		}
	},
	$elm$json$Json$Decode$string);
var $author$project$JsonFormats$SchemaFormat$decodeTableState = A6(
	$elm$json$Json$Decode$map5,
	$author$project$Models$Schema$TableState,
	A2($elm$json$Json$Decode$field, 'status', $author$project$JsonFormats$SchemaFormat$decodeTableStatus),
	A2($elm$json$Json$Decode$field, 'size', $author$project$JsonFormats$SchemaFormat$decodeSize),
	A2($elm$json$Json$Decode$field, 'position', $author$project$JsonFormats$SchemaFormat$decodePosition),
	A2($elm$json$Json$Decode$field, 'color', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'selected', $elm$json$Json$Decode$bool));
var $author$project$Models$Schema$Unique = F2(
	function (columns, name) {
		return {N: columns, R: name};
	});
var $author$project$Models$Schema$UniqueName = $elm$core$Basics$identity;
var $author$project$JsonFormats$SchemaFormat$decodeUnique = A3(
	$elm$json$Json$Decode$map2,
	$author$project$Models$Schema$Unique,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeColumnName)),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string)));
var $author$project$JsonFormats$SchemaFormat$decodeTable = $author$project$JsonFormats$SchemaFormat$decodeMap9($author$project$Models$Schema$Table)(
	A3(
		$elm$json$Json$Decode$map2,
		F2(
			function (schema, table) {
				return A2($author$project$Models$Schema$TableId, schema, table);
			}),
		A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string)))(
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string)))(
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$identity,
		A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string)))(
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		A2(
			$elm$json$Json$Decode$map,
			$author$project$Libs$Std$dictFromList(
				function ($) {
					return $.ap;
				}),
			$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeColumn))))(
	A2(
		$elm$json$Json$Decode$field,
		'primaryKey',
		$elm$json$Json$Decode$maybe($author$project$JsonFormats$SchemaFormat$decodePrimaryKey)))(
	A2(
		$elm$json$Json$Decode$field,
		'uniques',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeUnique)))(
	A2(
		$elm$json$Json$Decode$field,
		'indexes',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeIndex)))(
	A2(
		$elm$json$Json$Decode$field,
		'comment',
		$elm$json$Json$Decode$maybe(
			A2($elm$json$Json$Decode$map, $elm$core$Basics$identity, $elm$json$Json$Decode$string))))(
	A2($elm$json$Json$Decode$field, 'state', $author$project$JsonFormats$SchemaFormat$decodeTableState));
var $author$project$JsonFormats$SchemaFormat$decodeSchema = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Mappers$SchemaMapper$buildSchema,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'layouts',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeLayout)),
	A2(
		$elm$json$Json$Decode$field,
		'tables',
		$elm$json$Json$Decode$list($author$project$JsonFormats$SchemaFormat$decodeTable)));
var $author$project$Libs$Std$listResultCollect = function (list) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (r, _v0) {
				var errs = _v0.a;
				var res = _v0.b;
				if (!r.$) {
					var a = r.a;
					return _Utils_Tuple2(
						errs,
						A2($elm$core$List$cons, a, res));
				} else {
					var e = r.a;
					return _Utils_Tuple2(
						A2($elm$core$List$cons, e, errs),
						res);
				}
			}),
		_Utils_Tuple2(_List_Nil, _List_Nil),
		list);
};
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (!result.$) {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $author$project$Ports$schemasReceivedPort = _Platform_incomingPort(
	'schemasReceivedPort',
	$elm$json$Json$Decode$list(
		A2(
			$elm$json$Json$Decode$andThen,
			function (_v0) {
				return A2(
					$elm$json$Json$Decode$andThen,
					function (_v1) {
						return $elm$json$Json$Decode$succeed(
							_Utils_Tuple2(_v0, _v1));
					},
					A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$value));
			},
			A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string))));
var $author$project$Ports$schemasReceived = function (callback) {
	return $author$project$Ports$schemasReceivedPort(
		function (list) {
			return callback(
				$author$project$Libs$Std$listResultCollect(
					A2(
						$elm$core$List$map,
						function (_v0) {
							var k = _v0.a;
							var v = _v0.b;
							return A2(
								$elm$core$Result$mapError,
								function (e) {
									return _Utils_Tuple2(k, e);
								},
								A2($elm$json$Json$Decode$decodeValue, $author$project$JsonFormats$SchemaFormat$decodeSchema, v));
						},
						list)));
		});
};
var $author$project$Ports$sizesReceiver = _Platform_incomingPort(
	'sizesReceiver',
	$elm$json$Json$Decode$list(
		A2(
			$elm$json$Json$Decode$andThen,
			function (size) {
				return A2(
					$elm$json$Json$Decode$andThen,
					function (id) {
						return $elm$json$Json$Decode$succeed(
							{b_: id, df: size});
					},
					A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string));
			},
			A2(
				$elm$json$Json$Decode$field,
				'size',
				A2(
					$elm$json$Json$Decode$andThen,
					function (width) {
						return A2(
							$elm$json$Json$Decode$andThen,
							function (height) {
								return $elm$json$Json$Decode$succeed(
									{bX: height, dD: width});
							},
							A2($elm$json$Json$Decode$field, 'height', $elm$json$Json$Decode$float));
					},
					A2($elm$json$Json$Decode$field, 'width', $elm$json$Json$Decode$float))))));
var $zaboco$elm_draggable$Internal$DragAt = function (a) {
	return {$: 1, a: a};
};
var $zaboco$elm_draggable$Draggable$Msg = $elm$core$Basics$identity;
var $zaboco$elm_draggable$Internal$StopDragging = {$: 2};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Platform$Sub$map = _Platform_map;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $elm$browser$Browser$Events$Document = 0;
var $elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {aS: pids, ba: subs};
	});
var $elm$browser$Browser$Events$init = $elm$core$Task$succeed(
	A2($elm$browser$Browser$Events$State, _List_Nil, $elm$core$Dict$empty));
var $elm$browser$Browser$Events$nodeToKey = function (node) {
	if (!node) {
		return 'd_';
	} else {
		return 'w_';
	}
};
var $elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			$elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {ax: event, b7: key};
	});
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$browser$Browser$Events$spawn = F3(
	function (router, key, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var actualNode = function () {
			if (!node) {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			$elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						$elm$core$Platform$sendToSelf,
						router,
						A2($elm$browser$Browser$Events$Event, key, event));
				}));
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _v6) {
				var deads = _v6.a;
				var lives = _v6.b;
				var news = _v6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						$elm$core$List$cons,
						A3($elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_v4, pid, _v5) {
				var deads = _v5.a;
				var lives = _v5.b;
				var news = _v5.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _v2, _v3) {
				var deads = _v3.a;
				var lives = _v3.b;
				var news = _v3.c;
				return _Utils_Tuple3(
					deads,
					A3($elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2($elm$core$List$map, $elm$browser$Browser$Events$addKey, subs);
		var _v0 = A6(
			$elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.aS,
			$elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, $elm$core$Dict$empty, _List_Nil));
		var deadPids = _v0.a;
		var livePids = _v0.b;
		var makeNewPids = _v0.c;
		return A2(
			$elm$core$Task$andThen,
			function (pids) {
				return $elm$core$Task$succeed(
					A2(
						$elm$browser$Browser$Events$State,
						newSubs,
						A2(
							$elm$core$Dict$union,
							livePids,
							$elm$core$Dict$fromList(pids))));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$sequence(makeNewPids);
				},
				$elm$core$Task$sequence(
					A2($elm$core$List$map, $elm$core$Process$kill, deadPids))));
	});
var $elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _v0, state) {
		var key = _v0.b7;
		var event = _v0.ax;
		var toMessage = function (_v2) {
			var subKey = _v2.a;
			var _v3 = _v2.b;
			var node = _v3.a;
			var name = _v3.b;
			var decoder = _v3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : $elm$core$Maybe$Nothing;
		};
		var messages = A2($elm$core$List$filterMap, toMessage, state.ba);
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Platform$sendToApp(router),
					messages)));
	});
var $elm$browser$Browser$Events$subMap = F2(
	function (func, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var decoder = _v0.c;
		return A3(
			$elm$browser$Browser$Events$MySub,
			node,
			name,
			A2($elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager($elm$browser$Browser$Events$init, $elm$browser$Browser$Events$onEffects, $elm$browser$Browser$Events$onSelfMsg, 0, $elm$browser$Browser$Events$subMap);
var $elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var $elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return $elm$browser$Browser$Events$subscription(
			A3($elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var $elm$browser$Browser$Events$onMouseMove = A2($elm$browser$Browser$Events$on, 0, 'mousemove');
var $elm$browser$Browser$Events$onMouseUp = A2($elm$browser$Browser$Events$on, 0, 'mouseup');
var $zaboco$elm_draggable$Internal$Position = F2(
	function (x, y) {
		return {bf: x, bg: y};
	});
var $elm$core$Basics$truncate = _Basics_truncate;
var $zaboco$elm_draggable$Draggable$positionDecoder = A3(
	$elm$json$Json$Decode$map2,
	$zaboco$elm_draggable$Internal$Position,
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$truncate,
		A2($elm$json$Json$Decode$field, 'pageX', $elm$json$Json$Decode$float)),
	A2(
		$elm$json$Json$Decode$map,
		$elm$core$Basics$truncate,
		A2($elm$json$Json$Decode$field, 'pageY', $elm$json$Json$Decode$float)));
var $zaboco$elm_draggable$Draggable$subscriptions = F2(
	function (envelope, _v0) {
		var drag = _v0;
		if (!drag.$) {
			return $elm$core$Platform$Sub$none;
		} else {
			return A2(
				$elm$core$Platform$Sub$map,
				A2($elm$core$Basics$composeL, envelope, $elm$core$Basics$identity),
				$elm$core$Platform$Sub$batch(
					_List_fromArray(
						[
							$elm$browser$Browser$Events$onMouseMove(
							A2($elm$json$Json$Decode$map, $zaboco$elm_draggable$Internal$DragAt, $zaboco$elm_draggable$Draggable$positionDecoder)),
							$elm$browser$Browser$Events$onMouseUp(
							$elm$json$Json$Decode$succeed($zaboco$elm_draggable$Internal$StopDragging))
						])));
		}
	});
var $author$project$Main$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A2($zaboco$elm_draggable$Draggable$subscriptions, $author$project$Models$DragMsg, model.a6.bJ),
				$author$project$Ports$sizesReceiver($author$project$Models$SizesChanged),
				$author$project$Ports$schemasReceived($author$project$Models$SchemasReceived),
				$author$project$Ports$fileRead($author$project$Models$FileRead)
			]));
};
var $author$project$Ports$activateTooltipsAndPopovers = _Platform_outgoingPort(
	'activateTooltipsAndPopovers',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Libs$Std$cond = F3(
	function (predicate, _true, _false) {
		return predicate ? _true(0) : _false(0);
	});
var $elm$json$Json$Encode$float = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $author$project$JsonFormats$SchemaFormat$encodePosition = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'left',
				$elm$json$Json$Encode$float(value.cc)),
				_Utils_Tuple2(
				'top',
				$elm$json$Json$Encode$float(value.dw))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeCanvasProps = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'zoom',
				$elm$json$Json$Encode$float(value.dG)),
				_Utils_Tuple2(
				'position',
				$author$project$JsonFormats$SchemaFormat$encodePosition(value.U))
			]));
};
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(0),
				dictionary));
	});
var $pzp1997$assoc_list$AssocList$toList = function (_v0) {
	var alist = _v0;
	return alist;
};
var $author$project$JsonFormats$SchemaFormat$encodeDict = F3(
	function (encodeKey, encodeValue, dict) {
		return A3(
			$elm$json$Json$Encode$dict,
			$elm$core$Basics$identity,
			$elm$core$Basics$identity,
			$elm$core$Dict$fromList(
				A2(
					$elm$core$List$map,
					function (_v0) {
						var k = _v0.a;
						var a = _v0.b;
						return _Utils_Tuple2(
							encodeKey(k),
							encodeValue(a));
					},
					$pzp1997$assoc_list$AssocList$toList(dict))));
	});
var $elm$json$Json$Encode$int = _Json_wrap;
var $author$project$JsonFormats$SchemaFormat$encodeColumnProps = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'position',
				$elm$json$Json$Encode$int(value.U))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeTableProps = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'position',
				$author$project$JsonFormats$SchemaFormat$encodePosition(value.U)),
				_Utils_Tuple2(
				'color',
				$elm$json$Json$Encode$string(value.bw)),
				_Utils_Tuple2(
				'columns',
				A3(
					$author$project$JsonFormats$SchemaFormat$encodeDict,
					function (_v0) {
						var v = _v0;
						return v;
					},
					$author$project$JsonFormats$SchemaFormat$encodeColumnProps,
					value.N))
			]));
};
var $author$project$Views$Helpers$formatTableName = F2(
	function (_v0, _v1) {
		var table = _v0;
		var schema = _v1;
		return _Utils_eq(schema, $author$project$Conf$conf.bD.c4) ? table : (schema + ('.' + table));
	});
var $author$project$Views$Helpers$formatTableId = function (_v0) {
	var schema = _v0.a;
	var table = _v0.b;
	return A2($author$project$Views$Helpers$formatTableName, table, schema);
};
var $author$project$JsonFormats$SchemaFormat$encodeLayout = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(value.R)),
				_Utils_Tuple2(
				'canvas',
				$author$project$JsonFormats$SchemaFormat$encodeCanvasProps(value.bq)),
				_Utils_Tuple2(
				'tables',
				A3($author$project$JsonFormats$SchemaFormat$encodeDict, $author$project$Views$Helpers$formatTableId, $author$project$JsonFormats$SchemaFormat$encodeTableProps, value.dp))
			]));
};
var $elm$json$Json$Encode$bool = _Json_wrap;
var $author$project$JsonFormats$SchemaFormat$encodeColumnName = function (_v0) {
	var value = _v0;
	return $elm$json$Json$Encode$string(value);
};
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$JsonFormats$SchemaFormat$encodeMaybe = F2(
	function (encoder, maybe) {
		return A2(
			$elm$core$Maybe$withDefault,
			$elm$json$Json$Encode$null,
			A2($elm$core$Maybe$map, encoder, maybe));
	});
var $author$project$JsonFormats$SchemaFormat$encodeColumnState = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'order',
				A2($author$project$JsonFormats$SchemaFormat$encodeMaybe, $elm$json$Json$Encode$int, value.cP))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeForeignKey = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'schema',
				$elm$json$Json$Encode$string(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.c4))),
				_Utils_Tuple2(
				'table',
				$elm$json$Json$Encode$string(
					function (_v1) {
						var v = _v1;
						return v;
					}(value.bb))),
				_Utils_Tuple2(
				'column',
				$author$project$JsonFormats$SchemaFormat$encodeColumnName(value.ap)),
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(
					function (_v2) {
						var v = _v2;
						return v;
					}(value.R)))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeColumn = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'index',
				$elm$json$Json$Encode$int(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.b2))),
				_Utils_Tuple2(
				'column',
				$author$project$JsonFormats$SchemaFormat$encodeColumnName(value.ap)),
				_Utils_Tuple2(
				'kind',
				$elm$json$Json$Encode$string(
					function (_v1) {
						var v = _v1;
						return v;
					}(value.b9))),
				_Utils_Tuple2(
				'nullable',
				$elm$json$Json$Encode$bool(value.cA)),
				_Utils_Tuple2(
				'foreignKey',
				A2($author$project$JsonFormats$SchemaFormat$encodeMaybe, $author$project$JsonFormats$SchemaFormat$encodeForeignKey, value.bW)),
				_Utils_Tuple2(
				'comment',
				A2(
					$author$project$JsonFormats$SchemaFormat$encodeMaybe,
					function (_v2) {
						var v = _v2;
						return $elm$json$Json$Encode$string(v);
					},
					value.aq)),
				_Utils_Tuple2(
				'state',
				$author$project$JsonFormats$SchemaFormat$encodeColumnState(value.a6))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeIndex = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'columns',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeColumnName, value.N)),
				_Utils_Tuple2(
				'definition',
				$elm$json$Json$Encode$string(value.bE)),
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.R)))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodePrimaryKey = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'columns',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeColumnName, value.N)),
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.R)))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeSize = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'width',
				$elm$json$Json$Encode$float(value.dD)),
				_Utils_Tuple2(
				'height',
				$elm$json$Json$Encode$float(value.bX))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeTableStatus = function (value) {
	return $elm$json$Json$Encode$string(
		function () {
			switch (value) {
				case 0:
					return 'Uninitialized';
				case 1:
					return 'Initializing';
				case 2:
					return 'Hidden';
				default:
					return 'Shown';
			}
		}());
};
var $author$project$JsonFormats$SchemaFormat$encodeTableState = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'status',
				$author$project$JsonFormats$SchemaFormat$encodeTableStatus(value.di)),
				_Utils_Tuple2(
				'size',
				$author$project$JsonFormats$SchemaFormat$encodeSize(value.df)),
				_Utils_Tuple2(
				'position',
				$author$project$JsonFormats$SchemaFormat$encodePosition(value.U)),
				_Utils_Tuple2(
				'color',
				$elm$json$Json$Encode$string(value.bw)),
				_Utils_Tuple2(
				'selected',
				$elm$json$Json$Encode$bool(value.da))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeUnique = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'columns',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeColumnName, value.N)),
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.R)))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeTable = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'schema',
				$elm$json$Json$Encode$string(
					function (_v0) {
						var v = _v0;
						return v;
					}(value.c4))),
				_Utils_Tuple2(
				'table',
				$elm$json$Json$Encode$string(
					function (_v1) {
						var v = _v1;
						return v;
					}(value.bb))),
				_Utils_Tuple2(
				'columns',
				A2(
					$elm$json$Json$Encode$list,
					$author$project$JsonFormats$SchemaFormat$encodeColumn,
					$pzp1997$assoc_list$AssocList$values(value.N))),
				_Utils_Tuple2(
				'primaryKey',
				A2($author$project$JsonFormats$SchemaFormat$encodeMaybe, $author$project$JsonFormats$SchemaFormat$encodePrimaryKey, value.cX)),
				_Utils_Tuple2(
				'uniques',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeUnique, value.dy)),
				_Utils_Tuple2(
				'indexes',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeIndex, value.b3)),
				_Utils_Tuple2(
				'comment',
				A2(
					$author$project$JsonFormats$SchemaFormat$encodeMaybe,
					function (_v2) {
						var v = _v2;
						return $elm$json$Json$Encode$string(v);
					},
					value.aq)),
				_Utils_Tuple2(
				'state',
				$author$project$JsonFormats$SchemaFormat$encodeTableState(value.a6))
			]));
};
var $author$project$JsonFormats$SchemaFormat$encodeSchema = function (value) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(value.R)),
				_Utils_Tuple2(
				'layouts',
				A2($elm$json$Json$Encode$list, $author$project$JsonFormats$SchemaFormat$encodeLayout, value.cb)),
				_Utils_Tuple2(
				'tables',
				A2(
					$elm$json$Json$Encode$list,
					$author$project$JsonFormats$SchemaFormat$encodeTable,
					$pzp1997$assoc_list$AssocList$values(value.dp)))
			]));
};
var $author$project$Ports$saveSchemaPort = _Platform_outgoingPort('saveSchemaPort', $elm$core$Basics$identity);
var $author$project$Ports$saveSchema = function (schema) {
	return $author$project$Ports$saveSchemaPort(
		$author$project$JsonFormats$SchemaFormat$encodeSchema(schema));
};
var $author$project$Libs$Std$setSchema = F2(
	function (transform, item) {
		return _Utils_update(
			item,
			{
				c4: transform(item.c4)
			});
	});
var $author$project$Libs$Std$setState = F2(
	function (transform, item) {
		return _Utils_update(
			item,
			{
				a6: transform(item.a6)
			});
	});
var $author$project$Update$columnToLayout = function (column) {
	return A2(
		$elm$core$Maybe$map,
		function (order) {
			return _Utils_Tuple2(
				column.ap,
				{U: order});
		},
		column.a6.cP);
};
var $author$project$Update$tableToLayout = function (table) {
	return _Utils_Tuple2(
		table.b_,
		{
			bw: table.a6.bw,
			N: $pzp1997$assoc_list$AssocList$fromList(
				A2(
					$elm$core$List$filterMap,
					$author$project$Update$columnToLayout,
					$pzp1997$assoc_list$AssocList$values(table.N))),
			U: table.a6.U
		});
};
var $author$project$Update$toLayout = F2(
	function (name, model) {
		return {
			bq: {U: model.bq.U, dG: model.bq.dG},
			R: name,
			dp: $pzp1997$assoc_list$AssocList$fromList(
				A2(
					$elm$core$List$map,
					$author$project$Update$tableToLayout,
					A2(
						$elm$core$List$filter,
						function (t) {
							return t.a6.di === 3;
						},
						$pzp1997$assoc_list$AssocList$values(model.c4.dp))))
		};
	});
var $author$project$Update$createLayout = F2(
	function (name, model) {
		var newModel = A2(
			$author$project$Libs$Std$setSchema,
			function (s) {
				return _Utils_update(
					s,
					{
						cb: A2(
							$elm$core$List$cons,
							A2($author$project$Update$toLayout, name, model),
							s.cb)
					});
			},
			A2(
				$author$project$Libs$Std$setState,
				function (s) {
					return _Utils_update(
						s,
						{
							as: $elm$core$Maybe$Just(name),
							cr: $elm$core$Maybe$Nothing
						});
				},
				model));
		return _Utils_Tuple2(
			newModel,
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						$author$project$Ports$saveSchema(newModel.c4),
						$author$project$Ports$activateTooltipsAndPopovers(0)
					])));
	});
var $author$project$Mappers$SchemaMapper$tableIdFromJsonForeignKey = function (fk) {
	return A2($author$project$Models$Schema$TableId, fk.c4, fk.bb);
};
var $author$project$Mappers$SchemaMapper$buildJsonForeignKey = function (fk) {
	return {
		ap: fk.ap,
		R: fk.R,
		c4: fk.c4,
		bb: fk.bb,
		aj: $author$project$Mappers$SchemaMapper$tableIdFromJsonForeignKey(fk)
	};
};
var $author$project$Mappers$SchemaMapper$initColumnState = function (index) {
	return {
		cP: $elm$core$Maybe$Just(index)
	};
};
var $author$project$Mappers$SchemaMapper$buildJsonColumn = F2(
	function (index, column) {
		return {
			ap: column.ap,
			aq: A2($elm$core$Maybe$map, $elm$core$Basics$identity, column.aq),
			bW: A2($elm$core$Maybe$map, $author$project$Mappers$SchemaMapper$buildJsonForeignKey, column.c_),
			b2: index,
			b9: column.b9,
			cA: column.cA,
			a6: $author$project$Mappers$SchemaMapper$initColumnState(index)
		};
	});
var $author$project$Mappers$SchemaMapper$buildJsonIndex = function (index) {
	return {
		N: A2($elm$core$List$map, $elm$core$Basics$identity, index.N),
		bE: index.bE,
		R: index.R
	};
};
var $author$project$Mappers$SchemaMapper$buildJsonPrimaryKey = function (pk) {
	return {
		N: A2($elm$core$List$map, $elm$core$Basics$identity, pk.N),
		R: pk.R
	};
};
var $author$project$Mappers$SchemaMapper$buildJsonUnique = function (unique) {
	return {
		N: A2($elm$core$List$map, $elm$core$Basics$identity, unique.N),
		R: unique.R
	};
};
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $author$project$Libs$Std$listGet = F2(
	function (index, list) {
		return $elm$core$List$head(
			A2($elm$core$List$drop, index, list));
	});
var $elm$core$Basics$modBy = _Basics_modBy;
var $elm$core$String$foldl = _String_foldl;
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $author$project$Libs$Std$updateHash = F2(
	function (_char, hashCode) {
		return ((5 + hashCode) + $elm$core$Char$toCode(_char)) << hashCode;
	});
var $author$project$Libs$Std$stringHashCode = function (input) {
	return A3($elm$core$String$foldl, $author$project$Libs$Std$updateHash, 5381, input);
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $author$project$Libs$Std$stringWordSplit = function (input) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (sep, words) {
				return A2(
					$elm$core$List$concatMap,
					function (word) {
						return A2($elm$core$String$split, sep, word);
					},
					words);
			}),
		_List_fromArray(
			[input]),
		_List_fromArray(
			['_', '-', ' ']));
};
var $author$project$Mappers$SchemaMapper$computeColor = function (_v0) {
	var table = _v0.b;
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Conf$conf.bD.bw,
		A2(
			$elm$core$Maybe$andThen,
			function (index) {
				return A2($author$project$Libs$Std$listGet, index, $author$project$Conf$conf.bx);
			},
			A2(
				$elm$core$Maybe$map,
				$elm$core$Basics$modBy(
					$elm$core$List$length($author$project$Conf$conf.bx)),
				A2(
					$elm$core$Maybe$map,
					$author$project$Libs$Std$stringHashCode,
					$elm$core$List$head(
						$author$project$Libs$Std$stringWordSplit(table))))));
};
var $author$project$Mappers$SchemaMapper$initTableState = function (id) {
	return {
		bw: $author$project$Mappers$SchemaMapper$computeColor(id),
		U: A2($author$project$Models$Utils$Position, 0, 0),
		da: false,
		df: A2($author$project$Models$Utils$Size, 0, 0),
		di: 0
	};
};
var $author$project$Mappers$SchemaMapper$buildJsonTable = function (_v0) {
	var table = _v0.a;
	var id = _v0.b;
	return {
		N: A2(
			$author$project$Libs$Std$dictFromList,
			function ($) {
				return $.ap;
			},
			A2($elm$core$List$indexedMap, $author$project$Mappers$SchemaMapper$buildJsonColumn, table.N)),
		aq: A2($elm$core$Maybe$map, $elm$core$Basics$identity, table.aq),
		b_: id,
		b3: A2($elm$core$List$map, $author$project$Mappers$SchemaMapper$buildJsonIndex, table.b3),
		cX: A2($elm$core$Maybe$map, $author$project$Mappers$SchemaMapper$buildJsonPrimaryKey, table.cX),
		c4: table.c4,
		a6: $author$project$Mappers$SchemaMapper$initTableState(id),
		bb: table.bb,
		dy: A2($elm$core$List$map, $author$project$Mappers$SchemaMapper$buildJsonUnique, table.dy)
	};
};
var $author$project$Libs$Std$listZipWith = F2(
	function (transform, list) {
		return A2(
			$elm$core$List$map,
			function (a) {
				return _Utils_Tuple2(
					a,
					transform(a));
			},
			list);
	});
var $author$project$Mappers$SchemaMapper$tableIdFromJsonTable = function (table) {
	return A2($author$project$Models$Schema$TableId, table.c4, table.bb);
};
var $author$project$Mappers$SchemaMapper$buildJsonTables = function (schema) {
	return A2(
		$elm$core$List$map,
		$author$project$Mappers$SchemaMapper$buildJsonTable,
		A2($author$project$Libs$Std$listZipWith, $author$project$Mappers$SchemaMapper$tableIdFromJsonTable, schema.dp));
};
var $author$project$Mappers$SchemaMapper$buildSchemaFromJson = F2(
	function (name, schema) {
		return A3(
			$author$project$Mappers$SchemaMapper$buildSchema,
			name,
			_List_Nil,
			$author$project$Mappers$SchemaMapper$buildJsonTables(schema));
	});
var $author$project$Mappers$SchemaMapper$tableIdFromSqlForeignKey = function (fk) {
	return A2($author$project$Models$Schema$TableId, fk.c4, fk.bb);
};
var $author$project$Mappers$SchemaMapper$buildSqlForeignKey = function (fk) {
	return {
		ap: fk.ap,
		R: fk.R,
		c4: fk.c4,
		bb: fk.bb,
		aj: $author$project$Mappers$SchemaMapper$tableIdFromSqlForeignKey(fk)
	};
};
var $author$project$Mappers$SchemaMapper$buildSqlColumn = F2(
	function (index, column) {
		return {
			ap: column.R,
			aq: A2($elm$core$Maybe$map, $elm$core$Basics$identity, column.aq),
			bW: A2($elm$core$Maybe$map, $author$project$Mappers$SchemaMapper$buildSqlForeignKey, column.bW),
			b2: index,
			b9: column.b9,
			cA: column.cA,
			a6: $author$project$Mappers$SchemaMapper$initColumnState(index)
		};
	});
var $author$project$Mappers$SchemaMapper$buildSqlPrimaryKey = function (pk) {
	return {
		N: A2($elm$core$List$map, $elm$core$Basics$identity, pk.N),
		R: pk.R
	};
};
var $author$project$Mappers$SchemaMapper$buildSqlUnique = function (unique) {
	return {
		N: A2($elm$core$List$map, $elm$core$Basics$identity, unique.N),
		R: unique.R
	};
};
var $author$project$Mappers$SchemaMapper$tableIdFromSqlTable = function (table) {
	return A2($author$project$Models$Schema$TableId, table.c4, table.bb);
};
var $author$project$Mappers$SchemaMapper$buildSqlTable = function (table) {
	return {
		N: A2(
			$author$project$Libs$Std$dictFromList,
			function ($) {
				return $.ap;
			},
			A2($elm$core$List$indexedMap, $author$project$Mappers$SchemaMapper$buildSqlColumn, table.N)),
		aq: A2($elm$core$Maybe$map, $elm$core$Basics$identity, table.aq),
		b_: $author$project$Mappers$SchemaMapper$tableIdFromSqlTable(table),
		b3: _List_Nil,
		cX: A2($elm$core$Maybe$map, $author$project$Mappers$SchemaMapper$buildSqlPrimaryKey, table.cX),
		c4: table.c4,
		a6: $author$project$Mappers$SchemaMapper$initTableState(
			$author$project$Mappers$SchemaMapper$tableIdFromSqlTable(table)),
		bb: table.bb,
		dy: A2($elm$core$List$map, $author$project$Mappers$SchemaMapper$buildSqlUnique, table.dy)
	};
};
var $author$project$Mappers$SchemaMapper$buildSqlTables = function (schema) {
	return A2(
		$elm$core$List$map,
		$author$project$Mappers$SchemaMapper$buildSqlTable,
		$pzp1997$assoc_list$AssocList$values(schema));
};
var $author$project$Mappers$SchemaMapper$buildSchemaFromSql = F2(
	function (name, schema) {
		return A3(
			$author$project$Mappers$SchemaMapper$buildSchema,
			name,
			_List_Nil,
			$author$project$Mappers$SchemaMapper$buildSqlTables(schema));
	});
var $author$project$Views$Helpers$decodeErrorToHtml = function (error) {
	return '<pre>' + ($elm$json$Json$Decode$errorToString(error) + '</pre>');
};
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $elm$core$String$endsWith = _String_endsWith;
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (!result.$) {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $author$project$SqlParser$SchemaParser$buildRawSql = function (statement) {
	return A2(
		$elm$core$String$join,
		' ',
		A2(
			$elm$core$List$map,
			function ($) {
				return $.u;
			},
			A2($elm$core$List$cons, statement.aa, statement.af)));
};
var $author$project$SqlParser$SchemaParser$addStatement = F2(
	function (lines, statements) {
		if (!lines.b) {
			return statements;
		} else {
			var head = lines.a;
			var tail = lines.b;
			return A2(
				$elm$core$List$cons,
				{aa: head, af: tail},
				statements);
		}
	});
var $elm$core$Basics$not = _Basics_not;
var $elm$core$String$trim = _String_trim;
var $author$project$SqlParser$SchemaParser$buildStatements = function (lines) {
	return function (_v1) {
		var cur = _v1.a;
		var res = _v1.b;
		return A2($author$project$SqlParser$SchemaParser$addStatement, cur, res);
	}(
		A3(
			$elm$core$List$foldr,
			F2(
				function (line, _v0) {
					var currentStatementLines = _v0.a;
					var statements = _v0.b;
					var nestedBlock = _v0.c;
					return (A2($elm$core$String$endsWith, ';', line.u) && (!nestedBlock)) ? _Utils_Tuple3(
						A2($elm$core$List$cons, line, _List_Nil),
						A2($author$project$SqlParser$SchemaParser$addStatement, currentStatementLines, statements),
						nestedBlock) : (($elm$core$String$trim(line.u) === 'BEGIN') ? _Utils_Tuple3(
						A2($elm$core$List$cons, line, currentStatementLines),
						statements,
						nestedBlock + 1) : (($elm$core$String$trim(line.u) === 'END') ? _Utils_Tuple3(
						A2($elm$core$List$cons, line, currentStatementLines),
						statements,
						nestedBlock - 1) : _Utils_Tuple3(
						A2($elm$core$List$cons, line, currentStatementLines),
						statements,
						nestedBlock)));
				}),
			_Utils_Tuple3(_List_Nil, _List_Nil, 0),
			A2(
				$elm$core$List$filter,
				function (line) {
					return !($elm$core$String$isEmpty(
						$elm$core$String$trim(line.u)) || A2($elm$core$String$startsWith, '--', line.u));
				},
				lines)));
};
var $pzp1997$assoc_list$AssocList$empty = _List_Nil;
var $author$project$SqlParser$SchemaParser$buildId = F2(
	function (schema, table) {
		return schema + ('.' + table);
	});
var $author$project$SqlParser$SchemaParser$buildColumn = function (column) {
	return {aq: $elm$core$Maybe$Nothing, bD: column.bD, bW: $elm$core$Maybe$Nothing, b9: column.b9, R: column.R, cA: column.cA};
};
var $author$project$SqlParser$SchemaParser$buildTable = function (table) {
	return {
		M: _List_Nil,
		N: A2($elm$core$List$map, $author$project$SqlParser$SchemaParser$buildColumn, table.N),
		aq: $elm$core$Maybe$Nothing,
		cX: $elm$core$Maybe$Nothing,
		c4: table.c4,
		bb: table.bb,
		dy: _List_Nil
	};
};
var $pzp1997$assoc_list$AssocList$get = F2(
	function (targetKey, _v0) {
		get:
		while (true) {
			var alist = _v0;
			if (!alist.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var _v2 = alist.a;
				var key = _v2.a;
				var value = _v2.b;
				var rest = alist.b;
				if (_Utils_eq(key, targetKey)) {
					return $elm$core$Maybe$Just(value);
				} else {
					var $temp$targetKey = targetKey,
						$temp$_v0 = rest;
					targetKey = $temp$targetKey;
					_v0 = $temp$_v0;
					continue get;
				}
			}
		}
	});
var $author$project$Libs$Std$listFind = F2(
	function (predicate, list) {
		listFind:
		while (true) {
			if (!list.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var first = list.a;
				var rest = list.b;
				if (predicate(first)) {
					return $elm$core$Maybe$Just(first);
				} else {
					var $temp$predicate = predicate,
						$temp$list = rest;
					predicate = $temp$predicate;
					list = $temp$list;
					continue listFind;
				}
			}
		}
	});
var $elm$core$Result$map = F2(
	function (func, ra) {
		if (!ra.$) {
			var a = ra.a;
			return $elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return $elm$core$Result$Err(e);
		}
	});
var $pzp1997$assoc_list$AssocList$update = F3(
	function (targetKey, alter, dict) {
		var alist = dict;
		var maybeValue = A2($pzp1997$assoc_list$AssocList$get, targetKey, dict);
		if (!maybeValue.$) {
			var _v1 = alter(maybeValue);
			if (!_v1.$) {
				var alteredValue = _v1.a;
				return A2(
					$elm$core$List$map,
					function (entry) {
						var key = entry.a;
						return _Utils_eq(key, targetKey) ? _Utils_Tuple2(targetKey, alteredValue) : entry;
					},
					alist);
			} else {
				return A2($pzp1997$assoc_list$AssocList$remove, targetKey, dict);
			}
		} else {
			var _v2 = alter($elm$core$Maybe$Nothing);
			if (!_v2.$) {
				var alteredValue = _v2.a;
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(targetKey, alteredValue),
					alist);
			} else {
				return dict;
			}
		}
	});
var $author$project$SqlParser$SchemaParser$updateTable = F3(
	function (id, transform, tables) {
		return A2(
			$elm$core$Maybe$withDefault,
			$elm$core$Result$Err(
				_List_fromArray(
					['Table ' + (id + ' does not exist')])),
			A2(
				$elm$core$Maybe$map,
				function (table) {
					return A2(
						$elm$core$Result$map,
						function (newTable) {
							return A3(
								$pzp1997$assoc_list$AssocList$update,
								id,
								$elm$core$Maybe$map(
									function (_v0) {
										return newTable;
									}),
								tables);
						},
						transform(table));
				},
				A2($pzp1997$assoc_list$AssocList$get, id, tables)));
	});
var $author$project$SqlParser$SchemaParser$updateTableColumn = F3(
	function (column, transform, table) {
		return _Utils_update(
			table,
			{
				N: A2(
					$elm$core$List$map,
					function (c) {
						return _Utils_eq(c.R, column) ? transform(c) : c;
					},
					table.N)
			});
	});
var $author$project$SqlParser$SchemaParser$updateColumn = F4(
	function (id, name, transform, tables) {
		return A3(
			$author$project$SqlParser$SchemaParser$updateTable,
			id,
			function (table) {
				return A2(
					$elm$core$Maybe$withDefault,
					$elm$core$Result$Err(
						_List_fromArray(
							['Column ' + (name + (' does not exist in table ' + id))])),
					A2(
						$elm$core$Maybe$map,
						function (column) {
							return A2(
								$elm$core$Result$map,
								function (newColumn) {
									return A3(
										$author$project$SqlParser$SchemaParser$updateTableColumn,
										name,
										function (_v0) {
											return newColumn;
										},
										table);
								},
								transform(column));
						},
						A2(
							$author$project$Libs$Std$listFind,
							function (column) {
								return _Utils_eq(column.R, name);
							},
							table.N)));
			},
			tables);
	});
var $author$project$SqlParser$SchemaParser$evolve = F2(
	function (command, tables) {
		switch (command.$) {
			case 0:
				var table = command.a;
				var id = A2($author$project$SqlParser$SchemaParser$buildId, table.c4, table.bb);
				return A2(
					$elm$core$Maybe$withDefault,
					$elm$core$Result$Ok(
						A3(
							$pzp1997$assoc_list$AssocList$insert,
							id,
							$author$project$SqlParser$SchemaParser$buildTable(table),
							tables)),
					A2(
						$elm$core$Maybe$map,
						function (_v1) {
							return $elm$core$Result$Err(
								_List_fromArray(
									['Table ' + (id + ' already exists')]));
						},
						A2($pzp1997$assoc_list$AssocList$get, id, tables)));
			case 1:
				if (!command.a.$) {
					switch (command.a.c.$) {
						case 0:
							var _v2 = command.a;
							var schema = _v2.a;
							var table = _v2.b;
							var _v3 = _v2.c;
							var constraint = _v3.a;
							var pk = _v3.b;
							return A3(
								$author$project$SqlParser$SchemaParser$updateTable,
								A2($author$project$SqlParser$SchemaParser$buildId, schema, table),
								function (t) {
									return $elm$core$Result$Ok(
										_Utils_update(
											t,
											{
												cX: $elm$core$Maybe$Just(
													{N: pk, R: constraint})
											}));
								},
								tables);
						case 1:
							var _v4 = command.a;
							var schema = _v4.a;
							var table = _v4.b;
							var _v5 = _v4.c;
							var constraint = _v5.a;
							var fk = _v5.b;
							return A4(
								$author$project$SqlParser$SchemaParser$updateColumn,
								A2($author$project$SqlParser$SchemaParser$buildId, schema, table),
								fk.ap,
								function (c) {
									return $elm$core$Result$Ok(
										_Utils_update(
											c,
											{
												bW: $elm$core$Maybe$Just(
													{ap: fk.by, R: constraint, c4: fk.c5, bb: fk.$7})
											}));
								},
								tables);
						case 2:
							var _v6 = command.a;
							var schema = _v6.a;
							var table = _v6.b;
							var _v7 = _v6.c;
							var constraint = _v7.a;
							var unique = _v7.b;
							return A3(
								$author$project$SqlParser$SchemaParser$updateTable,
								A2($author$project$SqlParser$SchemaParser$buildId, schema, table),
								function (t) {
									return $elm$core$Result$Ok(
										_Utils_update(
											t,
											{
												dy: _Utils_ap(
													t.dy,
													_List_fromArray(
														[
															{N: unique, R: constraint}
														]))
											}));
								},
								tables);
						default:
							var _v8 = command.a;
							var schema = _v8.a;
							var table = _v8.b;
							var _v9 = _v8.c;
							var constraint = _v9.a;
							var check = _v9.b;
							return A3(
								$author$project$SqlParser$SchemaParser$updateTable,
								A2($author$project$SqlParser$SchemaParser$buildId, schema, table),
								function (t) {
									return $elm$core$Result$Ok(
										_Utils_update(
											t,
											{
												M: _Utils_ap(
													t.M,
													_List_fromArray(
														[
															{R: constraint, aU: check}
														]))
											}));
								},
								tables);
					}
				} else {
					if (!command.a.c.$) {
						var _v10 = command.a;
						var schema = _v10.a;
						var table = _v10.b;
						var _v11 = _v10.c;
						var column = _v11.a;
						var _default = _v11.b;
						return A4(
							$author$project$SqlParser$SchemaParser$updateColumn,
							A2($author$project$SqlParser$SchemaParser$buildId, schema, table),
							column,
							function (c) {
								return $elm$core$Result$Ok(
									_Utils_update(
										c,
										{
											bD: $elm$core$Maybe$Just(_default)
										}));
							},
							tables);
					} else {
						var _v12 = command.a;
						var _v13 = _v12.c;
						return $elm$core$Result$Ok(tables);
					}
				}
			case 2:
				var comment = command.a;
				return A3(
					$author$project$SqlParser$SchemaParser$updateTable,
					A2($author$project$SqlParser$SchemaParser$buildId, comment.c4, comment.bb),
					function (table) {
						return $elm$core$Result$Ok(
							_Utils_update(
								table,
								{
									aq: $elm$core$Maybe$Just(comment.aq)
								}));
					},
					tables);
			case 3:
				var comment = command.a;
				return A4(
					$author$project$SqlParser$SchemaParser$updateColumn,
					A2($author$project$SqlParser$SchemaParser$buildId, comment.c4, comment.bb),
					comment.ap,
					function (column) {
						return $elm$core$Result$Ok(
							_Utils_update(
								column,
								{
									aq: $elm$core$Maybe$Just(comment.aq)
								}));
					},
					tables);
			default:
				return $elm$core$Result$Ok(tables);
		}
	});
var $author$project$SqlParser$SqlParser$AlterTable = function (a) {
	return {$: 1, a: a};
};
var $author$project$SqlParser$SqlParser$ColumnComment = function (a) {
	return {$: 3, a: a};
};
var $author$project$SqlParser$SqlParser$CreateTable = function (a) {
	return {$: 0, a: a};
};
var $author$project$SqlParser$SqlParser$Ignored = function (a) {
	return {$: 4, a: a};
};
var $author$project$SqlParser$SqlParser$TableComment = function (a) {
	return {$: 2, a: a};
};
var $author$project$SqlParser$SqlParser$AddTableConstraint = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $author$project$SqlParser$SqlParser$AlterColumn = F3(
	function (a, b, c) {
		return {$: 1, a: a, b: b, c: c};
	});
var $author$project$SqlParser$SqlParser$ParsedCheck = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$SqlParser$SqlParser$ParsedForeignKey = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$SqlParser$SqlParser$ParsedPrimaryKey = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$SqlParser$SqlParser$ParsedUnique = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {b2: index, ce: match, cB: number, dm: submatches};
	});
var $elm$regex$Regex$find = _Regex_findAtMost(_Regex_infinity);
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{br: false, cp: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $author$project$SqlParser$SqlParser$regexMatches = F2(
	function (regex, text) {
		return A2(
			$elm$core$List$concatMap,
			function ($) {
				return $.dm;
			},
			function (r) {
				return A2($elm$regex$Regex$find, r, text);
			}(
				A2(
					$elm$core$Maybe$withDefault,
					$elm$regex$Regex$never,
					$elm$regex$Regex$fromString(regex))));
	});
var $author$project$SqlParser$SqlParser$parseAlterTableAddConstraintCheck = function (constraint) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^CHECK (?<predicate>.*)$', constraint);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var predicate = _v0.a.a;
		return $elm$core$Result$Ok(predicate);
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse check constraint: \'' + (constraint + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTableAddConstraintForeignKey = function (constraint) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^FOREIGN KEY \\((?<column>[^)]+)\\) REFERENCES (?<schema_b>[^ .]+)\\.(?<table_b>[^ .]+) ?\\((?<column_b>[^)]+)\\)(?: NOT VALID)?$', constraint);
	if ((((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && (!_v0.b.b.a.$)) && _v0.b.b.b.b) && (!_v0.b.b.b.a.$)) && (!_v0.b.b.b.b.b)) {
		var column = _v0.a.a;
		var _v1 = _v0.b;
		var schemaDest = _v1.a.a;
		var _v2 = _v1.b;
		var tableDest = _v2.a.a;
		var _v3 = _v2.b;
		var columnDest = _v3.a.a;
		return $elm$core$Result$Ok(
			{ap: column, by: columnDest, c5: schemaDest, $7: tableDest});
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse foreign key: \'' + (constraint + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTableAddConstraintPrimaryKey = function (constraint) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^PRIMARY KEY \\((?<columns>[^)]+)\\)$', constraint);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var columns = _v0.a.a;
		return $elm$core$Result$Ok(
			A2(
				$elm$core$List$map,
				$elm$core$String$trim,
				A2($elm$core$String$split, ',', columns)));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse primary key: \'' + (constraint + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTableAddConstraintUnique = function (constraint) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^UNIQUE \\((?<columns>[^)]+)\\)$', constraint);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var columns = _v0.a.a;
		return $elm$core$Result$Ok(
			A2(
				$elm$core$List$map,
				$elm$core$String$trim,
				A2($elm$core$String$split, ',', columns)));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse unique constraint: \'' + (constraint + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTableAddConstraint = function (command) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)$', command);
	if ((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && (!_v0.b.b.b)) {
		var name = _v0.a.a;
		var _v1 = _v0.b;
		var constraint = _v1.a.a;
		return A2($elm$core$String$startsWith, 'PRIMARY KEY', constraint) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ParsedPrimaryKey(name),
			$author$project$SqlParser$SqlParser$parseAlterTableAddConstraintPrimaryKey(constraint)) : (A2($elm$core$String$startsWith, 'FOREIGN KEY', constraint) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ParsedForeignKey(name),
			$author$project$SqlParser$SqlParser$parseAlterTableAddConstraintForeignKey(constraint)) : (A2($elm$core$String$startsWith, 'UNIQUE', constraint) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ParsedUnique(name),
			$author$project$SqlParser$SqlParser$parseAlterTableAddConstraintUnique(constraint)) : (A2($elm$core$String$startsWith, 'CHECK', constraint) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ParsedCheck(name),
			$author$project$SqlParser$SqlParser$parseAlterTableAddConstraintCheck(constraint)) : $elm$core$Result$Err(
			_List_fromArray(
				['Constraint not handled in: \'' + (constraint + '\'')])))));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse add constraint: \'' + (command + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$ColumnDefault = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$SqlParser$SqlParser$ColumnStatistics = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$SqlParser$SqlParser$parseAlterTableAlterColumnDefault = function (property) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^DEFAULT (?<value>.+)$', property);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var value = _v0.a.a;
		return $elm$core$Result$Ok(value);
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse default value: \'' + (property + '\'')]));
	}
};
var $elm$core$Result$fromMaybe = F2(
	function (err, maybe) {
		if (!maybe.$) {
			var v = maybe.a;
			return $elm$core$Result$Ok(v);
		} else {
			return $elm$core$Result$Err(err);
		}
	});
var $author$project$SqlParser$SqlParser$parseAlterTableAlterColumnStatistics = function (property) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^STATISTICS (?<value>[0-9]+)$', property);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var value = _v0.a.a;
		return A2(
			$elm$core$Result$fromMaybe,
			_List_fromArray(
				['Statistics value is not a number: \'' + (value + '\'')]),
			$elm$core$String$toInt(value));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse statistics: \'' + (property + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTableAlterColumn = function (command) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)$', command);
	if ((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && (!_v0.b.b.b)) {
		var column = _v0.a.a;
		var _v1 = _v0.b;
		var property = _v1.a.a;
		return A2($elm$core$String$startsWith, 'DEFAULT', property) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ColumnDefault(column),
			$author$project$SqlParser$SqlParser$parseAlterTableAlterColumnDefault(property)) : (A2($elm$core$String$startsWith, 'STATISTICS', property) ? A2(
			$elm$core$Result$map,
			$author$project$SqlParser$SqlParser$ColumnStatistics(column),
			$author$project$SqlParser$SqlParser$parseAlterTableAlterColumnStatistics(property)) : $elm$core$Result$Err(
			_List_fromArray(
				['Column update not handled in: \'' + (property + '\'')])));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse alter column: \'' + (command + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseAlterTable = function (sql) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^ALTER TABLE (?:ONLY )?(?<schema>[^ .]+)\\.(?<table>[^ .]+) +(?<command>.*);$', sql);
	if ((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && (!_v0.b.b.a.$)) && (!_v0.b.b.b.b)) {
		var schema = _v0.a.a;
		var _v1 = _v0.b;
		var table = _v1.a.a;
		var _v2 = _v1.b;
		var command = _v2.a.a;
		return A2($elm$core$String$startsWith, 'ADD CONSTRAINT', command) ? A2(
			$elm$core$Result$map,
			A2($author$project$SqlParser$SqlParser$AddTableConstraint, schema, table),
			$author$project$SqlParser$SqlParser$parseAlterTableAddConstraint(command)) : (A2($elm$core$String$startsWith, 'ALTER COLUMN', command) ? A2(
			$elm$core$Result$map,
			A2($author$project$SqlParser$SqlParser$AlterColumn, schema, table),
			$author$project$SqlParser$SqlParser$parseAlterTableAlterColumn(command)) : $elm$core$Result$Err(
			_List_fromArray(
				['Command not handled in: \'' + (command + '\'')])));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse alter table: \'' + (sql + '\'')]));
	}
};
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$SqlParser$SqlParser$parseColumnComment = function (sql) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^COMMENT ON COLUMN (?<schema>[^ .]+)\\.(?<table>[^ .]+)\\.(?<column>[^ .]+) IS \'(?<comment>(?:[^\']|\'\')+)\';$', sql);
	if ((((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && (!_v0.b.b.a.$)) && _v0.b.b.b.b) && (!_v0.b.b.b.a.$)) && (!_v0.b.b.b.b.b)) {
		var schema = _v0.a.a;
		var _v1 = _v0.b;
		var table = _v1.a.a;
		var _v2 = _v1.b;
		var column = _v2.a.a;
		var _v3 = _v2.b;
		var comment = _v3.a.a;
		return $elm$core$Result$Ok(
			{
				ap: column,
				aq: A3($elm$core$String$replace, '\'\'', '\'', comment),
				c4: schema,
				bb: table
			});
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse column comment: \'' + (sql + '\'')]));
	}
};
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$fromList = _String_fromList;
var $author$project$SqlParser$SqlParser$commaSplit = function (text) {
	return function (_v1) {
		var res = _v1.a;
		var end = _v1.b;
		return A2(
			$elm$core$List$cons,
			$elm$core$String$fromList(end),
			res);
	}(
		A3(
			$elm$core$String$foldr,
			F2(
				function (_char, _v0) {
					var res = _v0.a;
					var cur = _v0.b;
					var open = _v0.c;
					return ((_char === ',') && (!open)) ? _Utils_Tuple3(
						A2(
							$elm$core$List$cons,
							$elm$core$String$fromList(cur),
							res),
						_List_Nil,
						open) : ((_char === '(') ? _Utils_Tuple3(
						res,
						A2($elm$core$List$cons, _char, cur),
						open + 1) : ((_char === ')') ? _Utils_Tuple3(
						res,
						A2($elm$core$List$cons, _char, cur),
						open - 1) : _Utils_Tuple3(
						res,
						A2($elm$core$List$cons, _char, cur),
						open)));
				}),
			_Utils_Tuple3(_List_Nil, _List_Nil, 0),
			text));
};
var $author$project$Libs$Std$listResultSeq = function (list) {
	var _v0 = $author$project$Libs$Std$listResultCollect(list);
	if (!_v0.a.b) {
		var res = _v0.b;
		return $elm$core$Result$Ok(res);
	} else {
		var errs = _v0.a;
		return $elm$core$Result$Err(errs);
	}
};
var $author$project$SqlParser$SqlParser$noEnclosingQuotes = function (text) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '\"(.*)\"', text);
	if ((_v0.b && (!_v0.a.$)) && (!_v0.b.b)) {
		var res = _v0.a.a;
		return res;
	} else {
		return text;
	}
};
var $author$project$SqlParser$SqlParser$parseCreateTableColumn = function (sql) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$', sql);
	if ((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && _v0.b.b.b.b) && (!_v0.b.b.b.b.b)) {
		var name = _v0.a.a;
		var _v1 = _v0.b;
		var kind = _v1.a.a;
		var _v2 = _v1.b;
		var _default = _v2.a;
		var _v3 = _v2.b;
		var nullable = _v3.a;
		return $elm$core$Result$Ok(
			{
				bD: _default,
				b9: kind,
				R: $author$project$SqlParser$SqlParser$noEnclosingQuotes(name),
				cA: _Utils_eq(nullable, $elm$core$Maybe$Nothing)
			});
	} else {
		return $elm$core$Result$Err('Can\'t parse column: \'' + (sql + '\''));
	}
};
var $author$project$SqlParser$SqlParser$parseCreateTable = function (sql) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^CREATE TABLE (?<schema>[^ .]+)\\.(?<table>[^ .]+) \\((?<body>[^;]+?)\\)(?: +WITH \\((?<options>.*?)\\))?;$', sql);
	if (((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && (!_v0.b.b.a.$)) && _v0.b.b.b.b) && (!_v0.b.b.b.b.b)) {
		var schema = _v0.a.a;
		var _v1 = _v0.b;
		var table = _v1.a.a;
		var _v2 = _v1.b;
		var columns = _v2.a.a;
		var _v3 = _v2.b;
		return A2(
			$elm$core$Result$map,
			function (c) {
				return {N: c, c4: schema, bb: table};
			},
			$author$project$Libs$Std$listResultSeq(
				A2(
					$elm$core$List$map,
					$author$project$SqlParser$SqlParser$parseCreateTableColumn,
					A2(
						$elm$core$List$filter,
						function (c) {
							return !A2($elm$core$String$startsWith, 'CONSTRAINT', c);
						},
						A2(
							$elm$core$List$map,
							$elm$core$String$trim,
							$author$project$SqlParser$SqlParser$commaSplit(columns))))));
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse table: \'' + (sql + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseTableComment = function (sql) {
	var _v0 = A2($author$project$SqlParser$SqlParser$regexMatches, '^COMMENT ON TABLE (?<schema>[^ .]+)\\.(?<table>[^ .]+) IS \'(?<comment>(?:[^\']|\'\')+)\';$', sql);
	if ((((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && _v0.b.b.b) && (!_v0.b.b.a.$)) && (!_v0.b.b.b.b)) {
		var schema = _v0.a.a;
		var _v1 = _v0.b;
		var table = _v1.a.a;
		var _v2 = _v1.b;
		var comment = _v2.a.a;
		return $elm$core$Result$Ok(
			{
				aq: A3($elm$core$String$replace, '\'\'', '\'', comment),
				c4: schema,
				bb: table
			});
	} else {
		return $elm$core$Result$Err(
			_List_fromArray(
				['Can\'t parse table comment: \'' + (sql + '\'')]));
	}
};
var $author$project$SqlParser$SqlParser$parseCommand = function (sql) {
	return A2($elm$core$String$startsWith, 'CREATE TABLE ', sql) ? A2(
		$elm$core$Result$map,
		$author$project$SqlParser$SqlParser$CreateTable,
		$author$project$SqlParser$SqlParser$parseCreateTable(sql)) : (A2($elm$core$String$startsWith, 'ALTER TABLE ', sql) ? A2(
		$elm$core$Result$map,
		$author$project$SqlParser$SqlParser$AlterTable,
		$author$project$SqlParser$SqlParser$parseAlterTable(sql)) : (A2($elm$core$String$startsWith, 'COMMENT ON TABLE ', sql) ? A2(
		$elm$core$Result$map,
		$author$project$SqlParser$SqlParser$TableComment,
		$author$project$SqlParser$SqlParser$parseTableComment(sql)) : (A2($elm$core$String$startsWith, 'COMMENT ON COLUMN ', sql) ? A2(
		$elm$core$Result$map,
		$author$project$SqlParser$SqlParser$ColumnComment,
		$author$project$SqlParser$SqlParser$parseColumnComment(sql)) : (A2($elm$core$String$startsWith, 'CREATE VIEW ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE MATERIALIZED VIEW ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE OR REPLACE VIEW ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'COMMENT ON VIEW ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE INDEX ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE UNIQUE INDEX ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'COMMENT ON INDEX ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE TYPE ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE FUNCTION ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE SCHEMA ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE EXTENSION ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'COMMENT ON EXTENSION ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE TEXT SEARCH CONFIGURATION ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'ALTER TEXT SEARCH CONFIGURATION ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'CREATE SEQUENCE ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'ALTER SEQUENCE ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'SELECT ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'INSERT INTO ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : (A2($elm$core$String$startsWith, 'SET ', sql) ? $elm$core$Result$Ok(
		$author$project$SqlParser$SqlParser$Ignored(sql)) : $elm$core$Result$Err(
		_List_fromArray(
			['Statement not handled: \'' + (sql + '\'')]))))))))))))))))))))))));
};
var $author$project$SqlParser$SchemaParser$parseLines = F2(
	function (fileName, fileContent) {
		return A2(
			$elm$core$List$indexedMap,
			F2(
				function (i, line) {
					return {bS: fileName, aH: i + 1, u: line};
				}),
			A2($elm$core$String$split, '\n', fileContent));
	});
var $author$project$SqlParser$SchemaParser$parseSchema = F2(
	function (fileName, fileContent) {
		return A3(
			$elm$core$List$foldl,
			F2(
				function (statement, _v0) {
					var errs = _v0.a;
					var schema = _v0.b;
					var _v1 = A2(
						$elm$core$Result$andThen,
						function (command) {
							return A2($author$project$SqlParser$SchemaParser$evolve, command, schema);
						},
						$author$project$SqlParser$SqlParser$parseCommand(
							$author$project$SqlParser$SchemaParser$buildRawSql(statement)));
					if (!_v1.$) {
						var newSchema = _v1.a;
						return _Utils_Tuple2(errs, newSchema);
					} else {
						var e = _v1.a;
						return _Utils_Tuple2(
							_Utils_ap(errs, e),
							schema);
					}
				}),
			_Utils_Tuple2(_List_Nil, $pzp1997$assoc_list$AssocList$empty),
			$author$project$SqlParser$SchemaParser$buildStatements(
				A2($author$project$SqlParser$SchemaParser$parseLines, fileName, fileContent)));
	});
var $author$project$Libs$Std$resultFold = F3(
	function (onError, onSuccess, result) {
		if (!result.$) {
			var a = result.a;
			return onSuccess(a);
		} else {
			var x = result.a;
			return onError(x);
		}
	});
var $author$project$JsonFormats$JsonSchemaDecoder$JsonSchema = function (tables) {
	return {dp: tables};
};
var $author$project$JsonFormats$JsonSchemaDecoder$JsonTable = F7(
	function (schema, table, columns, primaryKey, uniques, indexes, comment) {
		return {N: columns, aq: comment, b3: indexes, cX: primaryKey, c4: schema, bb: table, dy: uniques};
	});
var $author$project$JsonFormats$JsonSchemaDecoder$JsonColumn = F5(
	function (column, kind, nullable, reference, comment) {
		return {ap: column, aq: comment, b9: kind, cA: nullable, c_: reference};
	});
var $author$project$JsonFormats$JsonSchemaDecoder$JsonForeignKey = F4(
	function (schema, table, column, name) {
		return {ap: column, R: name, c4: schema, bb: table};
	});
var $elm$json$Json$Decode$map4 = _Json_map4;
var $author$project$JsonFormats$JsonSchemaDecoder$foreignKeyDecoder = A5(
	$elm$json$Json$Decode$map4,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonForeignKey,
	A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'column', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
var $author$project$JsonFormats$JsonSchemaDecoder$columnDecoder = A6(
	$elm$json$Json$Decode$map5,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonColumn,
	A2($elm$json$Json$Decode$field, 'column', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'type', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'nullable', $elm$json$Json$Decode$bool),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'reference', $author$project$JsonFormats$JsonSchemaDecoder$foreignKeyDecoder)),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string)));
var $author$project$JsonFormats$JsonSchemaDecoder$JsonIndex = F3(
	function (columns, definition, name) {
		return {N: columns, bE: definition, R: name};
	});
var $author$project$JsonFormats$JsonSchemaDecoder$indexDecoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonIndex,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'definition', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
var $author$project$JsonFormats$JsonSchemaDecoder$JsonPrimaryKey = F2(
	function (columns, name) {
		return {N: columns, R: name};
	});
var $author$project$JsonFormats$JsonSchemaDecoder$primaryKeyDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonPrimaryKey,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
var $author$project$JsonFormats$JsonSchemaDecoder$JsonUnique = F2(
	function (columns, name) {
		return {N: columns, R: name};
	});
var $author$project$JsonFormats$JsonSchemaDecoder$uniqueIndexDecoder = A3(
	$elm$json$Json$Decode$map2,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonUnique,
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
var $author$project$JsonFormats$JsonSchemaDecoder$tableDecoder = A8(
	$elm$json$Json$Decode$map7,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonTable,
	A2($elm$json$Json$Decode$field, 'schema', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'table', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'columns',
		$elm$json$Json$Decode$list($author$project$JsonFormats$JsonSchemaDecoder$columnDecoder)),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'primary_key', $author$project$JsonFormats$JsonSchemaDecoder$primaryKeyDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'uniques',
		$elm$json$Json$Decode$list($author$project$JsonFormats$JsonSchemaDecoder$uniqueIndexDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'indexes',
		$elm$json$Json$Decode$list($author$project$JsonFormats$JsonSchemaDecoder$indexDecoder)),
	$elm$json$Json$Decode$maybe(
		A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string)));
var $author$project$JsonFormats$JsonSchemaDecoder$schemaDecoder = A2(
	$elm$json$Json$Decode$map,
	$author$project$JsonFormats$JsonSchemaDecoder$JsonSchema,
	A2(
		$elm$json$Json$Decode$field,
		'tables',
		$elm$json$Json$Decode$list($author$project$JsonFormats$JsonSchemaDecoder$tableDecoder)));
var $author$project$Update$buildSchema = F3(
	function (name, path, content) {
		return A2($elm$core$String$endsWith, '.sql', path) ? A2(
			$elm$core$Tuple$mapSecond,
			$author$project$Mappers$SchemaMapper$buildSchemaFromSql(name),
			A2($author$project$SqlParser$SchemaParser$parseSchema, path, content)) : (A2($elm$core$String$endsWith, '.json', path) ? A3(
			$author$project$Libs$Std$resultFold,
			function (e) {
				return _Utils_Tuple2(
					_List_fromArray(
						[
							'⚠️ Error in <b>' + (path + ('</b> ⚠️<br>' + $author$project$Views$Helpers$decodeErrorToHtml(e)))
						]),
					$author$project$Mappers$SchemaMapper$emptySchema);
			},
			function (schema) {
				return _Utils_Tuple2(
					_List_Nil,
					A2($author$project$Mappers$SchemaMapper$buildSchemaFromJson, name, schema));
			},
			A2($elm$json$Json$Decode$decodeString, $author$project$JsonFormats$JsonSchemaDecoder$schemaDecoder, content)) : _Utils_Tuple2(
			_List_fromArray(
				['Invalid file (' + (path + '), expected .sql or .json one')]),
			$author$project$Mappers$SchemaMapper$emptySchema));
	});
var $author$project$Views$Helpers$formatHttpError = function (error) {
	switch (error.$) {
		case 0:
			var url = error.a;
			return 'the URL ' + (url + ' was invalid');
		case 1:
			return 'unable to reach the server, try again';
		case 2:
			return 'unable to reach the server, check your network connection';
		case 3:
			switch (error.a) {
				case 500:
					return 'the server had a problem, try again later';
				case 400:
					return 'verify your information and try again';
				case 404:
					return 'file does not exist';
				default:
					var status = error.a;
					return 'network error (' + ($elm$core$String$fromInt(status) + ')');
			}
		default:
			var errorMessage = error.a;
			return errorMessage;
	}
};
var $author$project$Models$ShowAllTables = {$: 17};
var $author$project$Ports$click = _Platform_outgoingPort('click', $elm$json$Json$Encode$string);
var $author$project$Ports$hideModal = _Platform_outgoingPort('hideModal', $elm$json$Json$Encode$string);
var $pzp1997$assoc_list$AssocList$isEmpty = function (dict) {
	return _Utils_eq(dict, _List_Nil);
};
var $author$project$Libs$Std$send = function (msg) {
	return A2(
		$elm$core$Task$perform,
		$elm$core$Basics$identity,
		$elm$core$Task$succeed(msg));
};
var $pzp1997$assoc_list$AssocList$size = function (_v0) {
	var alist = _v0;
	return $elm$core$List$length(alist);
};
var $author$project$Ports$showToast = _Platform_outgoingPort(
	'showToast',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'kind',
					$elm$json$Json$Encode$string($.b9)),
					_Utils_Tuple2(
					'message',
					$elm$json$Json$Encode$string($.aJ))
				]));
	});
var $author$project$Ports$toastError = function (message) {
	return $author$project$Ports$showToast(
		{b9: 'error', aJ: message});
};
var $author$project$Ports$toastInfo = function (message) {
	return $author$project$Ports$showToast(
		{b9: 'info', aJ: message});
};
var $author$project$Update$loadSchema = F2(
	function (model, _v0) {
		var errs = _v0.a;
		var schema = _v0.b;
		return $pzp1997$assoc_list$AssocList$isEmpty(schema.dp) ? _Utils_Tuple2(
			_Utils_update(
				model,
				{X: $author$project$Models$initSwitch}),
			$elm$core$Platform$Cmd$batch(
				A2($elm$core$List$map, $author$project$Ports$toastError, errs))) : _Utils_Tuple2(
			_Utils_update(
				model,
				{c4: schema, X: $author$project$Models$initSwitch}),
			$elm$core$Platform$Cmd$batch(
				_Utils_ap(
					A2($elm$core$List$map, $author$project$Ports$toastError, errs),
					_Utils_ap(
						_List_fromArray(
							[
								$author$project$Ports$toastInfo('<b>' + (schema.R + '</b> loaded.<br>Use the search bar to explore it')),
								$author$project$Ports$hideModal($author$project$Conf$conf.b0.c6),
								$author$project$Ports$saveSchema(schema)
							]),
						($pzp1997$assoc_list$AssocList$size(schema.dp) < 10) ? _List_fromArray(
							[
								$author$project$Libs$Std$send($author$project$Models$ShowAllTables)
							]) : _List_fromArray(
							[
								$author$project$Ports$click($author$project$Conf$conf.b0.c9)
							])))));
	});
var $author$project$Update$createSampleSchema = F4(
	function (name, path, response, model) {
		return A2(
			$author$project$Update$loadSchema,
			model,
			A3(
				$author$project$Libs$Std$resultFold,
				function (err) {
					return _Utils_Tuple2(
						_List_fromArray(
							[
								'Can\'t load \'' + (name + ('\': ' + $author$project$Views$Helpers$formatHttpError(err)))
							]),
						$author$project$Mappers$SchemaMapper$emptySchema);
				},
				A2($author$project$Update$buildSchema, name, path),
				response));
	});
var $author$project$Update$createSchema = F3(
	function (file, content, model) {
		return A2(
			$author$project$Update$loadSchema,
			model,
			A3($author$project$Update$buildSchema, file.R, file.R, content));
	});
var $author$project$Update$deleteLayout = F2(
	function (name, model) {
		var newModel = A2(
			$author$project$Libs$Std$setState,
			function (s) {
				return _Utils_eq(
					s.as,
					$elm$core$Maybe$Just(name)) ? _Utils_update(
					s,
					{as: $elm$core$Maybe$Nothing}) : s;
			},
			A2(
				$author$project$Libs$Std$setSchema,
				function (s) {
					return _Utils_update(
						s,
						{
							cb: A2(
								$elm$core$List$filter,
								function (l) {
									return !_Utils_eq(l.R, name);
								},
								s.cb)
						});
				},
				model));
		return _Utils_Tuple2(
			newModel,
			$author$project$Ports$saveSchema(newModel.c4));
	});
var $author$project$Models$OnDragBy = function (a) {
	return {$: 24, a: a};
};
var $author$project$Models$StartDragging = function (a) {
	return {$: 22, a: a};
};
var $author$project$Models$StopDragging = {$: 23};
var $zaboco$elm_draggable$Draggable$Config = $elm$core$Basics$identity;
var $zaboco$elm_draggable$Internal$defaultConfig = {
	cD: function (_v0) {
		return $elm$core$Maybe$Nothing;
	},
	cE: function (_v1) {
		return $elm$core$Maybe$Nothing;
	},
	cF: $elm$core$Maybe$Nothing,
	cG: function (_v2) {
		return $elm$core$Maybe$Nothing;
	},
	cJ: function (_v3) {
		return $elm$core$Maybe$Nothing;
	}
};
var $zaboco$elm_draggable$Draggable$customConfig = function (events) {
	return A3($elm$core$List$foldl, $elm$core$Basics$apL, $zaboco$elm_draggable$Internal$defaultConfig, events);
};
var $zaboco$elm_draggable$Draggable$Events$onDragBy = F2(
	function (toMsg, config) {
		return _Utils_update(
			config,
			{
				cE: A2($elm$core$Basics$composeL, $elm$core$Maybe$Just, toMsg)
			});
	});
var $zaboco$elm_draggable$Draggable$Events$onDragEnd = F2(
	function (toMsg, config) {
		return _Utils_update(
			config,
			{
				cF: $elm$core$Maybe$Just(toMsg)
			});
	});
var $zaboco$elm_draggable$Draggable$Events$onDragStart = F2(
	function (toMsg, config) {
		return _Utils_update(
			config,
			{
				cG: A2($elm$core$Basics$composeL, $elm$core$Maybe$Just, toMsg)
			});
	});
var $author$project$Update$dragConfig = $zaboco$elm_draggable$Draggable$customConfig(
	_List_fromArray(
		[
			$zaboco$elm_draggable$Draggable$Events$onDragStart($author$project$Models$StartDragging),
			$zaboco$elm_draggable$Draggable$Events$onDragEnd($author$project$Models$StopDragging),
			$zaboco$elm_draggable$Draggable$Events$onDragBy($author$project$Models$OnDragBy)
		]));
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Update$updatePosition = F3(
	function (_v0, zoom, item) {
		var dx = _v0.a;
		var dy = _v0.b;
		return _Utils_update(
			item,
			{
				U: A2($author$project$Models$Utils$Position, item.U.cc + (dx / zoom), item.U.dw + (dy / zoom))
			});
	});
var $author$project$Update$visitTable = F3(
	function (id, transform, schema) {
		return _Utils_update(
			schema,
			{
				dp: A3(
					$pzp1997$assoc_list$AssocList$update,
					id,
					$elm$core$Maybe$map(transform),
					schema.dp)
			});
	});
var $author$project$Update$dragItem = F2(
	function (model, delta) {
		var _v0 = model.a6.av;
		if (!_v0.$) {
			var id = _v0.a;
			return _Utils_eq(id, $author$project$Conf$conf.b0.bL) ? _Utils_Tuple2(
				_Utils_update(
					model,
					{
						bq: A3($author$project$Update$updatePosition, delta, 1, model.bq)
					}),
				$elm$core$Platform$Cmd$none) : _Utils_Tuple2(
				_Utils_update(
					model,
					{
						c4: A3(
							$author$project$Update$visitTable,
							$author$project$Views$Helpers$parseTableId(id),
							$author$project$Libs$Std$setState(
								A2($author$project$Update$updatePosition, delta, model.bq.dG)),
							model.c4)
					}),
				$elm$core$Platform$Cmd$none);
		} else {
			return _Utils_Tuple2(
				model,
				$author$project$Ports$toastError('Can\'t dragItem when no drag id'));
		}
	});
var $pzp1997$assoc_list$AssocList$map = F2(
	function (alter, _v0) {
		var alist = _v0;
		return A2(
			$elm$core$List$map,
			function (_v1) {
				var key = _v1.a;
				var value = _v1.b;
				return _Utils_Tuple2(
					key,
					A2(alter, key, value));
			},
			alist);
	});
var $author$project$Update$visitTables = F2(
	function (transform, schema) {
		return _Utils_update(
			schema,
			{
				dp: A2(
					$pzp1997$assoc_list$AssocList$map,
					F2(
						function (_v0, table) {
							return transform(table);
						}),
					schema.dp)
			});
	});
var $author$project$Update$hideAllTables = function (schema) {
	return A2(
		$author$project$Update$visitTables,
		$author$project$Libs$Std$setState(
			function (state) {
				return (state.di === 3) ? _Utils_update(
					state,
					{di: 2}) : state;
			}),
		schema);
};
var $elm$core$List$sortBy = _List_sortBy;
var $author$project$Update$setSequentialOrder = function (columns) {
	return A2(
		$author$project$Libs$Std$dictFromList,
		function ($) {
			return $.ap;
		},
		A2(
			$elm$core$List$indexedMap,
			F2(
				function (index, column) {
					return _Utils_eq(column.a6.cP, $elm$core$Maybe$Nothing) ? column : A2(
						$author$project$Libs$Std$setState,
						function (state) {
							return _Utils_update(
								state,
								{
									cP: $elm$core$Maybe$Just(index)
								});
						},
						column);
				}),
			A2(
				$elm$core$List$sortBy,
				function (c) {
					return A2(
						$elm$core$Maybe$withDefault,
						$pzp1997$assoc_list$AssocList$size(columns),
						c.a6.cP);
				},
				$pzp1997$assoc_list$AssocList$values(columns))));
};
var $author$project$Update$hideColumn = F2(
	function (columnName, columns) {
		return $author$project$Update$setSequentialOrder(
			A3(
				$pzp1997$assoc_list$AssocList$update,
				columnName,
				$elm$core$Maybe$map(
					$author$project$Libs$Std$setState(
						function (state) {
							return _Utils_update(
								state,
								{cP: $elm$core$Maybe$Nothing});
						})),
				columns));
	});
var $author$project$Ports$hideOffcanvas = _Platform_outgoingPort('hideOffcanvas', $elm$json$Json$Encode$string);
var $author$project$Update$hideTable = F2(
	function (id, schema) {
		return A3(
			$author$project$Update$visitTable,
			id,
			$author$project$Libs$Std$setState(
				function (state) {
					return _Utils_update(
						state,
						{di: 2});
				}),
			schema);
	});
var $author$project$Ports$observeTablesSize = function (ids) {
	return $author$project$Ports$observeSizes(
		A2($elm$core$List$map, $author$project$Views$Helpers$formatTableId, ids));
};
var $author$project$Libs$Std$set = F2(
	function (transform, item) {
		return transform(item);
	});
var $author$project$Update$setTables = F2(
	function (tables, schema) {
		return _Utils_update(
			schema,
			{
				dp: A2(
					$author$project$Libs$Std$dictFromList,
					function ($) {
						return $.b_;
					},
					tables)
			});
	});
var $author$project$Update$setTableLayout = F2(
	function (props, table) {
		return _Utils_update(
			table,
			{
				N: A2(
					$pzp1997$assoc_list$AssocList$map,
					F2(
						function (name, column) {
							return A2(
								$author$project$Libs$Std$setState,
								function (state) {
									return _Utils_update(
										state,
										{
											cP: A2(
												$elm$core$Maybe$map,
												function ($) {
													return $.U;
												},
												A2($pzp1997$assoc_list$AssocList$get, name, props.N))
										});
								},
								column);
						}),
					table.N),
				a6: A2(
					$author$project$Libs$Std$set,
					function (state) {
						return _Utils_update(
							state,
							{bw: props.bw, U: props.U});
					},
					table.a6)
			});
	});
var $author$project$Update$showTableWithLayout = F2(
	function (maybeProps, table) {
		var _v0 = _Utils_Tuple2(table.a6.di, maybeProps);
		if (!_v0.b.$) {
			switch (_v0.a) {
				case 0:
					var _v1 = _v0.a;
					var props = _v0.b.a;
					return _Utils_Tuple2(
						$elm$core$Maybe$Just(table.b_),
						A2(
							$author$project$Update$setTableLayout,
							props,
							A2(
								$author$project$Libs$Std$setState,
								function (state) {
									return _Utils_update(
										state,
										{di: 1});
								},
								table)));
				case 1:
					var _v4 = _v0.a;
					var props = _v0.b.a;
					return _Utils_Tuple2(
						$elm$core$Maybe$Nothing,
						A2($author$project$Update$setTableLayout, props, table));
				case 2:
					var _v7 = _v0.a;
					var props = _v0.b.a;
					return _Utils_Tuple2(
						$elm$core$Maybe$Just(table.b_),
						A2(
							$author$project$Update$setTableLayout,
							props,
							A2(
								$author$project$Libs$Std$setState,
								function (state) {
									return _Utils_update(
										state,
										{da: false, di: 3});
								},
								table)));
				default:
					var _v10 = _v0.a;
					var props = _v0.b.a;
					return _Utils_Tuple2(
						$elm$core$Maybe$Nothing,
						A2($author$project$Update$setTableLayout, props, table));
			}
		} else {
			switch (_v0.a) {
				case 0:
					var _v2 = _v0.a;
					var _v3 = _v0.b;
					return _Utils_Tuple2($elm$core$Maybe$Nothing, table);
				case 1:
					var _v5 = _v0.a;
					var _v6 = _v0.b;
					return _Utils_Tuple2(
						$elm$core$Maybe$Nothing,
						A2(
							$author$project$Libs$Std$setState,
							function (state) {
								return _Utils_update(
									state,
									{di: 0});
							},
							table));
				case 2:
					var _v8 = _v0.a;
					var _v9 = _v0.b;
					return _Utils_Tuple2($elm$core$Maybe$Nothing, table);
				default:
					var _v11 = _v0.a;
					var _v12 = _v0.b;
					return _Utils_Tuple2(
						$elm$core$Maybe$Nothing,
						A2(
							$author$project$Libs$Std$setState,
							function (state) {
								return _Utils_update(
									state,
									{di: 2});
							},
							table));
			}
		}
	});
var $elm$core$List$unzip = function (pairs) {
	var step = F2(
		function (_v0, _v1) {
			var x = _v0.a;
			var y = _v0.b;
			var xs = _v1.a;
			var ys = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, x, xs),
				A2($elm$core$List$cons, y, ys));
		});
	return A3(
		$elm$core$List$foldr,
		step,
		_Utils_Tuple2(_List_Nil, _List_Nil),
		pairs);
};
var $author$project$Update$loadLayout = F2(
	function (name, model) {
		return A2(
			$elm$core$Maybe$withDefault,
			_Utils_Tuple2(model, $elm$core$Platform$Cmd$none),
			A2(
				$elm$core$Maybe$map,
				function (layout) {
					var _v0 = $elm$core$List$unzip(
						A2(
							$elm$core$List$map,
							function (table) {
								return A2(
									$author$project$Update$showTableWithLayout,
									A2($pzp1997$assoc_list$AssocList$get, table.b_, layout.dp),
									table);
							},
							$pzp1997$assoc_list$AssocList$values(model.c4.dp)));
					var cmds = _v0.a;
					var tables = _v0.b;
					return _Utils_Tuple2(
						A2(
							$author$project$Libs$Std$setState,
							function (s) {
								return _Utils_update(
									s,
									{
										as: $elm$core$Maybe$Just(name)
									});
							},
							A2(
								$author$project$Libs$Std$setSchema,
								$author$project$Update$setTables(tables),
								A2(
									$author$project$Libs$Std$set,
									function (m) {
										return _Utils_update(
											m,
											{
												bq: {U: layout.bq.U, df: model.bq.df, dG: layout.bq.dG}
											});
									},
									model))),
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									$author$project$Ports$observeTablesSize(
									A2($elm$core$List$filterMap, $elm$core$Basics$identity, cmds)),
									$author$project$Ports$activateTooltipsAndPopovers(0)
								])));
				},
				A2(
					$author$project$Libs$Std$listFind,
					function (layout) {
						return _Utils_eq(layout.R, name);
					},
					model.c4.cb)));
	});
var $author$project$Models$GotSampleData = F3(
	function (a, b, c) {
		return {$: 7, a: a, b: b, c: c};
	});
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 2};
var $elm$http$Http$Receiving = function (a) {
	return {$: 1, a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$Timeout_ = {$: 1};
var $elm$core$Maybe$isJust = function (maybe) {
	if (!maybe.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (!_v0.$) {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			$elm$core$Basics$identity,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$http$Http$BadBody = function (a) {
	return {$: 4, a: a};
};
var $elm$http$Http$BadStatus = function (a) {
	return {$: 3, a: a};
};
var $elm$http$Http$BadUrl = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$NetworkError = {$: 2};
var $elm$http$Http$Timeout = {$: 1};
var $elm$http$Http$resolve = F2(
	function (toResult, response) {
		switch (response.$) {
			case 0:
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 1:
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 2:
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			case 3:
				var metadata = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(metadata.dj));
			default:
				var body = response.b;
				return A2(
					$elm$core$Result$mapError,
					$elm$http$Http$BadBody,
					toResult(body));
		}
	});
var $elm$http$Http$expectString = function (toMsg) {
	return A2(
		$elm$http$Http$expectStringResponse,
		toMsg,
		$elm$http$Http$resolve($elm$core$Result$Ok));
};
var $elm$http$Http$emptyBody = _Http_emptyBody;
var $elm$http$Http$Request = function (a) {
	return {$: 1, a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {a$: reqs, ba: subs};
	});
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (!cmd.$) {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 1) {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.bd;
							if (_v4.$ === 1) {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.a$));
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.ba)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (!cmd.$) {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					bj: r.bj,
					bm: r.bm,
					bN: A2(_Http_mapExpect, func, r.bN),
					aB: r.aB,
					ci: r.ci,
					du: r.du,
					bd: r.bd,
					dA: r.dA
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{bj: false, bm: r.bm, bN: r.bN, aB: r.aB, ci: r.ci, du: r.du, bd: r.bd, dA: r.dA}));
};
var $elm$http$Http$get = function (r) {
	return $elm$http$Http$request(
		{bm: $elm$http$Http$emptyBody, bN: r.bN, aB: _List_Nil, ci: 'GET', du: $elm$core$Maybe$Nothing, bd: $elm$core$Maybe$Nothing, dA: r.dA});
};
var $author$project$Conf$schemaSamples = $pzp1997$assoc_list$AssocList$fromList(
	$elm$core$List$reverse(
		_List_fromArray(
			[
				_Utils_Tuple2('Basic example', 'schema.json')
			])));
var $author$project$Commands$FetchSample$loadSample = function (name) {
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Ports$toastError('Unable to find \'' + (name + '\' example')),
		A2(
			$elm$core$Maybe$map,
			function (path) {
				return $elm$http$Http$get(
					{
						bN: $elm$http$Http$expectString(
							A2($author$project$Models$GotSampleData, name, path)),
						dA: path
					});
			},
			A2($pzp1997$assoc_list$AssocList$get, name, $author$project$Conf$schemaSamples)));
};
var $elm$core$Tuple$mapFirst = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var $mpizenberg$elm_file$FileValue$encode = function (file) {
	return file.dB;
};
var $author$project$Ports$readTextFile = _Platform_outgoingPort('readTextFile', $elm$core$Basics$identity);
var $author$project$Ports$readFile = function (file) {
	return $author$project$Ports$readTextFile(
		$mpizenberg$elm_file$FileValue$encode(file));
};
var $author$project$Update$showTableByState = function (table) {
	var _v0 = table.a6.di;
	switch (_v0) {
		case 0:
			return _Utils_Tuple2(
				$elm$core$Maybe$Just(table.b_),
				A2(
					$author$project$Libs$Std$setState,
					function (state) {
						return _Utils_update(
							state,
							{di: 1});
					},
					table));
		case 1:
			return _Utils_Tuple2($elm$core$Maybe$Nothing, table);
		case 2:
			return _Utils_Tuple2(
				$elm$core$Maybe$Just(table.b_),
				A2(
					$author$project$Libs$Std$setState,
					function (state) {
						return _Utils_update(
							state,
							{da: false, di: 3});
					},
					table));
		default:
			return _Utils_Tuple2($elm$core$Maybe$Nothing, table);
	}
};
var $author$project$Update$showAllTables = function (model) {
	var _v0 = $elm$core$List$unzip(
		A2(
			$elm$core$List$map,
			$author$project$Update$showTableByState,
			$pzp1997$assoc_list$AssocList$values(model.c4.dp)));
	var cmds = _v0.a;
	var tables = _v0.b;
	return _Utils_Tuple2(
		_Utils_update(
			model,
			{
				c4: A2($author$project$Update$setTables, tables, model.c4)
			}),
		$elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					$author$project$Ports$observeTablesSize(
					A2($elm$core$List$filterMap, $elm$core$Basics$identity, cmds)),
					$author$project$Ports$activateTooltipsAndPopovers(0)
				])));
};
var $author$project$Update$showColumn = F3(
	function (columnName, index, columns) {
		return A2(
			$pzp1997$assoc_list$AssocList$map,
			F2(
				function (_v0, column) {
					var _v1 = column.a6.cP;
					if (!_v1.$) {
						var order = _v1.a;
						return (_Utils_cmp(order, index) < 0) ? column : A2(
							$author$project$Libs$Std$setState,
							function (state) {
								return _Utils_update(
									state,
									{
										cP: $elm$core$Maybe$Just(order + 1)
									});
							},
							column);
					} else {
						return _Utils_eq(column.ap, columnName) ? A2(
							$author$project$Libs$Std$setState,
							function (state) {
								return _Utils_update(
									state,
									{
										cP: $elm$core$Maybe$Just(index)
									});
							},
							column) : column;
					}
				}),
			columns);
	});
var $author$project$Update$getTable = F2(
	function (id, schema) {
		return A2($pzp1997$assoc_list$AssocList$get, id, schema.dp);
	});
var $author$project$Ports$observeTableSize = function (id) {
	return $author$project$Ports$observeSizes(
		_List_fromArray(
			[
				$author$project$Views$Helpers$formatTableId(id)
			]));
};
var $author$project$Update$showTable = F2(
	function (model, id) {
		var _v0 = A2(
			$elm$core$Maybe$map,
			function (t) {
				return t.a6.di;
			},
			A2($author$project$Update$getTable, id, model.c4));
		if (!_v0.$) {
			switch (_v0.a) {
				case 0:
					var _v1 = _v0.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								c4: A3(
									$author$project$Update$visitTable,
									id,
									$author$project$Libs$Std$setState(
										function (state) {
											return _Utils_update(
												state,
												{di: 1});
										}),
									model.c4)
							}),
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									$author$project$Ports$observeTableSize(id),
									$author$project$Ports$activateTooltipsAndPopovers(0)
								])));
				case 1:
					var _v2 = _v0.a;
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				case 2:
					var _v3 = _v0.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								c4: A3(
									$author$project$Update$visitTable,
									id,
									$author$project$Libs$Std$setState(
										function (state) {
											return _Utils_update(
												state,
												{da: false, di: 3});
										}),
									model.c4)
							}),
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									$author$project$Ports$observeTableSize(id),
									$author$project$Ports$activateTooltipsAndPopovers(0)
								])));
				default:
					var _v4 = _v0.a;
					return _Utils_Tuple2(
						model,
						$author$project$Ports$toastInfo(
							'Table <b>' + ($author$project$Views$Helpers$formatTableId(id) + '</b> is already shown')));
			}
		} else {
			return _Utils_Tuple2(
				model,
				$author$project$Ports$toastError(
					'Can\'t show table <b>' + ($author$project$Views$Helpers$formatTableId(id) + '</b>: not found')));
		}
	});
var $zaboco$elm_draggable$Cmd$Extra$message = function (x) {
	return A2(
		$elm$core$Task$perform,
		$elm$core$Basics$identity,
		$elm$core$Task$succeed(x));
};
var $zaboco$elm_draggable$Cmd$Extra$optionalMessage = function (msgMaybe) {
	return A2(
		$elm$core$Maybe$withDefault,
		$elm$core$Platform$Cmd$none,
		A2($elm$core$Maybe$map, $zaboco$elm_draggable$Cmd$Extra$message, msgMaybe));
};
var $zaboco$elm_draggable$Internal$Dragging = function (a) {
	return {$: 2, a: a};
};
var $zaboco$elm_draggable$Internal$DraggingTentative = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $zaboco$elm_draggable$Internal$distanceTo = F2(
	function (end, start) {
		return _Utils_Tuple2(end.bf - start.bf, end.bg - start.bg);
	});
var $zaboco$elm_draggable$Internal$updateAndEmit = F3(
	function (config, msg, drag) {
		var _v0 = _Utils_Tuple2(drag, msg);
		_v0$5:
		while (true) {
			switch (_v0.a.$) {
				case 0:
					if (!_v0.b.$) {
						var _v1 = _v0.a;
						var _v2 = _v0.b;
						var key = _v2.a;
						var initialPosition = _v2.b;
						return _Utils_Tuple2(
							A2($zaboco$elm_draggable$Internal$DraggingTentative, key, initialPosition),
							config.cJ(key));
					} else {
						break _v0$5;
					}
				case 1:
					switch (_v0.b.$) {
						case 1:
							var _v3 = _v0.a;
							var key = _v3.a;
							var oldPosition = _v3.b;
							return _Utils_Tuple2(
								$zaboco$elm_draggable$Internal$Dragging(oldPosition),
								config.cG(key));
						case 2:
							var _v4 = _v0.a;
							var key = _v4.a;
							var _v5 = _v0.b;
							return _Utils_Tuple2(
								$zaboco$elm_draggable$Internal$NotDragging,
								config.cD(key));
						default:
							break _v0$5;
					}
				default:
					switch (_v0.b.$) {
						case 1:
							var oldPosition = _v0.a.a;
							var newPosition = _v0.b.a;
							return _Utils_Tuple2(
								$zaboco$elm_draggable$Internal$Dragging(newPosition),
								config.cE(
									A2($zaboco$elm_draggable$Internal$distanceTo, newPosition, oldPosition)));
						case 2:
							var _v6 = _v0.b;
							return _Utils_Tuple2($zaboco$elm_draggable$Internal$NotDragging, config.cF);
						default:
							break _v0$5;
					}
			}
		}
		return _Utils_Tuple2(drag, $elm$core$Maybe$Nothing);
	});
var $zaboco$elm_draggable$Draggable$updateDraggable = F3(
	function (_v0, _v1, _v2) {
		var config = _v0;
		var msg = _v1;
		var drag = _v2;
		var _v3 = A3($zaboco$elm_draggable$Internal$updateAndEmit, config, msg, drag);
		var newDrag = _v3.a;
		var newMsgMaybe = _v3.b;
		return _Utils_Tuple2(
			newDrag,
			$zaboco$elm_draggable$Cmd$Extra$optionalMessage(newMsgMaybe));
	});
var $zaboco$elm_draggable$Draggable$update = F3(
	function (config, msg, model) {
		var _v0 = A3($zaboco$elm_draggable$Draggable$updateDraggable, config, msg, model.bJ);
		var dragState = _v0.a;
		var dragCmd = _v0.b;
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{bJ: dragState}),
			dragCmd);
	});
var $author$project$Update$updateLayout = F2(
	function (name, model) {
		var newModel = A2(
			$author$project$Libs$Std$setState,
			function (s) {
				return _Utils_update(
					s,
					{
						as: $elm$core$Maybe$Just(name)
					});
			},
			A2(
				$author$project$Libs$Std$setSchema,
				function (s) {
					return _Utils_update(
						s,
						{
							cb: A2(
								$elm$core$List$map,
								function (l) {
									return A3(
										$author$project$Libs$Std$cond,
										_Utils_eq(l.R, name),
										function (_v0) {
											return A2($author$project$Update$toLayout, name, model);
										},
										function (_v1) {
											return l;
										});
								},
								s.cb)
						});
				},
				model));
		return _Utils_Tuple2(
			newModel,
			$author$project$Ports$saveSchema(newModel.c4));
	});
var $author$project$Update$getArea = function (canvas) {
	return {bn: (canvas.df.bX - canvas.U.dw) / canvas.dG, cc: (0 - canvas.U.cc) / canvas.dG, c2: (canvas.df.dD - canvas.U.cc) / canvas.dG, dw: (0 - canvas.U.dw) / canvas.dG};
};
var $author$project$Libs$Std$maybeFilter = F2(
	function (predicate, maybe) {
		return A2(
			$elm$core$Maybe$andThen,
			function (a) {
				return A3(
					$author$project$Libs$Std$cond,
					predicate(a),
					function (_v0) {
						return maybe;
					},
					function (_v1) {
						return $elm$core$Maybe$Nothing;
					});
			},
			maybe);
	});
var $author$project$Update$getInitializingTable = F2(
	function (id, tables) {
		return A2(
			$author$project$Libs$Std$maybeFilter,
			function (t) {
				return t.a6.di === 1;
			},
			A2($pzp1997$assoc_list$AssocList$get, id, tables));
	});
var $author$project$Models$InitializedTable = F3(
	function (a, b, c) {
		return {$: 14, a: a, b: b, c: c};
	});
var $elm$random$Random$Generate = $elm$core$Basics$identity;
var $elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$random$Random$next = function (_v0) {
	var state0 = _v0.a;
	var incr = _v0.b;
	return A2($elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var $elm$random$Random$initialSeed = function (x) {
	var _v0 = $elm$random$Random$next(
		A2($elm$random$Random$Seed, 0, 1013904223));
	var state1 = _v0.a;
	var incr = _v0.b;
	var state2 = (state1 + x) >>> 0;
	return $elm$random$Random$next(
		A2($elm$random$Random$Seed, state2, incr));
};
var $elm$time$Time$Name = function (a) {
	return {$: 0, a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 1, a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $elm$time$Time$posixToMillis = function (_v0) {
	var millis = _v0;
	return millis;
};
var $elm$random$Random$init = A2(
	$elm$core$Task$andThen,
	function (time) {
		return $elm$core$Task$succeed(
			$elm$random$Random$initialSeed(
				$elm$time$Time$posixToMillis(time)));
	},
	$elm$time$Time$now);
var $elm$random$Random$step = F2(
	function (_v0, seed) {
		var generator = _v0;
		return generator(seed);
	});
var $elm$random$Random$onEffects = F3(
	function (router, commands, seed) {
		if (!commands.b) {
			return $elm$core$Task$succeed(seed);
		} else {
			var generator = commands.a;
			var rest = commands.b;
			var _v1 = A2($elm$random$Random$step, generator, seed);
			var value = _v1.a;
			var newSeed = _v1.b;
			return A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$random$Random$onEffects, router, rest, newSeed);
				},
				A2($elm$core$Platform$sendToApp, router, value));
		}
	});
var $elm$random$Random$onSelfMsg = F3(
	function (_v0, _v1, seed) {
		return $elm$core$Task$succeed(seed);
	});
var $elm$random$Random$Generator = $elm$core$Basics$identity;
var $elm$random$Random$map = F2(
	function (func, _v0) {
		var genA = _v0;
		return function (seed0) {
			var _v1 = genA(seed0);
			var a = _v1.a;
			var seed1 = _v1.b;
			return _Utils_Tuple2(
				func(a),
				seed1);
		};
	});
var $elm$random$Random$cmdMap = F2(
	function (func, _v0) {
		var generator = _v0;
		return A2($elm$random$Random$map, func, generator);
	});
_Platform_effectManagers['Random'] = _Platform_createManager($elm$random$Random$init, $elm$random$Random$onEffects, $elm$random$Random$onSelfMsg, $elm$random$Random$cmdMap);
var $elm$random$Random$command = _Platform_leaf('Random');
var $elm$random$Random$generate = F2(
	function (tagger, generator) {
		return $elm$random$Random$command(
			A2($elm$random$Random$map, tagger, generator));
	});
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $elm$random$Random$peel = function (_v0) {
	var state = _v0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var $elm$random$Random$float = F2(
	function (a, b) {
		return function (seed0) {
			var seed1 = $elm$random$Random$next(seed0);
			var range = $elm$core$Basics$abs(b - a);
			var n1 = $elm$random$Random$peel(seed1);
			var n0 = $elm$random$Random$peel(seed0);
			var lo = (134217727 & n1) * 1.0;
			var hi = (67108863 & n0) * 1.0;
			var val = ((hi * 134217728.0) + lo) / 9007199254740992.0;
			var scaled = (val * range) + a;
			return _Utils_Tuple2(
				scaled,
				$elm$random$Random$next(seed1));
		};
	});
var $elm$random$Random$map2 = F3(
	function (func, _v0, _v1) {
		var genA = _v0;
		var genB = _v1;
		return function (seed0) {
			var _v2 = genA(seed0);
			var a = _v2.a;
			var seed1 = _v2.b;
			var _v3 = genB(seed1);
			var b = _v3.a;
			var seed2 = _v3.b;
			return _Utils_Tuple2(
				A2(func, a, b),
				seed2);
		};
	});
var $author$project$Commands$InitializeTable$positionGen = F2(
	function (size, area) {
		return A3(
			$elm$random$Random$map2,
			F2(
				function (left, top) {
					return A2($author$project$Models$Utils$Position, left, top);
				}),
			A2($elm$random$Random$float, area.cc, area.c2 - size.dD),
			A2($elm$random$Random$float, area.dw, area.bn - size.bX));
	});
var $author$project$Commands$InitializeTable$initializeTable = F3(
	function (size, area, id) {
		return A2(
			$elm$random$Random$generate,
			A2($author$project$Models$InitializedTable, id, size),
			A2($author$project$Commands$InitializeTable$positionGen, size, area));
	});
var $author$project$Update$maybeChangeCmd = F2(
	function (model, _v0) {
		var id = _v0.b_;
		var size = _v0.df;
		return A2(
			$elm$core$Maybe$map,
			function (t) {
				return A3(
					$author$project$Commands$InitializeTable$initializeTable,
					size,
					$author$project$Update$getArea(model.bq),
					t.b_);
			},
			A2(
				$author$project$Update$getInitializingTable,
				$author$project$Views$Helpers$parseTableId(id),
				model.c4.dp));
	});
var $author$project$Update$setSize = F2(
	function (transform, item) {
		return _Utils_update(
			item,
			{
				df: transform(item.df)
			});
	});
var $author$project$Update$updateSize = F2(
	function (change, model) {
		return _Utils_eq(change.b_, $author$project$Conf$conf.b0.bL) ? _Utils_update(
			model,
			{
				bq: A2(
					$author$project$Update$setSize,
					function (_v0) {
						return change.df;
					},
					model.bq)
			}) : _Utils_update(
			model,
			{
				c4: A3(
					$author$project$Update$visitTable,
					$author$project$Views$Helpers$parseTableId(change.b_),
					$author$project$Libs$Std$setState(
						function (state) {
							return _Utils_update(
								state,
								{df: change.df});
						}),
					model.c4)
			});
	});
var $author$project$Update$updateSizes = F2(
	function (sizeChanges, model) {
		return _Utils_Tuple2(
			A3($elm$core$List$foldr, $author$project$Update$updateSize, model, sizeChanges),
			$elm$core$Platform$Cmd$batch(
				A2(
					$elm$core$List$filterMap,
					$author$project$Update$maybeChangeCmd(model),
					sizeChanges)));
	});
var $author$project$Update$useSchema = F2(
	function (schema, model) {
		return A2(
			$author$project$Update$loadSchema,
			model,
			_Utils_Tuple2(_List_Nil, schema));
	});
var $elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var $author$project$Update$zoomCanvas = F2(
	function (wheel, canvas) {
		var newZoom = A3($elm$core$Basics$clamp, $author$project$Conf$conf.dG.ck, $author$project$Conf$conf.dG.cf, canvas.dG + (wheel.bF.bg * $author$project$Conf$conf.dG.dg));
		var zoomFactor = newZoom / canvas.dG;
		var newTop = canvas.U.dw - ((wheel.cm.bg - canvas.U.dw) * (zoomFactor - 1));
		var newLeft = canvas.U.cc - ((wheel.cm.bf - canvas.U.cc) * (zoomFactor - 1));
		return _Utils_update(
			canvas,
			{
				U: A2($author$project$Models$Utils$Position, newLeft, newTop),
				dG: newZoom
			});
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 0:
				return _Utils_Tuple2(
					model,
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								$author$project$Ports$showModal($author$project$Conf$conf.b0.c6),
								$author$project$Ports$hideOffcanvas($author$project$Conf$conf.b0.cg)
							])));
			case 1:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 2:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 3:
				var file = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							X: A2(
								$author$project$Libs$Std$set,
								function (s) {
									return _Utils_update(
										s,
										{cd: true});
								},
								model.X)
						}),
					$author$project$Ports$readFile(file));
			case 4:
				var file = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							X: A2(
								$author$project$Libs$Std$set,
								function (s) {
									return _Utils_update(
										s,
										{cd: true});
								},
								model.X)
						}),
					$author$project$Ports$readFile(file));
			case 5:
				var _v1 = msg.a;
				var file = _v1.a;
				var content = _v1.b;
				return A3($author$project$Update$createSchema, file, content, model);
			case 6:
				var sampleName = msg.a;
				return _Utils_Tuple2(
					model,
					$author$project$Commands$FetchSample$loadSample(sampleName));
			case 7:
				var name = msg.a;
				var path = msg.b;
				var response = msg.c;
				return A4($author$project$Update$createSampleSchema, name, path, response, model);
			case 8:
				var _v2 = msg.a;
				var errors = _v2.a;
				var schemas = _v2.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{dl: schemas}),
					$elm$core$Platform$Cmd$batch(
						A2(
							$elm$core$List$map,
							function (_v3) {
								var name = _v3.a;
								var err = _v3.b;
								return $author$project$Ports$toastError(
									'Unable to read schema <b>' + (name + ('</b>:<br>' + $author$project$Views$Helpers$decodeErrorToHtml(err))));
							},
							errors)));
			case 9:
				var schema = msg.a;
				return A2($author$project$Update$useSchema, schema, model);
			case 10:
				var search = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							a6: A2(
								$author$project$Libs$Std$set,
								function (state) {
									return _Utils_update(
										state,
										{c8: search});
								},
								model.a6)
						}),
					$elm$core$Platform$Cmd$none);
			case 11:
				var id = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: A2(
								$author$project$Update$visitTables,
								function (table) {
									return A2(
										$author$project$Libs$Std$setState,
										function (state) {
											return _Utils_update(
												state,
												{
													da: A3(
														$author$project$Libs$Std$cond,
														_Utils_eq(table.b_, id),
														function (_v4) {
															return !state.da;
														},
														function (_v5) {
															return false;
														})
												});
										},
										table);
								},
								model.c4)
						}),
					$elm$core$Platform$Cmd$none);
			case 12:
				var id = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: A2($author$project$Update$hideTable, id, model.c4)
						}),
					$elm$core$Platform$Cmd$none);
			case 13:
				var id = msg.a;
				return A2($author$project$Update$showTable, model, id);
			case 14:
				var id = msg.a;
				var size = msg.b;
				var position = msg.c;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: A3(
								$author$project$Update$visitTable,
								id,
								$author$project$Libs$Std$setState(
									function (state) {
										return _Utils_update(
											state,
											{U: position, df: size, di: 3});
									}),
								model.c4)
						}),
					$elm$core$Platform$Cmd$none);
			case 15:
				var sizes = msg.a;
				return A2($author$project$Update$updateSizes, sizes, model);
			case 16:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: $author$project$Update$hideAllTables(model.c4)
						}),
					$elm$core$Platform$Cmd$none);
			case 17:
				return $author$project$Update$showAllTables(model);
			case 18:
				var ref = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: A3(
								$author$project$Update$visitTable,
								ref.bb,
								function (table) {
									return _Utils_update(
										table,
										{
											N: A2($author$project$Update$hideColumn, ref.ap, table.N)
										});
								},
								model.c4)
						}),
					$author$project$Ports$activateTooltipsAndPopovers(0));
			case 19:
				var ref = msg.a;
				var index = msg.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							c4: A3(
								$author$project$Update$visitTable,
								ref.bb,
								function (table) {
									return _Utils_update(
										table,
										{
											N: A3($author$project$Update$showColumn, ref.ap, index, table.N)
										});
								},
								model.c4)
						}),
					$author$project$Ports$activateTooltipsAndPopovers(0));
			case 20:
				var zoom = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							bq: A2($author$project$Update$zoomCanvas, zoom, model.bq)
						}),
					$elm$core$Platform$Cmd$none);
			case 21:
				var dragMsg = msg.a;
				return A2(
					$elm$core$Tuple$mapFirst,
					function (newState) {
						return _Utils_update(
							model,
							{a6: newState});
					},
					A3($zaboco$elm_draggable$Draggable$update, $author$project$Update$dragConfig, dragMsg, model.a6));
			case 22:
				var id = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							a6: A2(
								$author$project$Libs$Std$set,
								function (state) {
									return _Utils_update(
										state,
										{
											av: $elm$core$Maybe$Just(id)
										});
								},
								model.a6)
						}),
					$elm$core$Platform$Cmd$none);
			case 23:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							a6: A2(
								$author$project$Libs$Std$set,
								function (state) {
									return _Utils_update(
										state,
										{av: $elm$core$Maybe$Nothing});
								},
								model.a6)
						}),
					$elm$core$Platform$Cmd$none);
			case 24:
				var delta = msg.a;
				return A2($author$project$Update$dragItem, model, delta);
			case 25:
				var name = msg.a;
				return _Utils_Tuple2(
					A2(
						$author$project$Libs$Std$setState,
						function (s) {
							return _Utils_update(
								s,
								{
									cr: A3(
										$author$project$Libs$Std$cond,
										!$elm$core$String$length(name),
										function (_v6) {
											return $elm$core$Maybe$Nothing;
										},
										function (_v7) {
											return $elm$core$Maybe$Just(name);
										})
								});
						},
						model),
					$elm$core$Platform$Cmd$none);
			case 26:
				var name = msg.a;
				return A2($author$project$Update$createLayout, name, model);
			case 27:
				var name = msg.a;
				return A2($author$project$Update$loadLayout, name, model);
			case 28:
				var name = msg.a;
				return A2($author$project$Update$updateLayout, name, model);
			case 29:
				var name = msg.a;
				return A2($author$project$Update$deleteLayout, name, model);
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
};
var $elm$html$Html$node = $elm$virtual_dom$VirtualDom$node;
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $lattyware$elm_fontawesome$FontAwesome$Styles$css = A3(
	$elm$html$Html$node,
	'style',
	_List_Nil,
	_List_fromArray(
		[
			$elm$html$Html$text('svg:not(:root).svg-inline--fa {  overflow: visible;}.svg-inline--fa {  display: inline-block;  font-size: inherit;  height: 1em;  overflow: visible;  vertical-align: -0.125em;}.svg-inline--fa.fa-lg {  vertical-align: -0.225em;}.svg-inline--fa.fa-w-1 {  width: 0.0625em;}.svg-inline--fa.fa-w-2 {  width: 0.125em;}.svg-inline--fa.fa-w-3 {  width: 0.1875em;}.svg-inline--fa.fa-w-4 {  width: 0.25em;}.svg-inline--fa.fa-w-5 {  width: 0.3125em;}.svg-inline--fa.fa-w-6 {  width: 0.375em;}.svg-inline--fa.fa-w-7 {  width: 0.4375em;}.svg-inline--fa.fa-w-8 {  width: 0.5em;}.svg-inline--fa.fa-w-9 {  width: 0.5625em;}.svg-inline--fa.fa-w-10 {  width: 0.625em;}.svg-inline--fa.fa-w-11 {  width: 0.6875em;}.svg-inline--fa.fa-w-12 {  width: 0.75em;}.svg-inline--fa.fa-w-13 {  width: 0.8125em;}.svg-inline--fa.fa-w-14 {  width: 0.875em;}.svg-inline--fa.fa-w-15 {  width: 0.9375em;}.svg-inline--fa.fa-w-16 {  width: 1em;}.svg-inline--fa.fa-w-17 {  width: 1.0625em;}.svg-inline--fa.fa-w-18 {  width: 1.125em;}.svg-inline--fa.fa-w-19 {  width: 1.1875em;}.svg-inline--fa.fa-w-20 {  width: 1.25em;}.svg-inline--fa.fa-pull-left {  margin-right: 0.3em;  width: auto;}.svg-inline--fa.fa-pull-right {  margin-left: 0.3em;  width: auto;}.svg-inline--fa.fa-border {  height: 1.5em;}.svg-inline--fa.fa-li {  width: 2em;}.svg-inline--fa.fa-fw {  width: 1.25em;}.fa-layers svg.svg-inline--fa {  bottom: 0;  left: 0;  margin: auto;  position: absolute;  right: 0;  top: 0;}.fa-layers {  display: inline-block;  height: 1em;  position: relative;  text-align: center;  vertical-align: -0.125em;  width: 1em;}.fa-layers svg.svg-inline--fa {  -webkit-transform-origin: center center;          transform-origin: center center;}.fa-layers-counter, .fa-layers-text {  display: inline-block;  position: absolute;  text-align: center;}.fa-layers-text {  left: 50%;  top: 50%;  -webkit-transform: translate(-50%, -50%);          transform: translate(-50%, -50%);  -webkit-transform-origin: center center;          transform-origin: center center;}.fa-layers-counter {  background-color: #ff253a;  border-radius: 1em;  -webkit-box-sizing: border-box;          box-sizing: border-box;  color: #fff;  height: 1.5em;  line-height: 1;  max-width: 5em;  min-width: 1.5em;  overflow: hidden;  padding: 0.25em;  right: 0;  text-overflow: ellipsis;  top: 0;  -webkit-transform: scale(0.25);          transform: scale(0.25);  -webkit-transform-origin: top right;          transform-origin: top right;}.fa-layers-bottom-right {  bottom: 0;  right: 0;  top: auto;  -webkit-transform: scale(0.25);          transform: scale(0.25);  -webkit-transform-origin: bottom right;          transform-origin: bottom right;}.fa-layers-bottom-left {  bottom: 0;  left: 0;  right: auto;  top: auto;  -webkit-transform: scale(0.25);          transform: scale(0.25);  -webkit-transform-origin: bottom left;          transform-origin: bottom left;}.fa-layers-top-right {  right: 0;  top: 0;  -webkit-transform: scale(0.25);          transform: scale(0.25);  -webkit-transform-origin: top right;          transform-origin: top right;}.fa-layers-top-left {  left: 0;  right: auto;  top: 0;  -webkit-transform: scale(0.25);          transform: scale(0.25);  -webkit-transform-origin: top left;          transform-origin: top left;}.fa-lg {  font-size: 1.3333333333em;  line-height: 0.75em;  vertical-align: -0.0667em;}.fa-xs {  font-size: 0.75em;}.fa-sm {  font-size: 0.875em;}.fa-1x {  font-size: 1em;}.fa-2x {  font-size: 2em;}.fa-3x {  font-size: 3em;}.fa-4x {  font-size: 4em;}.fa-5x {  font-size: 5em;}.fa-6x {  font-size: 6em;}.fa-7x {  font-size: 7em;}.fa-8x {  font-size: 8em;}.fa-9x {  font-size: 9em;}.fa-10x {  font-size: 10em;}.fa-fw {  text-align: center;  width: 1.25em;}.fa-ul {  list-style-type: none;  margin-left: 2.5em;  padding-left: 0;}.fa-ul > li {  position: relative;}.fa-li {  left: -2em;  position: absolute;  text-align: center;  width: 2em;  line-height: inherit;}.fa-border {  border: solid 0.08em #eee;  border-radius: 0.1em;  padding: 0.2em 0.25em 0.15em;}.fa-pull-left {  float: left;}.fa-pull-right {  float: right;}.fa.fa-pull-left,.fas.fa-pull-left,.far.fa-pull-left,.fal.fa-pull-left,.fab.fa-pull-left {  margin-right: 0.3em;}.fa.fa-pull-right,.fas.fa-pull-right,.far.fa-pull-right,.fal.fa-pull-right,.fab.fa-pull-right {  margin-left: 0.3em;}.fa-spin {  -webkit-animation: fa-spin 2s infinite linear;          animation: fa-spin 2s infinite linear;}.fa-pulse {  -webkit-animation: fa-spin 1s infinite steps(8);          animation: fa-spin 1s infinite steps(8);}@-webkit-keyframes fa-spin {  0% {    -webkit-transform: rotate(0deg);            transform: rotate(0deg);  }  100% {    -webkit-transform: rotate(360deg);            transform: rotate(360deg);  }}@keyframes fa-spin {  0% {    -webkit-transform: rotate(0deg);            transform: rotate(0deg);  }  100% {    -webkit-transform: rotate(360deg);            transform: rotate(360deg);  }}.fa-rotate-90 {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=1)\";  -webkit-transform: rotate(90deg);          transform: rotate(90deg);}.fa-rotate-180 {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=2)\";  -webkit-transform: rotate(180deg);          transform: rotate(180deg);}.fa-rotate-270 {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=3)\";  -webkit-transform: rotate(270deg);          transform: rotate(270deg);}.fa-flip-horizontal {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=0, mirror=1)\";  -webkit-transform: scale(-1, 1);          transform: scale(-1, 1);}.fa-flip-vertical {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=2, mirror=1)\";  -webkit-transform: scale(1, -1);          transform: scale(1, -1);}.fa-flip-both, .fa-flip-horizontal.fa-flip-vertical {  -ms-filter: \"progid:DXImageTransform.Microsoft.BasicImage(rotation=2, mirror=1)\";  -webkit-transform: scale(-1, -1);          transform: scale(-1, -1);}:root .fa-rotate-90,:root .fa-rotate-180,:root .fa-rotate-270,:root .fa-flip-horizontal,:root .fa-flip-vertical,:root .fa-flip-both {  -webkit-filter: none;          filter: none;}.fa-stack {  display: inline-block;  height: 2em;  position: relative;  width: 2.5em;}.fa-stack-1x,.fa-stack-2x {  bottom: 0;  left: 0;  margin: auto;  position: absolute;  right: 0;  top: 0;}.svg-inline--fa.fa-stack-1x {  height: 1em;  width: 1.25em;}.svg-inline--fa.fa-stack-2x {  height: 2em;  width: 2.5em;}.fa-inverse {  color: #fff;}.sr-only {  border: 0;  clip: rect(0, 0, 0, 0);  height: 1px;  margin: -1px;  overflow: hidden;  padding: 0;  position: absolute;  width: 1px;}.sr-only-focusable:active, .sr-only-focusable:focus {  clip: auto;  height: auto;  margin: 0;  overflow: visible;  position: static;  width: auto;}.svg-inline--fa .fa-primary {  fill: var(--fa-primary-color, currentColor);  opacity: 1;  opacity: var(--fa-primary-opacity, 1);}.svg-inline--fa .fa-secondary {  fill: var(--fa-secondary-color, currentColor);  opacity: 0.4;  opacity: var(--fa-secondary-opacity, 0.4);}.svg-inline--fa.fa-swap-opacity .fa-primary {  opacity: 0.4;  opacity: var(--fa-secondary-opacity, 0.4);}.svg-inline--fa.fa-swap-opacity .fa-secondary {  opacity: 1;  opacity: var(--fa-primary-opacity, 1);}.svg-inline--fa mask .fa-primary,.svg-inline--fa mask .fa-secondary {  fill: black;}.fad.fa-inverse {  color: #fff;}')
		]));
var $author$project$Models$Zoom = function (a) {
	return {$: 20, a: a};
};
var $author$project$View$getTableAndColumn = F2(
	function (ref, schema) {
		return A2(
			$elm$core$Maybe$andThen,
			function (table) {
				return A2(
					$elm$core$Maybe$map,
					function (column) {
						return {ap: column, bb: table};
					},
					A2($pzp1997$assoc_list$AssocList$get, ref.ap, table.N));
			},
			A2($pzp1997$assoc_list$AssocList$get, ref.bb, schema.dp));
	});
var $elm$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		if (ma.$ === 1) {
			return $elm$core$Maybe$Nothing;
		} else {
			var a = ma.a;
			if (mb.$ === 1) {
				return $elm$core$Maybe$Nothing;
			} else {
				var b = mb.a;
				return $elm$core$Maybe$Just(
					A2(func, a, b));
			}
		}
	});
var $author$project$View$buildRelation = F2(
	function (schema, rel) {
		return A3(
			$elm$core$Maybe$map2,
			F2(
				function (from, to) {
					return {b7: rel.b7, cZ: to, dh: from, a6: rel.a6};
				}),
			A2($author$project$View$getTableAndColumn, rel.dh, schema),
			A2($author$project$View$getTableAndColumn, rel.cZ, schema));
	});
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $zaboco$elm_draggable$Draggable$alwaysPreventDefaultAndStopPropagation = function (msg) {
	return {aJ: msg, aV: true, a7: true};
};
var $zaboco$elm_draggable$Internal$StartDragging = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $zaboco$elm_draggable$Draggable$baseDecoder = function (key) {
	return A2(
		$elm$json$Json$Decode$map,
		A2(
			$elm$core$Basics$composeL,
			$elm$core$Basics$identity,
			$zaboco$elm_draggable$Internal$StartDragging(key)),
		$zaboco$elm_draggable$Draggable$positionDecoder);
};
var $elm$virtual_dom$VirtualDom$Custom = function (a) {
	return {$: 3, a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$custom = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Custom(decoder));
	});
var $zaboco$elm_draggable$Draggable$whenLeftMouseButtonPressed = function (decoder) {
	return A2(
		$elm$json$Json$Decode$andThen,
		function (button) {
			if (!button) {
				return decoder;
			} else {
				return $elm$json$Json$Decode$fail('Event is only relevant when the main mouse button was pressed.');
			}
		},
		A2($elm$json$Json$Decode$field, 'button', $elm$json$Json$Decode$int));
};
var $zaboco$elm_draggable$Draggable$mouseTrigger = F2(
	function (key, envelope) {
		return A2(
			$elm$html$Html$Events$custom,
			'mousedown',
			A2(
				$elm$json$Json$Decode$map,
				A2($elm$core$Basics$composeL, $zaboco$elm_draggable$Draggable$alwaysPreventDefaultAndStopPropagation, envelope),
				$zaboco$elm_draggable$Draggable$whenLeftMouseButtonPressed(
					$zaboco$elm_draggable$Draggable$baseDecoder(key))));
	});
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$defaultOptions = {aV: true, a7: false};
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$Event = F4(
	function (keys, changedTouches, targetTouches, touches) {
		return {bt: changedTouches, b8: keys, dr: targetTouches, dx: touches};
	});
var $mpizenberg$elm_pointer_events$Internal$Decode$Keys = F3(
	function (alt, ctrl, shift) {
		return {bk: alt, bA: ctrl, dc: shift};
	});
var $mpizenberg$elm_pointer_events$Internal$Decode$keys = A4(
	$elm$json$Json$Decode$map3,
	$mpizenberg$elm_pointer_events$Internal$Decode$Keys,
	A2($elm$json$Json$Decode$field, 'altKey', $elm$json$Json$Decode$bool),
	A2($elm$json$Json$Decode$field, 'ctrlKey', $elm$json$Json$Decode$bool),
	A2($elm$json$Json$Decode$field, 'shiftKey', $elm$json$Json$Decode$bool));
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$Touch = F4(
	function (identifier, clientPos, pagePos, screenPos) {
		return {bv: clientPos, b$: identifier, cQ: pagePos, c7: screenPos};
	});
var $mpizenberg$elm_pointer_events$Internal$Decode$clientPos = A3(
	$elm$json$Json$Decode$map2,
	F2(
		function (a, b) {
			return _Utils_Tuple2(a, b);
		}),
	A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'clientY', $elm$json$Json$Decode$float));
var $mpizenberg$elm_pointer_events$Internal$Decode$pagePos = A3(
	$elm$json$Json$Decode$map2,
	F2(
		function (a, b) {
			return _Utils_Tuple2(a, b);
		}),
	A2($elm$json$Json$Decode$field, 'pageX', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'pageY', $elm$json$Json$Decode$float));
var $mpizenberg$elm_pointer_events$Internal$Decode$screenPos = A3(
	$elm$json$Json$Decode$map2,
	F2(
		function (a, b) {
			return _Utils_Tuple2(a, b);
		}),
	A2($elm$json$Json$Decode$field, 'screenX', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'screenY', $elm$json$Json$Decode$float));
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchDecoder = A5(
	$elm$json$Json$Decode$map4,
	$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$Touch,
	A2($elm$json$Json$Decode$field, 'identifier', $elm$json$Json$Decode$int),
	$mpizenberg$elm_pointer_events$Internal$Decode$clientPos,
	$mpizenberg$elm_pointer_events$Internal$Decode$pagePos,
	$mpizenberg$elm_pointer_events$Internal$Decode$screenPos);
var $mpizenberg$elm_pointer_events$Internal$Decode$all = A2(
	$elm$core$List$foldr,
	$elm$json$Json$Decode$map2($elm$core$List$cons),
	$elm$json$Json$Decode$succeed(_List_Nil));
var $mpizenberg$elm_pointer_events$Internal$Decode$dynamicListOf = function (itemDecoder) {
	var decodeOne = function (n) {
		return A2(
			$elm$json$Json$Decode$field,
			$elm$core$String$fromInt(n),
			itemDecoder);
	};
	var decodeN = function (n) {
		return $mpizenberg$elm_pointer_events$Internal$Decode$all(
			A2(
				$elm$core$List$map,
				decodeOne,
				A2($elm$core$List$range, 0, n - 1)));
	};
	return A2(
		$elm$json$Json$Decode$andThen,
		decodeN,
		A2($elm$json$Json$Decode$field, 'length', $elm$json$Json$Decode$int));
};
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchListDecoder = $mpizenberg$elm_pointer_events$Internal$Decode$dynamicListOf;
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$eventDecoder = A5(
	$elm$json$Json$Decode$map4,
	$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$Event,
	$mpizenberg$elm_pointer_events$Internal$Decode$keys,
	A2(
		$elm$json$Json$Decode$field,
		'changedTouches',
		$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchListDecoder($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'targetTouches',
		$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchListDecoder($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'touches',
		$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchListDecoder($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$touchDecoder)));
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onWithOptions = F3(
	function (event, options, tag) {
		return A2(
			$elm$html$Html$Events$custom,
			event,
			A2(
				$elm$json$Json$Decode$map,
				function (ev) {
					return {
						aJ: tag(ev),
						aV: options.aV,
						a7: options.a7
					};
				},
				$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$eventDecoder));
	});
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onEnd = A2($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onWithOptions, 'touchend', $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$defaultOptions);
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onMove = A2($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onWithOptions, 'touchmove', $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$defaultOptions);
var $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onStart = A2($mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onWithOptions, 'touchstart', $mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$defaultOptions);
var $elm$core$Basics$round = _Basics_round;
var $zaboco$elm_draggable$Draggable$touchTriggers = F2(
	function (key, envelope) {
		var touchToMouse = function (touchEvent) {
			return function (_v1) {
				var clientX = _v1.a;
				var clientY = _v1.b;
				return A2(
					$zaboco$elm_draggable$Internal$Position,
					$elm$core$Basics$round(clientX),
					$elm$core$Basics$round(clientY));
			}(
				A2(
					$elm$core$Maybe$withDefault,
					_Utils_Tuple2(0, 0),
					A2(
						$elm$core$Maybe$map,
						function ($) {
							return $.bv;
						},
						$elm$core$List$head(touchEvent.bt))));
		};
		var mouseToEnv = function (internal) {
			return A2(
				$elm$core$Basics$composeR,
				touchToMouse,
				A2(
					$elm$core$Basics$composeR,
					internal,
					A2($elm$core$Basics$composeR, $elm$core$Basics$identity, envelope)));
		};
		return _List_fromArray(
			[
				$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onStart(
				mouseToEnv(
					$zaboco$elm_draggable$Internal$StartDragging(key))),
				$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onMove(
				mouseToEnv($zaboco$elm_draggable$Internal$DragAt)),
				$mpizenberg$elm_pointer_events$Html$Events$Extra$Touch$onEnd(
				mouseToEnv(
					function (_v0) {
						return $zaboco$elm_draggable$Internal$StopDragging;
					}))
			]);
	});
var $author$project$Views$Helpers$dragAttrs = function (id) {
	return A2(
		$elm$core$List$cons,
		A2($zaboco$elm_draggable$Draggable$mouseTrigger, id, $author$project$Models$DragMsg),
		A2($zaboco$elm_draggable$Draggable$touchTriggers, id, $author$project$Models$DragMsg));
};
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $author$project$View$incomingTableRelations = F2(
	function (relations, table) {
		return A2(
			$elm$core$List$filter,
			function (r) {
				return _Utils_eq(r.cZ.bb.b_, table.b_);
			},
			relations);
	});
var $author$project$Libs$Std$listFilterMap = F3(
	function (predicate, transform, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (a, res) {
					return A3(
						$author$project$Libs$Std$cond,
						predicate(a),
						function (_v0) {
							return A2(
								$elm$core$List$cons,
								transform(a),
								res);
						},
						function (_v1) {
							return res;
						});
				}),
			_List_Nil,
			list);
	});
var $author$project$Libs$Std$WheelEvent = F3(
	function (delta, mouse, keys) {
		return {bF: delta, b8: keys, cm: mouse};
	});
var $author$project$Libs$Std$onWheel = function (callback) {
	var preventDefaultAndStopPropagation = function (msg) {
		return {aJ: msg, aV: true, a7: true};
	};
	var decoder = A2(
		$elm$json$Json$Decode$map,
		callback,
		A4(
			$elm$json$Json$Decode$map3,
			$author$project$Libs$Std$WheelEvent,
			A4(
				$elm$json$Json$Decode$map3,
				F3(
					function (x, y, z) {
						return {bf: x, bg: y, dF: z};
					}),
				A2($elm$json$Json$Decode$field, 'deltaX', $elm$json$Json$Decode$float),
				A2($elm$json$Json$Decode$field, 'deltaY', $elm$json$Json$Decode$float),
				A2($elm$json$Json$Decode$field, 'deltaZ', $elm$json$Json$Decode$float)),
			A3(
				$elm$json$Json$Decode$map2,
				F2(
					function (x, y) {
						return {bf: x, bg: y};
					}),
				A2($elm$json$Json$Decode$field, 'pageX', $elm$json$Json$Decode$float),
				A2($elm$json$Json$Decode$field, 'pageY', $elm$json$Json$Decode$float)),
			A5(
				$elm$json$Json$Decode$map4,
				F4(
					function (ctrl, alt, shift, meta) {
						return {bk: alt, bA: ctrl, ch: meta, dc: shift};
					}),
				A2($elm$json$Json$Decode$field, 'ctrlKey', $elm$json$Json$Decode$bool),
				A2($elm$json$Json$Decode$field, 'altKey', $elm$json$Json$Decode$bool),
				A2($elm$json$Json$Decode$field, 'shiftKey', $elm$json$Json$Decode$bool),
				A2($elm$json$Json$Decode$field, 'metaKey', $elm$json$Json$Decode$bool))));
	return A2(
		$elm$html$Html$Events$custom,
		'wheel',
		A2($elm$json$Json$Decode$map, preventDefaultAndStopPropagation, decoder));
};
var $elm$core$String$fromFloat = _String_fromNumber;
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$View$placeAndZoom = F2(
	function (zoom, pan) {
		return A2(
			$elm$html$Html$Attributes$style,
			'transform',
			'translate(' + ($elm$core$String$fromFloat(pan.cc) + ('px, ' + ($elm$core$String$fromFloat(pan.dw) + ('px) scale(' + ($elm$core$String$fromFloat(zoom) + ')'))))));
	});
var $author$project$View$shouldDrawRelation = function (relation) {
	return relation.a6.dd && function () {
		var _v0 = _Utils_Tuple2(relation.dh.bb.a6.di, relation.cZ.bb.a6.di);
		if (_v0.a === 3) {
			if (_v0.b === 3) {
				var _v1 = _v0.a;
				var _v2 = _v0.b;
				return (!_Utils_eq(relation.dh.ap.a6.cP, $elm$core$Maybe$Nothing)) && (!_Utils_eq(relation.cZ.ap.a6.cP, $elm$core$Maybe$Nothing));
			} else {
				var _v3 = _v0.a;
				return !_Utils_eq(relation.dh.ap.a6.cP, $elm$core$Maybe$Nothing);
			}
		} else {
			if (_v0.b === 3) {
				var _v4 = _v0.b;
				return !_Utils_eq(relation.cZ.ap.a6.cP, $elm$core$Maybe$Nothing);
			} else {
				return false;
			}
		}
	}();
};
var $author$project$View$shouldDrawTable = function (table) {
	var _v0 = table.a6.di;
	switch (_v0) {
		case 0:
			return false;
		case 2:
			return false;
		case 1:
			return true;
		default:
			return true;
	}
};
var $elm$html$Html$Attributes$height = function (n) {
	return A2(
		_VirtualDom_attribute,
		'height',
		$elm$core$String$fromInt(n));
};
var $elm$html$Html$Attributes$width = function (n) {
	return A2(
		_VirtualDom_attribute,
		'width',
		$elm$core$String$fromInt(n));
};
var $author$project$Views$Helpers$sizeAttrs = function (size) {
	return _List_fromArray(
		[
			$elm$html$Html$Attributes$width(
			$elm$core$Basics$round(size.dD)),
			$elm$html$Html$Attributes$height(
			$elm$core$Basics$round(size.bX))
		]);
};
var $elm$svg$Svg$Attributes$class = _VirtualDom_attribute('class');
var $elm$svg$Svg$Attributes$height = _VirtualDom_attribute('height');
var $elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var $author$project$Views$Relations$minus = F2(
	function (p1, p2) {
		return {bf: p1.bf - p2.bf, bg: p1.bg - p2.bg};
	});
var $elm$svg$Svg$Attributes$style = _VirtualDom_attribute('style');
var $elm$svg$Svg$trustedNode = _VirtualDom_nodeNS('http://www.w3.org/2000/svg');
var $elm$svg$Svg$svg = $elm$svg$Svg$trustedNode('svg');
var $elm$svg$Svg$text = $elm$virtual_dom$VirtualDom$text;
var $elm$svg$Svg$line = $elm$svg$Svg$trustedNode('line');
var $author$project$Libs$Std$listAddIf = F3(
	function (predicate, item, list) {
		return predicate ? A2($elm$core$List$cons, item, list) : list;
	});
var $elm$svg$Svg$Attributes$strokeDasharray = _VirtualDom_attribute('stroke-dasharray');
var $elm$svg$Svg$Attributes$x1 = _VirtualDom_attribute('x1');
var $elm$svg$Svg$Attributes$x2 = _VirtualDom_attribute('x2');
var $elm$svg$Svg$Attributes$y1 = _VirtualDom_attribute('y1');
var $elm$svg$Svg$Attributes$y2 = _VirtualDom_attribute('y2');
var $author$project$Views$Relations$viewLine = F4(
	function (p1, p2, optional, color) {
		return A2(
			$elm$svg$Svg$line,
			A3(
				$author$project$Libs$Std$listAddIf,
				optional,
				$elm$svg$Svg$Attributes$strokeDasharray('4'),
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$x1(
						$elm$core$String$fromFloat(p1.bf)),
						$elm$svg$Svg$Attributes$y1(
						$elm$core$String$fromFloat(p1.bg)),
						$elm$svg$Svg$Attributes$x2(
						$elm$core$String$fromFloat(p2.bf)),
						$elm$svg$Svg$Attributes$y2(
						$elm$core$String$fromFloat(p2.bg)),
						$elm$svg$Svg$Attributes$style(
						A2(
							$elm$core$Maybe$withDefault,
							'stroke: #A0AEC0; stroke-width: 2;',
							A2(
								$elm$core$Maybe$map,
								function (c) {
									return 'stroke: var(--tw-' + (c + '); stroke-width: 3;');
								},
								color)))
					])),
			_List_Nil);
	});
var $elm$svg$Svg$Attributes$width = _VirtualDom_attribute('width');
var $author$project$Views$Relations$drawRelation = F5(
	function (src, ref, optional, color, name) {
		var padding = 10;
		var origin = {
			bf: A2($elm$core$Basics$min, src.bf, ref.bf) - padding,
			bg: A2($elm$core$Basics$min, src.bg, ref.bg) - padding
		};
		return A2(
			$elm$svg$Svg$svg,
			_List_fromArray(
				[
					$elm$svg$Svg$Attributes$class('relation'),
					$elm$svg$Svg$Attributes$width(
					$elm$core$String$fromFloat(
						$elm$core$Basics$abs(src.bf - ref.bf) + (padding * 2))),
					$elm$svg$Svg$Attributes$height(
					$elm$core$String$fromFloat(
						$elm$core$Basics$abs(src.bg - ref.bg) + (padding * 2))),
					$elm$svg$Svg$Attributes$style(
					'position: absolute; left: ' + ($elm$core$String$fromFloat(origin.bf) + ('px; top: ' + ($elm$core$String$fromFloat(origin.bg) + 'px;'))))
				]),
			_List_fromArray(
				[
					A4(
					$author$project$Views$Relations$viewLine,
					A2($author$project$Views$Relations$minus, src, origin),
					A2($author$project$Views$Relations$minus, ref, origin),
					optional,
					color),
					$elm$svg$Svg$text(name)
				]));
	});
var $author$project$Views$Relations$formatForeignKeyName = function (_v0) {
	var name = _v0;
	return name;
};
var $author$project$Views$Helpers$withColumnName = F2(
	function (_v0, table) {
		var column = _v0;
		return table + ('.' + column);
	});
var $author$project$Views$Relations$formatRef = F2(
	function (table, column) {
		return A2(
			$author$project$Views$Helpers$withColumnName,
			column.ap,
			$author$project$Views$Helpers$formatTableId(table.b_));
	});
var $author$project$Views$Relations$formatText = F3(
	function (fk, src, ref) {
		return A2($author$project$Views$Relations$formatRef, src.bb, src.ap) + (' -> ' + ($author$project$Views$Relations$formatForeignKeyName(fk) + (' -> ' + A2($author$project$Views$Relations$formatRef, ref.bb, ref.ap))));
	});
var $author$project$Views$Relations$getColor = F2(
	function (src, ref) {
		return ((src.bb.a6.di === 3) && src.bb.a6.da) ? $elm$core$Maybe$Just(src.bb.a6.bw) : (((ref.bb.a6.di === 3) && ref.bb.a6.da) ? $elm$core$Maybe$Just(ref.bb.a6.bw) : $elm$core$Maybe$Nothing);
	});
var $author$project$Views$Relations$tablePositions = function (table) {
	return _Utils_Tuple3(table.a6.U.cc, table.a6.U.cc + (table.a6.df.dD / 2), table.a6.U.cc + table.a6.df.dD);
};
var $author$project$Views$Relations$positionX = F2(
	function (srcTable, refTable) {
		var _v0 = _Utils_Tuple2(
			$author$project$Views$Relations$tablePositions(srcTable),
			$author$project$Views$Relations$tablePositions(refTable));
		var _v1 = _v0.a;
		var srcLeft = _v1.a;
		var srcCenter = _v1.b;
		var srcRight = _v1.c;
		var _v2 = _v0.b;
		var refLeft = _v2.a;
		var refCenter = _v2.b;
		var refRight = _v2.c;
		return (_Utils_cmp(srcRight, refLeft) < 0) ? _Utils_Tuple2(srcRight, refLeft) : ((_Utils_cmp(srcCenter, refCenter) < 0) ? _Utils_Tuple2(srcRight, refRight) : ((_Utils_cmp(srcLeft, refRight) < 0) ? _Utils_Tuple2(srcLeft, refLeft) : _Utils_Tuple2(srcLeft, refRight)));
	});
var $author$project$Views$Relations$columnHeight = 31;
var $author$project$Views$Relations$headerHeight = 48;
var $author$project$Views$Relations$positionY = function (_v0) {
	var table = _v0.bb;
	var column = _v0.ap;
	return (table.a6.U.dw + $author$project$Views$Relations$headerHeight) + ($author$project$Views$Relations$columnHeight * (0.5 + A2($elm$core$Maybe$withDefault, -1, column.a6.cP)));
};
var $author$project$Views$Relations$viewRelation = function (_v0) {
	var key = _v0.b7;
	var src = _v0.dh;
	var ref = _v0.cZ;
	var _v1 = _Utils_Tuple2(
		_Utils_Tuple2(src.bb.a6.di === 3, ref.bb.a6.di === 3),
		_Utils_Tuple2(
			A3($author$project$Views$Relations$formatText, key, src, ref),
			A2($author$project$Views$Relations$getColor, src, ref)));
	if (!_v1.a.a) {
		if (!_v1.a.b) {
			var _v2 = _v1.a;
			var _v3 = _v1.b;
			var name = _v3.a;
			return A2(
				$elm$svg$Svg$svg,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$class('erd-relation')
					]),
				_List_fromArray(
					[
						$elm$svg$Svg$text(name)
					]));
		} else {
			var _v7 = _v1.a;
			var _v8 = _v1.b;
			var name = _v8.a;
			var color = _v8.b;
			var _v9 = {
				bf: ref.bb.a6.U.cc,
				bg: $author$project$Views$Relations$positionY(ref)
			};
			var refPos = _v9;
			return A5(
				$author$project$Views$Relations$drawRelation,
				{bf: refPos.bf - 20, bg: refPos.bg},
				refPos,
				src.ap.cA,
				color,
				name);
		}
	} else {
		if (!_v1.a.b) {
			var _v4 = _v1.a;
			var _v5 = _v1.b;
			var name = _v5.a;
			var color = _v5.b;
			var _v6 = {
				bf: src.bb.a6.U.cc + src.bb.a6.df.dD,
				bg: $author$project$Views$Relations$positionY(src)
			};
			var srcPos = _v6;
			return A5(
				$author$project$Views$Relations$drawRelation,
				srcPos,
				{bf: srcPos.bf + 20, bg: srcPos.bg},
				src.ap.cA,
				color,
				name);
		} else {
			var _v10 = _v1.a;
			var _v11 = _v1.b;
			var name = _v11.a;
			var color = _v11.b;
			var _v12 = _Utils_Tuple2(
				A2($author$project$Views$Relations$positionX, src.bb, ref.bb),
				_Utils_Tuple2(
					$author$project$Views$Relations$positionY(src),
					$author$project$Views$Relations$positionY(ref)));
			var _v13 = _v12.a;
			var srcX = _v13.a;
			var refX = _v13.b;
			var _v14 = _v12.b;
			var srcY = _v14.a;
			var refY = _v14.b;
			return A5(
				$author$project$Views$Relations$drawRelation,
				{bf: srcX, bg: srcY},
				{bf: refX, bg: refY},
				src.ap.cA,
				color,
				name);
		}
	}
};
var $author$project$Views$Bootstrap$Collapse = 3;
var $elm$virtual_dom$VirtualDom$attribute = F2(
	function (key, value) {
		return A2(
			_VirtualDom_attribute,
			_VirtualDom_noOnOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var $elm$html$Html$Attributes$attribute = $elm$virtual_dom$VirtualDom$attribute;
var $author$project$Views$Bootstrap$ariaControls = function (targetId) {
	return A2($elm$html$Html$Attributes$attribute, 'aria-controls', targetId);
};
var $author$project$Views$Bootstrap$ariaExpanded = function (value) {
	if (value) {
		return A2($elm$html$Html$Attributes$attribute, 'aria-expanded', 'true');
	} else {
		return A2($elm$html$Html$Attributes$attribute, 'aria-expanded', 'false');
	}
};
var $author$project$Views$Bootstrap$bsTarget = function (targetId) {
	return A2($elm$html$Html$Attributes$attribute, 'data-bs-target', '#' + targetId);
};
var $author$project$Views$Bootstrap$toggleName = function (toggle) {
	switch (toggle) {
		case 0:
			return 'tooltip';
		case 1:
			return 'dropdown';
		case 2:
			return 'modal';
		case 3:
			return 'collapse';
		default:
			return 'offcanvas';
	}
};
var $author$project$Views$Bootstrap$bsToggle = function (kind) {
	return A2(
		$elm$html$Html$Attributes$attribute,
		'data-bs-toggle',
		$author$project$Views$Bootstrap$toggleName(kind));
};
var $author$project$Views$Bootstrap$bsToggleCollapse = function (targetId) {
	return _List_fromArray(
		[
			$author$project$Views$Bootstrap$bsToggle(3),
			$author$project$Views$Bootstrap$bsTarget(targetId),
			$author$project$Views$Bootstrap$ariaControls(targetId),
			$author$project$Views$Bootstrap$ariaExpanded(false)
		]);
};
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$html$Html$Attributes$classList = function (classes) {
	return $elm$html$Html$Attributes$class(
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2($elm$core$List$filter, $elm$core$Tuple$second, classes))));
};
var $author$project$Libs$Std$divIf = F3(
	function (predicate, attrs, children) {
		return predicate ? A2($elm$html$Html$div, attrs, children) : A2($elm$html$Html$div, _List_Nil, _List_Nil);
	});
var $author$project$Views$Helpers$extractColumnIndex = function (_v0) {
	var index = _v0;
	return index;
};
var $author$project$Views$Tables$filterIncomingColumnRelations = F2(
	function (incomingTableRelations, column) {
		return A2(
			$elm$core$List$filter,
			function (r) {
				return _Utils_eq(r.cZ.ap.ap, column.ap);
			},
			incomingTableRelations);
	});
var $elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _v0) {
				var trues = _v0.a;
				var falses = _v0.b;
				return pred(x) ? _Utils_Tuple2(
					A2($elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2($elm$core$List$cons, x, falses));
			});
		return A3(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var $author$project$Views$Helpers$placeAt = function (p) {
	return A2(
		$elm$html$Html$Attributes$style,
		'transform',
		'translate(' + ($elm$core$String$fromFloat(p.cc) + ('px, ' + ($elm$core$String$fromFloat(p.dw) + 'px)'))));
};
var $author$project$Libs$Std$plural = F4(
	function (count, none, one, many) {
		return (!count) ? none : ((count === 1) ? one : _Utils_ap(
			$elm$core$String$fromInt(count),
			many));
	});
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $author$project$Models$HideColumn = function (a) {
	return {$: 18, a: a};
};
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onDoubleClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'dblclick',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$Models$ShowTable = function (a) {
	return {$: 13, a: a};
};
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$b = _VirtualDom_node('b');
var $author$project$Views$Bootstrap$ariaLabelledBy = function (targetId) {
	return A2($elm$html$Html$Attributes$attribute, 'aria-labelledby', targetId);
};
var $author$project$Views$Bootstrap$Dropdown = 1;
var $author$project$Views$Bootstrap$bsToggleDropdown = function (eltId) {
	return _List_fromArray(
		[
			$author$project$Views$Bootstrap$bsToggle(1),
			$elm$html$Html$Attributes$id(eltId),
			$author$project$Views$Bootstrap$ariaExpanded(false)
		]);
};
var $author$project$Views$Bootstrap$bsDropdown = F4(
	function (dropdownId, contentAttrs, toggleElement, dropdownContent) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('dropdown')
				]),
			_List_fromArray(
				[
					toggleElement(
					$author$project$Views$Bootstrap$bsToggleDropdown(dropdownId)),
					dropdownContent(
					_Utils_ap(
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('dropdown-menu'),
								$author$project$Views$Bootstrap$ariaLabelledBy(dropdownId)
							]),
						contentAttrs))
				]));
	});
var $lattyware$elm_fontawesome$FontAwesome$Icon$Icon = F5(
	function (prefix, name, width, height, paths) {
		return {bX: height, R: name, cR: paths, cV: prefix, dD: width};
	});
var $lattyware$elm_fontawesome$FontAwesome$Solid$externalLinkAlt = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'external-link-alt',
	512,
	512,
	_List_fromArray(
		['M432,320H400a16,16,0,0,0-16,16V448H64V128H208a16,16,0,0,0,16-16V80a16,16,0,0,0-16-16H48A48,48,0,0,0,0,112V464a48,48,0,0,0,48,48H400a48,48,0,0,0,48-48V336A16,16,0,0,0,432,320ZM488,0h-128c-21.37,0-32.05,25.91-17,41l35.73,35.73L135,320.37a24,24,0,0,0,0,34L157.67,377a24,24,0,0,0,34,0L435.28,133.32,471,169c15,15,41,4.5,41-17V24A24,24,0,0,0,488,0Z']));
var $author$project$Views$Helpers$formatColumnRef = function (ref) {
	return A2(
		$author$project$Views$Helpers$withColumnName,
		ref.ap,
		$author$project$Views$Helpers$formatTableId(ref.bb));
};
var $elm$html$Html$li = _VirtualDom_node('li');
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$ul = _VirtualDom_node('ul');
var $lattyware$elm_fontawesome$FontAwesome$Icon$Presentation = $elm$core$Basics$identity;
var $lattyware$elm_fontawesome$FontAwesome$Icon$present = function (icon) {
	return {L: _List_Nil, aD: icon, b_: $elm$core$Maybe$Nothing, G: $elm$core$Maybe$Nothing, ag: 'img', dv: $elm$core$Maybe$Nothing, Y: _List_Nil};
};
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$add = F2(
	function (transform, combined) {
		switch (transform.$) {
			case 0:
				var direction = transform.a;
				var amount = function () {
					if (!direction.$) {
						var by = direction.a;
						return by;
					} else {
						var by = direction.a;
						return -by;
					}
				}();
				return _Utils_update(
					combined,
					{df: combined.df + amount});
			case 1:
				var direction = transform.a;
				var _v2 = function () {
					switch (direction.$) {
						case 0:
							var by = direction.a;
							return _Utils_Tuple2(0, -by);
						case 1:
							var by = direction.a;
							return _Utils_Tuple2(0, by);
						case 2:
							var by = direction.a;
							return _Utils_Tuple2(-by, 0);
						default:
							var by = direction.a;
							return _Utils_Tuple2(by, 0);
					}
				}();
				var x = _v2.a;
				var y = _v2.b;
				return _Utils_update(
					combined,
					{bf: combined.bf + x, bg: combined.bg + y});
			case 2:
				var rotation = transform.a;
				return _Utils_update(
					combined,
					{c3: combined.c3 + rotation});
			default:
				if (!transform.a) {
					var _v4 = transform.a;
					return _Utils_update(
						combined,
						{bU: true});
				} else {
					var _v5 = transform.a;
					return _Utils_update(
						combined,
						{bV: true});
				}
		}
	});
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$baseSize = 16;
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaninglessTransform = {bU: false, bV: false, c3: 0, df: $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$baseSize, bf: 0, bg: 0};
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$combine = function (transforms) {
	return A3($elm$core$List$foldl, $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$add, $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaninglessTransform, transforms);
};
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaningfulTransform = function (transforms) {
	var combined = $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$combine(transforms);
	return _Utils_eq(combined, $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaninglessTransform) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(combined);
};
var $elm$svg$Svg$Attributes$id = _VirtualDom_attribute('id');
var $elm$svg$Svg$title = $elm$svg$Svg$trustedNode('title');
var $lattyware$elm_fontawesome$FontAwesome$Icon$titledContents = F3(
	function (titleId, contents, title) {
		return A2(
			$elm$core$List$cons,
			A2(
				$elm$svg$Svg$title,
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$id(titleId)
					]),
				_List_fromArray(
					[
						$elm$svg$Svg$text(title)
					])),
			contents);
	});
var $elm$svg$Svg$Attributes$transform = _VirtualDom_attribute('transform');
var $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$transformForSvg = F3(
	function (containerWidth, iconWidth, transform) {
		var path = 'translate(' + ($elm$core$String$fromFloat((iconWidth / 2) * (-1)) + ' -256)');
		var outer = 'translate(' + ($elm$core$String$fromFloat(containerWidth / 2) + ' 256)');
		var innerTranslate = 'translate(' + ($elm$core$String$fromFloat(transform.bf * 32) + (',' + ($elm$core$String$fromFloat(transform.bg * 32) + ') ')));
		var innerRotate = 'rotate(' + ($elm$core$String$fromFloat(transform.c3) + ' 0 0)');
		var flipY = transform.bV ? (-1) : 1;
		var scaleY = (transform.df / $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$baseSize) * flipY;
		var flipX = transform.bU ? (-1) : 1;
		var scaleX = (transform.df / $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$baseSize) * flipX;
		var innerScale = 'scale(' + ($elm$core$String$fromFloat(scaleX) + (', ' + ($elm$core$String$fromFloat(scaleY) + ') ')));
		return {
			aE: $elm$svg$Svg$Attributes$transform(
				_Utils_ap(
					innerTranslate,
					_Utils_ap(innerScale, innerRotate))),
			G: $elm$svg$Svg$Attributes$transform(outer),
			aR: $elm$svg$Svg$Attributes$transform(path)
		};
	});
var $elm$svg$Svg$Attributes$viewBox = _VirtualDom_attribute('viewBox');
var $elm$svg$Svg$Attributes$x = _VirtualDom_attribute('x');
var $elm$svg$Svg$Attributes$y = _VirtualDom_attribute('y');
var $lattyware$elm_fontawesome$FontAwesome$Icon$allSpace = _List_fromArray(
	[
		$elm$svg$Svg$Attributes$x('0'),
		$elm$svg$Svg$Attributes$y('0'),
		$elm$svg$Svg$Attributes$width('100%'),
		$elm$svg$Svg$Attributes$height('100%')
	]);
var $elm$svg$Svg$clipPath = $elm$svg$Svg$trustedNode('clipPath');
var $elm$svg$Svg$Attributes$clipPath = _VirtualDom_attribute('clip-path');
var $elm$svg$Svg$Attributes$d = _VirtualDom_attribute('d');
var $elm$svg$Svg$Attributes$fill = _VirtualDom_attribute('fill');
var $elm$svg$Svg$path = $elm$svg$Svg$trustedNode('path');
var $lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePath = F2(
	function (attrs, d) {
		return A2(
			$elm$svg$Svg$path,
			A2(
				$elm$core$List$cons,
				$elm$svg$Svg$Attributes$fill('currentColor'),
				A2(
					$elm$core$List$cons,
					$elm$svg$Svg$Attributes$d(d),
					attrs)),
			_List_Nil);
	});
var $elm$svg$Svg$g = $elm$svg$Svg$trustedNode('g');
var $lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePaths = F2(
	function (attrs, icon) {
		var _v0 = icon.cR;
		if (!_v0.b) {
			return A2($lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePath, attrs, '');
		} else {
			if (!_v0.b.b) {
				var only = _v0.a;
				return A2($lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePath, attrs, only);
			} else {
				var secondary = _v0.a;
				var _v1 = _v0.b;
				var primary = _v1.a;
				return A2(
					$elm$svg$Svg$g,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$class('fa-group')
						]),
					_List_fromArray(
						[
							A2(
							$lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePath,
							A2(
								$elm$core$List$cons,
								$elm$svg$Svg$Attributes$class('fa-secondary'),
								attrs),
							secondary),
							A2(
							$lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePath,
							A2(
								$elm$core$List$cons,
								$elm$svg$Svg$Attributes$class('fa-primary'),
								attrs),
							primary)
						]));
			}
		}
	});
var $elm$svg$Svg$defs = $elm$svg$Svg$trustedNode('defs');
var $elm$svg$Svg$mask = $elm$svg$Svg$trustedNode('mask');
var $elm$svg$Svg$Attributes$mask = _VirtualDom_attribute('mask');
var $elm$svg$Svg$Attributes$maskContentUnits = _VirtualDom_attribute('maskContentUnits');
var $elm$svg$Svg$Attributes$maskUnits = _VirtualDom_attribute('maskUnits');
var $elm$svg$Svg$rect = $elm$svg$Svg$trustedNode('rect');
var $lattyware$elm_fontawesome$FontAwesome$Icon$viewMaskedWithTransform = F4(
	function (id, transforms, inner, outer) {
		var maskInnerGroup = A2(
			$elm$svg$Svg$g,
			_List_fromArray(
				[transforms.aE]),
			_List_fromArray(
				[
					A2(
					$lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePaths,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$fill('black'),
							transforms.aR
						]),
					inner)
				]));
		var maskId = 'mask-' + (inner.R + ('-' + id));
		var maskTag = A2(
			$elm$svg$Svg$mask,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$svg$Svg$Attributes$id(maskId),
						$elm$svg$Svg$Attributes$maskUnits('userSpaceOnUse'),
						$elm$svg$Svg$Attributes$maskContentUnits('userSpaceOnUse')
					]),
				$lattyware$elm_fontawesome$FontAwesome$Icon$allSpace),
			_List_fromArray(
				[
					A2(
					$elm$svg$Svg$rect,
					A2(
						$elm$core$List$cons,
						$elm$svg$Svg$Attributes$fill('white'),
						$lattyware$elm_fontawesome$FontAwesome$Icon$allSpace),
					_List_Nil),
					A2(
					$elm$svg$Svg$g,
					_List_fromArray(
						[transforms.G]),
					_List_fromArray(
						[maskInnerGroup]))
				]));
		var clipId = 'clip-' + (outer.R + ('-' + id));
		var defs = A2(
			$elm$svg$Svg$defs,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$svg$Svg$clipPath,
					_List_fromArray(
						[
							$elm$svg$Svg$Attributes$id(clipId)
						]),
					_List_fromArray(
						[
							A2($lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePaths, _List_Nil, outer)
						])),
					maskTag
				]));
		return _List_fromArray(
			[
				defs,
				A2(
				$elm$svg$Svg$rect,
				$elm$core$List$concat(
					_List_fromArray(
						[
							_List_fromArray(
							[
								$elm$svg$Svg$Attributes$fill('currentColor'),
								$elm$svg$Svg$Attributes$clipPath('url(#' + (clipId + ')')),
								$elm$svg$Svg$Attributes$mask('url(#' + (maskId + ')'))
							]),
							$lattyware$elm_fontawesome$FontAwesome$Icon$allSpace
						])),
				_List_Nil)
			]);
	});
var $lattyware$elm_fontawesome$FontAwesome$Icon$viewWithTransform = F2(
	function (transforms, icon) {
		if (!transforms.$) {
			var ts = transforms.a;
			return A2(
				$elm$svg$Svg$g,
				_List_fromArray(
					[ts.G]),
				_List_fromArray(
					[
						A2(
						$elm$svg$Svg$g,
						_List_fromArray(
							[ts.aE]),
						_List_fromArray(
							[
								A2(
								$lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePaths,
								_List_fromArray(
									[ts.aR]),
								icon)
							]))
					]));
		} else {
			return A2($lattyware$elm_fontawesome$FontAwesome$Svg$Internal$corePaths, _List_Nil, icon);
		}
	});
var $lattyware$elm_fontawesome$FontAwesome$Icon$internalView = function (_v0) {
	var icon = _v0.aD;
	var attributes = _v0.L;
	var transforms = _v0.Y;
	var role = _v0.ag;
	var id = _v0.b_;
	var title = _v0.dv;
	var outer = _v0.G;
	var alwaysId = A2($elm$core$Maybe$withDefault, icon.R, id);
	var titleId = alwaysId + '-title';
	var semantics = A2(
		$elm$core$Maybe$withDefault,
		A2($elm$html$Html$Attributes$attribute, 'aria-hidden', 'true'),
		A2(
			$elm$core$Maybe$map,
			$elm$core$Basics$always(
				A2($elm$html$Html$Attributes$attribute, 'aria-labelledby', titleId)),
			title));
	var _v1 = A2(
		$elm$core$Maybe$withDefault,
		_Utils_Tuple2(icon.dD, icon.bX),
		A2(
			$elm$core$Maybe$map,
			function (o) {
				return _Utils_Tuple2(o.dD, o.bX);
			},
			outer));
	var width = _v1.a;
	var height = _v1.b;
	var classes = _List_fromArray(
		[
			'svg-inline--fa',
			'fa-' + icon.R,
			'fa-w-' + $elm$core$String$fromInt(
			$elm$core$Basics$ceiling((width / height) * 16))
		]);
	var svgTransform = A2(
		$elm$core$Maybe$map,
		A2($lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$transformForSvg, width, icon.dD),
		$lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaningfulTransform(transforms));
	var contents = function () {
		var resolvedSvgTransform = A2(
			$elm$core$Maybe$withDefault,
			A3($lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$transformForSvg, width, icon.dD, $lattyware$elm_fontawesome$FontAwesome$Transforms$Internal$meaninglessTransform),
			svgTransform);
		return A2(
			$elm$core$Maybe$withDefault,
			_List_fromArray(
				[
					A2($lattyware$elm_fontawesome$FontAwesome$Icon$viewWithTransform, svgTransform, icon)
				]),
			A2(
				$elm$core$Maybe$map,
				A3($lattyware$elm_fontawesome$FontAwesome$Icon$viewMaskedWithTransform, alwaysId, resolvedSvgTransform, icon),
				outer));
	}();
	var potentiallyTitledContents = A2(
		$elm$core$Maybe$withDefault,
		contents,
		A2(
			$elm$core$Maybe$map,
			A2($lattyware$elm_fontawesome$FontAwesome$Icon$titledContents, titleId, contents),
			title));
	return A2(
		$elm$svg$Svg$svg,
		$elm$core$List$concat(
			_List_fromArray(
				[
					_List_fromArray(
					[
						A2($elm$html$Html$Attributes$attribute, 'role', role),
						A2($elm$html$Html$Attributes$attribute, 'xmlns', 'http://www.w3.org/2000/svg'),
						$elm$svg$Svg$Attributes$viewBox(
						'0 0 ' + ($elm$core$String$fromInt(width) + (' ' + $elm$core$String$fromInt(height)))),
						semantics
					]),
					A2($elm$core$List$map, $elm$svg$Svg$Attributes$class, classes),
					attributes
				])),
		potentiallyTitledContents);
};
var $lattyware$elm_fontawesome$FontAwesome$Icon$view = function (presentation) {
	return $lattyware$elm_fontawesome$FontAwesome$Icon$internalView(presentation);
};
var $lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon = A2($elm$core$Basics$composeR, $lattyware$elm_fontawesome$FontAwesome$Icon$present, $lattyware$elm_fontawesome$FontAwesome$Icon$view);
var $author$project$Views$Helpers$withNullableInfo = F2(
	function (nullable, text) {
		return nullable ? (text + '?') : text;
	});
var $author$project$Views$Tables$viewColumnDropdown = F3(
	function (incomingColumnRelations, ref, element) {
		var _v0 = A2(
			$elm$core$List$map,
			function (relation) {
				return A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('dropdown-item'),
									$elm$html$Html$Attributes$classList(
									_List_fromArray(
										[
											_Utils_Tuple2('disabled', relation.dh.bb.a6.di === 3)
										])),
									$elm$html$Html$Events$onClick(
									$author$project$Models$ShowTable(relation.dh.bb.b_))
								]),
							_List_fromArray(
								[
									$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$externalLinkAlt),
									$elm$html$Html$text(' '),
									A2(
									$elm$html$Html$b,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text(
											$author$project$Views$Helpers$formatTableId(relation.dh.bb.b_))
										])),
									$elm$html$Html$text(
									A2(
										$author$project$Views$Helpers$withNullableInfo,
										relation.dh.ap.cA,
										A2($author$project$Views$Helpers$withColumnName, relation.dh.ap.ap, '')))
								]))
						]));
			},
			incomingColumnRelations);
		if (!_v0.b) {
			return A2(
				$elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						element(_List_Nil)
					]));
		} else {
			var items = _v0;
			return A4(
				$author$project$Views$Bootstrap$bsDropdown,
				$author$project$Views$Helpers$formatColumnRef(ref) + '-relations-dropdown',
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('dropdown-menu-end')
					]),
				function (attrs) {
					return element(attrs);
				},
				function (attrs) {
					return A2($elm$html$Html$ul, attrs, items);
				});
		}
	});
var $author$project$Views$Bootstrap$Tooltip = 0;
var $lattyware$elm_fontawesome$FontAwesome$Solid$fingerprint = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'fingerprint',
	512,
	512,
	_List_fromArray(
		['M256.12 245.96c-13.25 0-24 10.74-24 24 1.14 72.25-8.14 141.9-27.7 211.55-2.73 9.72 2.15 30.49 23.12 30.49 10.48 0 20.11-6.92 23.09-17.52 13.53-47.91 31.04-125.41 29.48-224.52.01-13.25-10.73-24-23.99-24zm-.86-81.73C194 164.16 151.25 211.3 152.1 265.32c.75 47.94-3.75 95.91-13.37 142.55-2.69 12.98 5.67 25.69 18.64 28.36 13.05 2.67 25.67-5.66 28.36-18.64 10.34-50.09 15.17-101.58 14.37-153.02-.41-25.95 19.92-52.49 54.45-52.34 31.31.47 57.15 25.34 57.62 55.47.77 48.05-2.81 96.33-10.61 143.55-2.17 13.06 6.69 25.42 19.76 27.58 19.97 3.33 26.81-15.1 27.58-19.77 8.28-50.03 12.06-101.21 11.27-152.11-.88-55.8-47.94-101.88-104.91-102.72zm-110.69-19.78c-10.3-8.34-25.37-6.8-33.76 3.48-25.62 31.5-39.39 71.28-38.75 112 .59 37.58-2.47 75.27-9.11 112.05-2.34 13.05 6.31 25.53 19.36 27.89 20.11 3.5 27.07-14.81 27.89-19.36 7.19-39.84 10.5-80.66 9.86-121.33-.47-29.88 9.2-57.88 28-80.97 8.35-10.28 6.79-25.39-3.49-33.76zm109.47-62.33c-15.41-.41-30.87 1.44-45.78 4.97-12.89 3.06-20.87 15.98-17.83 28.89 3.06 12.89 16 20.83 28.89 17.83 11.05-2.61 22.47-3.77 34-3.69 75.43 1.13 137.73 61.5 138.88 134.58.59 37.88-1.28 76.11-5.58 113.63-1.5 13.17 7.95 25.08 21.11 26.58 16.72 1.95 25.51-11.88 26.58-21.11a929.06 929.06 0 0 0 5.89-119.85c-1.56-98.75-85.07-180.33-186.16-181.83zm252.07 121.45c-2.86-12.92-15.51-21.2-28.61-18.27-12.94 2.86-21.12 15.66-18.26 28.61 4.71 21.41 4.91 37.41 4.7 61.6-.11 13.27 10.55 24.09 23.8 24.2h.2c13.17 0 23.89-10.61 24-23.8.18-22.18.4-44.11-5.83-72.34zm-40.12-90.72C417.29 43.46 337.6 1.29 252.81.02 183.02-.82 118.47 24.91 70.46 72.94 24.09 119.37-.9 181.04.14 246.65l-.12 21.47c-.39 13.25 10.03 24.31 23.28 24.69.23.02.48.02.72.02 12.92 0 23.59-10.3 23.97-23.3l.16-23.64c-.83-52.5 19.16-101.86 56.28-139 38.76-38.8 91.34-59.67 147.68-58.86 69.45 1.03 134.73 35.56 174.62 92.39 7.61 10.86 22.56 13.45 33.42 5.86 10.84-7.62 13.46-22.59 5.84-33.43z']));
var $author$project$Views$Tables$formatReference = function (_v0) {
	var schema = _v0.c4;
	var table = _v0.bb;
	var column = _v0.ap;
	return A2(
		$author$project$Views$Helpers$withColumnName,
		column,
		A2($author$project$Views$Helpers$formatTableName, table, schema));
};
var $author$project$Views$Tables$formatFkTitle = function (fk) {
	return 'Foreign key to ' + $author$project$Views$Tables$formatReference(fk);
};
var $author$project$Views$Tables$formatIndexName = function (_v0) {
	var name = _v0;
	return name;
};
var $author$project$Views$Tables$formatIndexTitle = function (indexes) {
	return 'Indexed by ' + A2(
		$elm$core$String$join,
		', ',
		A2(
			$elm$core$List$map,
			function (index) {
				return $author$project$Views$Tables$formatIndexName(index.R);
			},
			indexes));
};
var $author$project$Views$Tables$formatPkTitle = function (_v0) {
	return 'Primary key';
};
var $author$project$Views$Tables$formatUniqueIndexName = function (_v0) {
	var name = _v0;
	return name;
};
var $author$project$Views$Tables$formatUniqueTitle = function (uniques) {
	return 'Unique constraint in ' + A2(
		$elm$core$String$join,
		', ',
		A2(
			$elm$core$List$map,
			function (unique) {
				return $author$project$Views$Tables$formatUniqueIndexName(unique.R);
			},
			uniques));
};
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $author$project$Views$Tables$hasColumn = F2(
	function (column, columns) {
		return A2(
			$elm$core$List$any,
			function (c) {
				return _Utils_eq(c, column);
			},
			columns);
	});
var $author$project$Views$Tables$inIndexes = F2(
	function (column, indexes) {
		return A2(
			$elm$core$List$filter,
			function (_v0) {
				var columns = _v0.N;
				return A2($author$project$Views$Tables$hasColumn, column, columns);
			},
			indexes);
	});
var $author$project$Views$Tables$inPrimaryKey = F2(
	function (column, pk) {
		return A2(
			$author$project$Libs$Std$maybeFilter,
			function (_v0) {
				var columns = _v0.N;
				return A2($author$project$Views$Tables$hasColumn, column, columns);
			},
			pk);
	});
var $author$project$Views$Tables$inUniqueIndexes = F2(
	function (column, uniques) {
		return A2(
			$elm$core$List$filter,
			function (_v0) {
				var columns = _v0.N;
				return A2($author$project$Views$Tables$hasColumn, column, columns);
			},
			uniques);
	});
var $lattyware$elm_fontawesome$FontAwesome$Solid$key = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'key',
	512,
	512,
	_List_fromArray(
		['M512 176.001C512 273.203 433.202 352 336 352c-11.22 0-22.19-1.062-32.827-3.069l-24.012 27.014A23.999 23.999 0 0 1 261.223 384H224v40c0 13.255-10.745 24-24 24h-40v40c0 13.255-10.745 24-24 24H24c-13.255 0-24-10.745-24-24v-78.059c0-6.365 2.529-12.47 7.029-16.971l161.802-161.802C163.108 213.814 160 195.271 160 176 160 78.798 238.797.001 335.999 0 433.488-.001 512 78.511 512 176.001zM336 128c0 26.51 21.49 48 48 48s48-21.49 48-48-21.49-48-48-48-48 21.49-48 48z']));
var $lattyware$elm_fontawesome$FontAwesome$Solid$sortAmountDownAlt = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'sort-amount-down-alt',
	512,
	512,
	_List_fromArray(
		['M240 96h64a16 16 0 0 0 16-16V48a16 16 0 0 0-16-16h-64a16 16 0 0 0-16 16v32a16 16 0 0 0 16 16zm0 128h128a16 16 0 0 0 16-16v-32a16 16 0 0 0-16-16H240a16 16 0 0 0-16 16v32a16 16 0 0 0 16 16zm256 192H240a16 16 0 0 0-16 16v32a16 16 0 0 0 16 16h256a16 16 0 0 0 16-16v-32a16 16 0 0 0-16-16zm-256-64h192a16 16 0 0 0 16-16v-32a16 16 0 0 0-16-16H240a16 16 0 0 0-16 16v32a16 16 0 0 0 16 16zm-64 0h-48V48a16 16 0 0 0-16-16H80a16 16 0 0 0-16 16v304H16c-14.19 0-21.37 17.24-11.29 27.31l80 96a16 16 0 0 0 22.62 0l80-96C197.35 369.26 190.22 352 176 352z']));
var $elm$html$Html$Attributes$title = $elm$html$Html$Attributes$stringProperty('title');
var $author$project$Views$Tables$viewColumnIcon = F5(
	function (maybePk, uniques, indexes, column, attrs) {
		var _v0 = _Utils_Tuple2(
			_Utils_Tuple2(
				A2($author$project$Views$Tables$inPrimaryKey, column.ap, maybePk),
				column.bW),
			_Utils_Tuple2(
				A2($author$project$Views$Tables$inUniqueIndexes, column.ap, uniques),
				A2($author$project$Views$Tables$inIndexes, column.ap, indexes)));
		if (!_v0.a.a.$) {
			var _v1 = _v0.a;
			var pk = _v1.a.a;
			return A2(
				$elm$html$Html$div,
				A2(
					$elm$core$List$cons,
					$elm$html$Html$Attributes$class('icon'),
					attrs),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$title(
								$author$project$Views$Tables$formatPkTitle(pk)),
								$author$project$Views$Bootstrap$bsToggle(0)
							]),
						_List_fromArray(
							[
								$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$key)
							]))
					]));
		} else {
			if (!_v0.a.b.$) {
				var _v2 = _v0.a;
				var fk = _v2.b.a;
				return A2(
					$elm$html$Html$div,
					A2(
						$elm$core$List$cons,
						$elm$html$Html$Attributes$class('icon'),
						A2(
							$elm$core$List$cons,
							$elm$html$Html$Events$onClick(
								$author$project$Models$ShowTable(fk.aj)),
							attrs)),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$title(
									$author$project$Views$Tables$formatFkTitle(fk)),
									$author$project$Views$Bootstrap$bsToggle(0)
								]),
							_List_fromArray(
								[
									$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$externalLinkAlt)
								]))
						]));
			} else {
				if (_v0.b.a.b) {
					var _v3 = _v0.b;
					var _v4 = _v3.a;
					var u = _v4.a;
					var us = _v4.b;
					return A2(
						$elm$html$Html$div,
						A2(
							$elm$core$List$cons,
							$elm$html$Html$Attributes$class('icon'),
							attrs),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$title(
										$author$project$Views$Tables$formatUniqueTitle(
											A2($elm$core$List$cons, u, us))),
										$author$project$Views$Bootstrap$bsToggle(0)
									]),
								_List_fromArray(
									[
										$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$fingerprint)
									]))
							]));
				} else {
					if (_v0.b.b.b) {
						var _v5 = _v0.b;
						var _v6 = _v5.b;
						var i = _v6.a;
						var is = _v6.b;
						return A2(
							$elm$html$Html$div,
							A2(
								$elm$core$List$cons,
								$elm$html$Html$Attributes$class('icon'),
								attrs),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$title(
											$author$project$Views$Tables$formatIndexTitle(
												A2($elm$core$List$cons, i, is))),
											$author$project$Views$Bootstrap$bsToggle(0)
										]),
									_List_fromArray(
										[
											$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$sortAmountDownAlt)
										]))
								]));
					} else {
						return A2(
							$elm$html$Html$div,
							_Utils_ap(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('icon')
									]),
								attrs),
							_List_Nil);
					}
				}
			}
		}
	});
var $author$project$Views$Helpers$extractColumnName = function (_v0) {
	var name = _v0;
	return name;
};
var $author$project$Libs$Std$listAppendOn = F3(
	function (maybe, transform, list) {
		if (!maybe.$) {
			var b = maybe.a;
			return _Utils_ap(
				list,
				_List_fromArray(
					[
						transform(b)
					]));
		} else {
			return list;
		}
	});
var $lattyware$elm_fontawesome$FontAwesome$Regular$commentDots = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'far',
	'comment-dots',
	512,
	512,
	_List_fromArray(
		['M144 208c-17.7 0-32 14.3-32 32s14.3 32 32 32 32-14.3 32-32-14.3-32-32-32zm112 0c-17.7 0-32 14.3-32 32s14.3 32 32 32 32-14.3 32-32-14.3-32-32-32zm112 0c-17.7 0-32 14.3-32 32s14.3 32 32 32 32-14.3 32-32-14.3-32-32-32zM256 32C114.6 32 0 125.1 0 240c0 47.6 19.9 91.2 52.9 126.3C38 405.7 7 439.1 6.5 439.5c-6.6 7-8.4 17.2-4.6 26S14.4 480 24 480c61.5 0 110-25.7 139.1-46.3C192 442.8 223.2 448 256 448c141.4 0 256-93.1 256-208S397.4 32 256 32zm0 368c-26.7 0-53.1-4.1-78.4-12.1l-22.7-7.2-19.5 13.8c-14.3 10.1-33.9 21.4-57.5 29 7.3-12.1 14.4-25.7 19.9-40.2l10.6-28.1-20.6-21.8C69.7 314.1 48 282.2 48 240c0-88.2 93.3-160 208-160s208 71.8 208 160-93.3 160-208 160z']));
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$Views$Tables$viewComment = function (comment) {
	return A2(
		$elm$html$Html$span,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$title(comment),
				$author$project$Views$Bootstrap$bsToggle(0),
				A2($elm$html$Html$Attributes$style, 'margin-left', '.25rem'),
				A2($elm$html$Html$Attributes$style, 'font-size', '.9rem'),
				A2($elm$html$Html$Attributes$style, 'opacity', '.25')
			]),
		_List_fromArray(
			[
				$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Regular$commentDots)
			]));
};
var $author$project$Views$Tables$viewColumnName = F2(
	function (pk, column) {
		var className = function () {
			var _v1 = A2($author$project$Views$Tables$inPrimaryKey, column.ap, pk);
			if (!_v1.$) {
				return 'name bold';
			} else {
				return 'name';
			}
		}();
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class(className)
				]),
			A3(
				$author$project$Libs$Std$listAppendOn,
				column.aq,
				function (_v0) {
					var comment = _v0;
					return $author$project$Views$Tables$viewComment(comment);
				},
				_List_fromArray(
					[
						$elm$html$Html$text(
						$author$project$Views$Helpers$extractColumnName(column.ap))
					])));
	});
var $author$project$Views$Helpers$extractColumnType = function (_v0) {
	var kind = _v0;
	return kind;
};
var $author$project$Views$Tables$formatColumnType = function (column) {
	return A2(
		$author$project$Views$Helpers$withNullableInfo,
		column.cA,
		$author$project$Views$Helpers$extractColumnType(column.b9));
};
var $author$project$Views$Tables$viewColumnType = function (column) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('type')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(
				$author$project$Views$Tables$formatColumnType(column))
			]));
};
var $author$project$Views$Tables$viewColumn = F6(
	function (ref, pk, uniques, indexes, columnRelations, column) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('column'),
					$elm$html$Html$Events$onDoubleClick(
					$author$project$Models$HideColumn(ref))
				]),
			_List_fromArray(
				[
					A3(
					$author$project$Views$Tables$viewColumnDropdown,
					columnRelations,
					ref,
					A4($author$project$Views$Tables$viewColumnIcon, pk, uniques, indexes, column)),
					A2($author$project$Views$Tables$viewColumnName, pk, column),
					$author$project$Views$Tables$viewColumnType(column)
				]));
	});
var $author$project$Models$HideTable = function (a) {
	return {$: 12, a: a};
};
var $author$project$Models$Noop = {$: 30};
var $author$project$Models$SelectTable = function (a) {
	return {$: 11, a: a};
};
var $lattyware$elm_fontawesome$FontAwesome$Solid$ellipsisV = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'ellipsis-v',
	192,
	512,
	_List_fromArray(
		['M96 184c39.8 0 72 32.2 72 72s-32.2 72-72 72-72-32.2-72-72 32.2-72 72-72zM24 80c0 39.8 32.2 72 72 72s72-32.2 72-72S135.8 8 96 8 24 40.2 24 80zm0 352c0 39.8 32.2 72 72 72s72-32.2 72-72-32.2-72-72-72-72 32.2-72 72z']));
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 1, a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $author$project$Libs$Std$stopClick = function (m) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'click',
		$elm$json$Json$Decode$succeed(
			_Utils_Tuple2(m, true)));
};
var $author$project$Views$Tables$tableNameSize = function (zoom) {
	return (zoom < 0.5) ? _List_fromArray(
		[
			A2(
			$elm$html$Html$Attributes$style,
			'font-size',
			$elm$core$String$fromFloat(10 / zoom) + 'px')
		]) : _List_Nil;
};
var $author$project$Views$Tables$viewHeader = F2(
	function (zoom, table) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('header'),
					A2($elm$html$Html$Attributes$style, 'display', 'flex'),
					A2($elm$html$Html$Attributes$style, 'align-items', 'center'),
					$elm$html$Html$Events$onClick(
					$author$project$Models$SelectTable(table.b_))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'flex-grow', '1')
						]),
					A3(
						$author$project$Libs$Std$listAppendOn,
						table.aq,
						function (_v0) {
							var comment = _v0;
							return $author$project$Views$Tables$viewComment(comment);
						},
						_List_fromArray(
							[
								A2(
								$elm$html$Html$span,
								$author$project$Views$Tables$tableNameSize(zoom),
								_List_fromArray(
									[
										$elm$html$Html$text(
										A2($author$project$Views$Helpers$formatTableName, table.bb, table.c4))
									]))
							]))),
					A4(
					$author$project$Views$Bootstrap$bsDropdown,
					$author$project$Views$Helpers$formatTableId(table.b_) + '-settings-dropdown',
					_List_Nil,
					function (attrs) {
						return A2(
							$elm$html$Html$div,
							_Utils_ap(
								_List_fromArray(
									[
										A2($elm$html$Html$Attributes$style, 'font-size', '0.9rem'),
										A2($elm$html$Html$Attributes$style, 'opacity', '0.25'),
										A2($elm$html$Html$Attributes$style, 'width', '30px'),
										A2($elm$html$Html$Attributes$style, 'margin-left', '-10px'),
										A2($elm$html$Html$Attributes$style, 'margin-right', '-20px'),
										$author$project$Libs$Std$stopClick($author$project$Models$Noop)
									]),
								attrs),
							_List_fromArray(
								[
									$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$ellipsisV)
								]));
					},
					function (attrs) {
						return A2(
							$elm$html$Html$ul,
							attrs,
							_List_fromArray(
								[
									A2(
									$elm$html$Html$li,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$a,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('dropdown-item'),
													$elm$html$Html$Attributes$href('#'),
													$elm$html$Html$Events$onClick(
													$author$project$Models$HideTable(table.b_))
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Hide table')
												]))
										]))
								]));
					})
				]));
	});
var $author$project$Models$ShowColumn = F2(
	function (a, b) {
		return {$: 19, a: a, b: b};
	});
var $author$project$Views$Tables$viewHiddenColumn = F5(
	function (ref, pk, uniques, indexes, column) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('hidden-column'),
					$elm$html$Html$Events$onDoubleClick(
					A2(
						$author$project$Models$ShowColumn,
						ref,
						$author$project$Views$Helpers$extractColumnIndex(column.b2)))
				]),
			_List_fromArray(
				[
					A5($author$project$Views$Tables$viewColumnIcon, pk, uniques, indexes, column, _List_Nil),
					A2($author$project$Views$Tables$viewColumnName, pk, column),
					$author$project$Views$Tables$viewColumnType(column)
				]));
	});
var $author$project$Views$Tables$viewTable = F3(
	function (zoom, incomingTableRelations, table) {
		var collapseId = $author$project$Views$Helpers$formatTableId(table.b_) + '-hidden-columns-collapse';
		var _v0 = A2(
			$elm$core$List$partition,
			function (column) {
				return _Utils_eq(column.a6.cP, $elm$core$Maybe$Nothing);
			},
			$pzp1997$assoc_list$AssocList$values(table.N));
		var hiddenColumns = _v0.a;
		var visibleColumns = _v0.b;
		return A2(
			$elm$html$Html$div,
			_Utils_ap(
				A3(
					$author$project$Libs$Std$listAddIf,
					table.a6.di === 1,
					A2($elm$html$Html$Attributes$style, 'visibility', 'hidden'),
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('erd-table'),
							$elm$html$Html$Attributes$class(table.a6.bw),
							$elm$html$Html$Attributes$classList(
							_List_fromArray(
								[
									_Utils_Tuple2('selected', table.a6.da)
								])),
							$elm$html$Html$Attributes$id(
							$author$project$Views$Helpers$formatTableId(table.b_)),
							$author$project$Views$Helpers$placeAt(table.a6.U)
						])),
				_Utils_ap(
					$author$project$Views$Helpers$sizeAttrs(table.a6.df),
					$author$project$Views$Helpers$dragAttrs(
						$author$project$Views$Helpers$formatTableId(table.b_)))),
			_List_fromArray(
				[
					A2($author$project$Views$Tables$viewHeader, zoom, table),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('columns')
						]),
					A2(
						$elm$core$List$map,
						function (c) {
							return A6(
								$author$project$Views$Tables$viewColumn,
								{ap: c.ap, bb: table.b_},
								table.cX,
								table.dy,
								table.b3,
								A2($author$project$Views$Tables$filterIncomingColumnRelations, incomingTableRelations, c),
								c);
						},
						A2(
							$elm$core$List$sortBy,
							function (c) {
								return A2($elm$core$Maybe$withDefault, -1, c.a6.cP);
							},
							visibleColumns))),
					A3(
					$author$project$Libs$Std$divIf,
					$elm$core$List$length(hiddenColumns) > 0,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('hidden-columns')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$button,
							_Utils_ap(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('toggle'),
										$elm$html$Html$Attributes$type_('button')
									]),
								$author$project$Views$Bootstrap$bsToggleCollapse(collapseId)),
							_List_fromArray(
								[
									$elm$html$Html$text(
									A4(
										$author$project$Libs$Std$plural,
										$elm$core$List$length(hiddenColumns),
										'No hidden column',
										'1 hidden column',
										' hidden columns'))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('collapse'),
									$elm$html$Html$Attributes$id(collapseId)
								]),
							A2(
								$elm$core$List$map,
								function (c) {
									return A5(
										$author$project$Views$Tables$viewHiddenColumn,
										{ap: c.ap, bb: table.b_},
										table.cX,
										table.dy,
										table.b3,
										c);
								},
								A2(
									$elm$core$List$sortBy,
									function (column) {
										return $author$project$Views$Helpers$extractColumnIndex(column.b2);
									},
									hiddenColumns)))
						]))
				]));
	});
var $author$project$View$viewErd = F2(
	function (canvas, schema) {
		var relations = A2(
			$elm$core$List$filterMap,
			$author$project$View$buildRelation(schema),
			schema.c0);
		return A2(
			$elm$html$Html$div,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Attributes$id($author$project$Conf$conf.b0.bL),
						$elm$html$Html$Attributes$class('erd'),
						$author$project$Libs$Std$onWheel($author$project$Models$Zoom)
					]),
				_Utils_ap(
					$author$project$Views$Helpers$sizeAttrs(canvas.df),
					$author$project$Views$Helpers$dragAttrs($author$project$Conf$conf.b0.bL))),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('canvas'),
							A2($author$project$View$placeAndZoom, canvas.dG, canvas.U)
						]),
					_Utils_ap(
						A3(
							$author$project$Libs$Std$listFilterMap,
							$author$project$View$shouldDrawTable,
							function (t) {
								return A3(
									$author$project$Views$Tables$viewTable,
									canvas.dG,
									A2($author$project$View$incomingTableRelations, relations, t),
									t);
							},
							$pzp1997$assoc_list$AssocList$values(schema.dp)),
						A3($author$project$Libs$Std$listFilterMap, $author$project$View$shouldDrawRelation, $author$project$Views$Relations$viewRelation, relations)))
				]));
	});
var $author$project$Models$ChangeSchema = {$: 0};
var $author$project$Models$HideAllTables = {$: 16};
var $author$project$Views$Bootstrap$Offcanvas = 4;
var $author$project$Views$Bootstrap$Primary = 0;
var $author$project$Views$Bootstrap$Secondary = 1;
var $author$project$Views$Bootstrap$ariaLabel = function (text) {
	return A2($elm$html$Html$Attributes$attribute, 'aria-label', text);
};
var $author$project$Views$Bootstrap$bsBackdrop = function (value) {
	if (value) {
		return A2($elm$html$Html$Attributes$attribute, 'data-bs-backdrop', 'true');
	} else {
		return A2($elm$html$Html$Attributes$attribute, 'data-bs-backdrop', 'false');
	}
};
var $author$project$Views$Bootstrap$colorToString = function (color) {
	switch (color) {
		case 0:
			return 'primary';
		case 1:
			return 'secondary';
		case 2:
			return 'success';
		case 3:
			return 'info';
		case 4:
			return 'warning';
		case 5:
			return 'danger';
		case 6:
			return 'light';
		default:
			return 'dark';
	}
};
var $author$project$Views$Bootstrap$bsButton = F3(
	function (color, attrs, children) {
		return A2(
			$elm$html$Html$button,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Attributes$type_('button'),
						$elm$html$Html$Attributes$class('btn'),
						$elm$html$Html$Attributes$class(
						'btn-outline-' + $author$project$Views$Bootstrap$colorToString(color))
					]),
				attrs),
			children);
	});
var $author$project$Libs$Std$role = function (text) {
	return A2($elm$html$Html$Attributes$attribute, 'role', text);
};
var $author$project$Views$Bootstrap$bsButtonGroup = F2(
	function (label, buttons) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('btn-group'),
					$author$project$Libs$Std$role('group'),
					$author$project$Views$Bootstrap$ariaLabel(label)
				]),
			buttons);
	});
var $author$project$Views$Bootstrap$bsDismiss = function (kind) {
	return A2(
		$elm$html$Html$Attributes$attribute,
		'data-bs-dismiss',
		$author$project$Views$Bootstrap$toggleName(kind));
};
var $author$project$Views$Bootstrap$bsScroll = function (value) {
	if (value) {
		return A2($elm$html$Html$Attributes$attribute, 'data-bs-scroll', 'true');
	} else {
		return A2($elm$html$Html$Attributes$attribute, 'data-bs-scroll', 'false');
	}
};
var $pzp1997$assoc_list$AssocList$foldl = F3(
	function (func, initialResult, _v0) {
		var alist = _v0;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v1, result) {
					var key = _v1.a;
					var value = _v1.b;
					return A3(func, key, value, result);
				}),
			initialResult,
			alist);
	});
var $elm$html$Html$h5 = _VirtualDom_node('h5');
var $elm$html$Html$Attributes$tabindex = function (n) {
	return A2(
		_VirtualDom_attribute,
		'tabIndex',
		$elm$core$String$fromInt(n));
};
var $author$project$Views$Menu$viewMenu = function (schema) {
	return _List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$id($author$project$Conf$conf.b0.cg),
					$elm$html$Html$Attributes$class('offcanvas offcanvas-start'),
					$author$project$Views$Bootstrap$bsScroll(true),
					$author$project$Views$Bootstrap$bsBackdrop(false),
					$author$project$Views$Bootstrap$ariaLabelledBy($author$project$Conf$conf.b0.cg + '-label'),
					$elm$html$Html$Attributes$tabindex(-1)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('offcanvas-header')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$h5,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('offcanvas-title'),
									$elm$html$Html$Attributes$id($author$project$Conf$conf.b0.cg + '-label')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Menu')
								])),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$type_('button'),
									$elm$html$Html$Attributes$class('btn-close text-reset'),
									$author$project$Views$Bootstrap$bsDismiss(4),
									$author$project$Views$Bootstrap$ariaLabel('Close')
								]),
							_List_Nil)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('offcanvas-body')
						]),
					_Utils_ap(
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_Nil,
								_List_fromArray(
									[
										A3(
										$author$project$Views$Bootstrap$bsButton,
										0,
										_List_fromArray(
											[
												$elm$html$Html$Events$onClick($author$project$Models$ChangeSchema)
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Load a schema')
											]))
									]))
							]),
						$pzp1997$assoc_list$AssocList$isEmpty(schema.dp) ? _List_Nil : _List_fromArray(
							[
								$elm$html$Html$text(
								$elm$core$String$fromInt(
									$pzp1997$assoc_list$AssocList$size(schema.dp)) + (' tables, ' + ($elm$core$String$fromInt(
									A3(
										$pzp1997$assoc_list$AssocList$foldl,
										F3(
											function (_v0, t, c) {
												return c + $pzp1997$assoc_list$AssocList$size(t.N);
											}),
										0,
										schema.dp)) + (' columns, ' + ($elm$core$String$fromInt(
									$elm$core$List$length(schema.c0)) + ' relations'))))),
								A2(
								$elm$html$Html$div,
								_List_Nil,
								_List_fromArray(
									[
										A2(
										$author$project$Views$Bootstrap$bsButtonGroup,
										'Toggle all',
										_List_fromArray(
											[
												A3(
												$author$project$Views$Bootstrap$bsButton,
												1,
												_List_fromArray(
													[
														$elm$html$Html$Events$onClick($author$project$Models$HideAllTables)
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Hide all tables')
													])),
												A3(
												$author$project$Views$Bootstrap$bsButton,
												1,
												_List_fromArray(
													[
														$elm$html$Html$Events$onClick($author$project$Models$ShowAllTables)
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Show all tables')
													]))
											]))
									]))
							])))
				]))
		]);
};
var $author$project$Models$CreateLayout = function (a) {
	return {$: 26, a: a};
};
var $author$project$Views$Bootstrap$Modal = 2;
var $author$project$Models$NewLayout = function (a) {
	return {$: 25, a: a};
};
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$autofocus = $elm$html$Html$Attributes$boolProperty('autofocus');
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $elm$html$Html$Attributes$for = $elm$html$Html$Attributes$stringProperty('htmlFor');
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$label = _VirtualDom_node('label');
var $author$project$Views$Bootstrap$ariaHidden = function (value) {
	if (value) {
		return A2($elm$html$Html$Attributes$attribute, 'aria-hidden', 'true');
	} else {
		return A2($elm$html$Html$Attributes$attribute, 'aria-hidden', 'false');
	}
};
var $author$project$Views$Modals$modal = F4(
	function (modalId, title, body, footer) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$id(modalId),
					$elm$html$Html$Attributes$class('modal fade'),
					$elm$html$Html$Attributes$tabindex(-1),
					$author$project$Views$Bootstrap$ariaLabelledBy(modalId + '-label'),
					$author$project$Views$Bootstrap$ariaHidden(true)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('modal-content')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('modal-header')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h5,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('modal-title'),
													$elm$html$Html$Attributes$id(modalId + '-label')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(title)
												])),
											A2(
											$elm$html$Html$button,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$type_('button'),
													$elm$html$Html$Attributes$class('btn-close'),
													$author$project$Views$Bootstrap$bsDismiss(2),
													$author$project$Views$Bootstrap$ariaLabel('Close')
												]),
											_List_Nil)
										])),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('modal-body')
										]),
									body),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('modal-footer')
										]),
									footer)
								]))
						]))
				]));
	});
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Views$Modals$viewCreateLayoutModal = function (newLayout) {
	return A4(
		$author$project$Views$Modals$modal,
		$author$project$Conf$conf.b0.cs,
		'Save layout',
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row g-3 align-items-center')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('col-auto')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$label,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('col-form-label'),
										$elm$html$Html$Attributes$for('new-layout-name')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Layout name')
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('col-auto')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$input,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$type_('text'),
										$elm$html$Html$Attributes$class('form-control'),
										$elm$html$Html$Attributes$id('new-layout-name'),
										$elm$html$Html$Attributes$value(newLayout),
										$elm$html$Html$Events$onInput($author$project$Models$NewLayout),
										$elm$html$Html$Attributes$autofocus(true)
									]),
								_List_Nil)
							]))
					]))
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$type_('button'),
						$elm$html$Html$Attributes$class('btn btn-secondary'),
						$author$project$Views$Bootstrap$bsDismiss(2)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Cancel')
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$type_('button'),
						$elm$html$Html$Attributes$class('btn btn-primary'),
						$author$project$Views$Bootstrap$bsDismiss(2),
						$elm$html$Html$Attributes$disabled(newLayout === ''),
						$elm$html$Html$Events$onClick(
						$author$project$Models$CreateLayout(newLayout))
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Save layout')
					]))
			]));
};
var $author$project$Libs$Std$bText = function (content) {
	return A2(
		$elm$html$Html$b,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(content)
			]));
};
var $elm$html$Html$code = _VirtualDom_node('code');
var $author$project$Libs$Std$codeText = function (content) {
	return A2(
		$elm$html$Html$code,
		_List_Nil,
		_List_fromArray(
			[
				$elm$html$Html$text(content)
			]));
};
var $author$project$Views$Modals$viewHelpModal = A4(
	$author$project$Views$Modals$modal,
	$author$project$Conf$conf.b0.bY,
	'Schema Viz cheatsheet',
	_List_fromArray(
		[
			A2(
			$elm$html$Html$ul,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('In '),
							$author$project$Libs$Std$bText('search'),
							$elm$html$Html$text(', you can look for tables and columns, then click on one to show it')
						])),
					A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('Not connected relations on the left are '),
							$author$project$Libs$Std$bText('incoming foreign keys'),
							$elm$html$Html$text('. Click on the column icon to see tables referencing it and then show them')
						])),
					A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('Not connected relations on the right are '),
							$author$project$Libs$Std$bText('column foreign keys'),
							$elm$html$Html$text('. Click on the column icon to show referenced table')
						])),
					A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('You can '),
							$author$project$Libs$Std$bText('hide/show a column'),
							$elm$html$Html$text(' with a '),
							$author$project$Libs$Std$codeText('double click'),
							$elm$html$Html$text(' on it')
						])),
					A2(
					$elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('You can '),
							$author$project$Libs$Std$bText('zoom in/out'),
							$elm$html$Html$text(' using scrolling action, '),
							$author$project$Libs$Std$bText('move tables'),
							$elm$html$Html$text(' around by dragging them or even '),
							$author$project$Libs$Std$bText('move everything'),
							$elm$html$Html$text(' by dragging the background')
						]))
				]))
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$button,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$type_('button'),
					$elm$html$Html$Attributes$class('btn btn-primary'),
					$author$project$Views$Bootstrap$bsDismiss(2)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Thanks!')
				]))
		]));
var $author$project$Models$FileDragLeave = {$: 2};
var $author$project$Models$FileDragOver = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Models$FileDropped = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$Models$FileSelected = function (a) {
	return {$: 4, a: a};
};
var $author$project$Models$LoadSampleData = function (a) {
	return {$: 6, a: a};
};
var $author$project$Models$UseSchema = function (a) {
	return {$: 9, a: a};
};
var $elm$html$Html$Attributes$accept = $elm$html$Html$Attributes$stringProperty('accept');
var $mpizenberg$elm_file$FileValue$inputAttributes = F2(
	function (id, mimes) {
		return _List_fromArray(
			[
				$elm$html$Html$Attributes$id(id),
				$elm$html$Html$Attributes$type_('file'),
				A2($elm$html$Html$Attributes$style, 'display', 'none'),
				$elm$html$Html$Attributes$accept(
				A2($elm$core$String$join, ',', mimes))
			]);
	});
var $mpizenberg$elm_file$FileValue$loadFile = function (msgTag) {
	return A2(
		$elm$html$Html$Events$custom,
		'change',
		A2(
			$elm$json$Json$Decode$map,
			function (file) {
				return {
					aJ: msgTag(file),
					aV: true,
					a7: true
				};
			},
			A2(
				$elm$json$Json$Decode$at,
				_List_fromArray(
					['target', 'files', '0']),
				$mpizenberg$elm_file$FileValue$decoder)));
};
var $mpizenberg$elm_file$FileValue$hiddenInputSingle = F3(
	function (id, mimes, msgTag) {
		return A2(
			$elm$html$Html$input,
			A2(
				$elm$core$List$cons,
				$mpizenberg$elm_file$FileValue$loadFile(msgTag),
				A2($mpizenberg$elm_file$FileValue$inputAttributes, id, mimes)),
			_List_Nil);
	});
var $pzp1997$assoc_list$AssocList$keys = function (_v0) {
	var alist = _v0;
	return A2($elm$core$List$map, $elm$core$Tuple$first, alist);
};
var $mpizenberg$elm_file$FileValue$all = A2(
	$elm$core$List$foldr,
	$elm$json$Json$Decode$map2($elm$core$List$cons),
	$elm$json$Json$Decode$succeed(_List_Nil));
var $mpizenberg$elm_file$FileValue$dynamicListOf = function (itemDecoder) {
	var decodeOne = function (n) {
		return A2(
			$elm$json$Json$Decode$field,
			$elm$core$String$fromInt(n),
			itemDecoder);
	};
	var decodeN = function (n) {
		return $mpizenberg$elm_file$FileValue$all(
			A2(
				$elm$core$List$map,
				decodeOne,
				A2($elm$core$List$range, 0, n - 1)));
	};
	return A2(
		$elm$json$Json$Decode$andThen,
		decodeN,
		A2($elm$json$Json$Decode$field, 'length', $elm$json$Json$Decode$int));
};
var $mpizenberg$elm_file$FileValue$errorFile = {
	ca: $elm$time$Time$millisToPosix(0),
	cj: 'text/plain',
	R: 'If you see this file, please report an error at https://github.com/mpizenberg/elm-files/issues',
	df: 0,
	dB: $elm$json$Json$Encode$null
};
var $mpizenberg$elm_file$FileValue$multipleFilesDecoder = A2(
	$elm$json$Json$Decode$andThen,
	function (files) {
		if (files.b) {
			var file = files.a;
			var list = files.b;
			return $elm$json$Json$Decode$succeed(
				_Utils_Tuple2(file, list));
		} else {
			return $elm$json$Json$Decode$succeed(
				_Utils_Tuple2($mpizenberg$elm_file$FileValue$errorFile, _List_Nil));
		}
	},
	$mpizenberg$elm_file$FileValue$dynamicListOf($mpizenberg$elm_file$FileValue$decoder));
var $mpizenberg$elm_file$FileValue$filesOn = F2(
	function (event, msgTag) {
		return A2(
			$elm$html$Html$Events$custom,
			event,
			A2(
				$elm$json$Json$Decode$map,
				function (_v0) {
					var file = _v0.a;
					var list = _v0.b;
					return {
						aJ: A2(msgTag, file, list),
						aV: true,
						a7: true
					};
				},
				A2(
					$elm$json$Json$Decode$at,
					_List_fromArray(
						['dataTransfer', 'files']),
					$mpizenberg$elm_file$FileValue$multipleFilesDecoder)));
	});
var $mpizenberg$elm_file$FileValue$onWithId = F3(
	function (id, event, msg) {
		return A2(
			$elm$html$Html$Events$custom,
			event,
			A2(
				$elm$json$Json$Decode$map,
				function (message) {
					return {aJ: message, aV: true, a7: true};
				},
				A2(
					$elm$json$Json$Decode$andThen,
					function (targetId) {
						return _Utils_eq(targetId, id) ? $elm$json$Json$Decode$succeed(msg) : $elm$json$Json$Decode$fail('Wrong target');
					},
					A2(
						$elm$json$Json$Decode$at,
						_List_fromArray(
							['target', 'id']),
						$elm$json$Json$Decode$string))));
	});
var $mpizenberg$elm_file$FileValue$onDrop = function (config) {
	return A2(
		$elm$core$List$cons,
		A2($mpizenberg$elm_file$FileValue$filesOn, 'dragover', config.cK),
		A2(
			$elm$core$List$cons,
			A2($mpizenberg$elm_file$FileValue$filesOn, 'drop', config.cH),
			function () {
				var _v0 = config.cI;
				if (_v0.$ === 1) {
					return _List_Nil;
				} else {
					var id = _v0.a.b_;
					var msg = _v0.a.co;
					return _List_fromArray(
						[
							$elm$html$Html$Attributes$id(id),
							A3($mpizenberg$elm_file$FileValue$onWithId, id, 'dragleave', msg)
						]);
				}
			}()));
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $elm$html$Html$Attributes$target = $elm$html$Html$Attributes$stringProperty('target');
var $author$project$Views$Modals$viewSchemaSwitchModal = F3(
	function (_switch, schema, storedSchemas) {
		return A4(
			$author$project$Views$Modals$modal,
			$author$project$Conf$conf.b0.c6,
			A3(
				$author$project$Libs$Std$cond,
				$pzp1997$assoc_list$AssocList$isEmpty(schema.dp),
				function (_v0) {
					return 'Welcome to Schema Viz';
				},
				function (_v1) {
					return 'Load a new schema';
				}),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('row row-cols-1 row-cols-sm-2 row-cols-lg-3')
						]),
					A2(
						$elm$core$List$map,
						function (s) {
							return A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('col')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('card h-100')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('card-body')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$h5,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('card-title')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(s.R)
															]))
													])),
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('card-footer text-end')
													]),
												_List_fromArray(
													[
														A3(
														$author$project$Views$Bootstrap$bsButton,
														0,
														_List_fromArray(
															[
																$elm$html$Html$Events$onClick(
																$author$project$Models$UseSchema(s))
															]),
														_List_fromArray(
															[
																$elm$html$Html$text('Use this schema')
															]))
													]))
											]))
									]));
						},
						storedSchemas)),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'margin', '1em 0')
						]),
					_List_fromArray(
						[
							A3(
							$mpizenberg$elm_file$FileValue$hiddenInputSingle,
							'file-loader',
							_List_fromArray(
								['.sql,.json']),
							$author$project$Models$FileSelected),
							A2(
							$elm$html$Html$label,
							_Utils_ap(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$for('file-loader'),
										$elm$html$Html$Attributes$class('drop-zone')
									]),
								$mpizenberg$elm_file$FileValue$onDrop(
									{
										cH: $author$project$Models$FileDropped,
										cI: $elm$core$Maybe$Just(
											{b_: 'file-drop', co: $author$project$Models$FileDragLeave}),
										cK: $author$project$Models$FileDragOver
									})),
							_List_fromArray(
								[
									_switch.cd ? A2(
									$elm$html$Html$span,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('spinner-grow text-secondary'),
											$author$project$Libs$Std$role('status')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('visually-hidden')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Loading...')
												]))
										])) : A2(
									$elm$html$Html$span,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('title h5')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('Drop your schema here or click to browse')
										]))
								]))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2($elm$html$Html$Attributes$style, 'text-align', 'center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('Or just try out with '),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('dropdown dropup'),
									A2($elm$html$Html$Attributes$style, 'display', 'inline-block')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$a,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$id('schema-samples'),
											$elm$html$Html$Attributes$href('#'),
											$author$project$Views$Bootstrap$bsToggle(1),
											$author$project$Views$Bootstrap$ariaExpanded(false)
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('an example')
										])),
									A2(
									$elm$html$Html$ul,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('dropdown-menu'),
											$author$project$Views$Bootstrap$ariaLabelledBy('schema-samples')
										]),
									A2(
										$elm$core$List$map,
										function (name) {
											return A2(
												$elm$html$Html$li,
												_List_Nil,
												_List_fromArray(
													[
														A2(
														$elm$html$Html$a,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('dropdown-item'),
																$elm$html$Html$Attributes$href('#'),
																$elm$html$Html$Events$onClick(
																$author$project$Models$LoadSampleData(name))
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(name)
															]))
													]));
										},
										$pzp1997$assoc_list$AssocList$keys($author$project$Conf$schemaSamples)))
								]))
						]))
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$p,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('fw-lighter fst-italic text-muted')
						]),
					_List_fromArray(
						[
							$author$project$Libs$Std$bText('Schema Viz'),
							$elm$html$Html$text(' is an '),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$href('https://github.com/loicknuchel/schema-viz'),
									$elm$html$Html$Attributes$target('_blank')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('open source tool')
								])),
							$elm$html$Html$text(' done by '),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$href('https://twitter.com/sbouaked'),
									$elm$html$Html$Attributes$target('_blank')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('@sbouaked')
								])),
							$elm$html$Html$text(' and '),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$href('https://twitter.com/loicknuchel'),
									$elm$html$Html$Attributes$target('_blank')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('@loicknuchel')
								]))
						]))
				]));
	});
var $author$project$Views$Modals$viewModals = F4(
	function (_switch, schema, storedSchemas, newLayout) {
		return _List_fromArray(
			[
				A3($author$project$Views$Modals$viewSchemaSwitchModal, _switch, schema, storedSchemas),
				$author$project$Views$Modals$viewCreateLayoutModal(newLayout),
				$author$project$Views$Modals$viewHelpModal
			]);
	});
var $elm$html$Html$Attributes$alt = $elm$html$Html$Attributes$stringProperty('alt');
var $author$project$Views$Bootstrap$bsToggleModal = function (targetId) {
	return _List_fromArray(
		[
			$author$project$Views$Bootstrap$bsToggle(2),
			$author$project$Views$Bootstrap$bsTarget(targetId)
		]);
};
var $author$project$Views$Bootstrap$bsToggleOffcanvas = function (targetId) {
	return _List_fromArray(
		[
			$author$project$Views$Bootstrap$bsToggle(4),
			$author$project$Views$Bootstrap$bsTarget(targetId),
			$author$project$Views$Bootstrap$ariaControls(targetId)
		]);
};
var $elm$html$Html$img = _VirtualDom_node('img');
var $elm$html$Html$nav = _VirtualDom_node('nav');
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $author$project$Models$DeleteLayout = function (a) {
	return {$: 29, a: a};
};
var $author$project$Models$LoadLayout = function (a) {
	return {$: 27, a: a};
};
var $author$project$Models$UpdateLayout = function (a) {
	return {$: 28, a: a};
};
var $lattyware$elm_fontawesome$FontAwesome$Solid$edit = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'edit',
	576,
	512,
	_List_fromArray(
		['M402.6 83.2l90.2 90.2c3.8 3.8 3.8 10 0 13.8L274.4 405.6l-92.8 10.3c-12.4 1.4-22.9-9.1-21.5-21.5l10.3-92.8L388.8 83.2c3.8-3.8 10-3.8 13.8 0zm162-22.9l-48.8-48.8c-15.2-15.2-39.9-15.2-55.2 0l-35.4 35.4c-3.8 3.8-3.8 10 0 13.8l90.2 90.2c3.8 3.8 10 3.8 13.8 0l35.4-35.4c15.2-15.3 15.2-40 0-55.2zM384 346.2V448H64V128h229.8c3.2 0 6.2-1.3 8.5-3.5l40-40c7.6-7.6 2.2-20.5-8.5-20.5H48C21.5 64 0 85.5 0 112v352c0 26.5 21.5 48 48 48h352c26.5 0 48-21.5 48-48V306.2c0-10.7-12.9-16-20.5-8.5l-40 40c-2.2 2.3-3.5 5.3-3.5 8.5z']));
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $lattyware$elm_fontawesome$FontAwesome$Solid$plus = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'plus',
	448,
	512,
	_List_fromArray(
		['M416 208H272V64c0-17.67-14.33-32-32-32h-32c-17.67 0-32 14.33-32 32v144H32c-17.67 0-32 14.33-32 32v32c0 17.67 14.33 32 32 32h144v144c0 17.67 14.33 32 32 32h32c17.67 0 32-14.33 32-32V304h144c17.67 0 32-14.33 32-32v-32c0-17.67-14.33-32-32-32z']));
var $lattyware$elm_fontawesome$FontAwesome$Solid$trashAlt = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'trash-alt',
	448,
	512,
	_List_fromArray(
		['M32 464a48 48 0 0 0 48 48h288a48 48 0 0 0 48-48V128H32zm272-256a16 16 0 0 1 32 0v224a16 16 0 0 1-32 0zm-96 0a16 16 0 0 1 32 0v224a16 16 0 0 1-32 0zm-96 0a16 16 0 0 1 32 0v224a16 16 0 0 1-32 0zM432 32H312l-9.4-18.7A24 24 0 0 0 281.1 0H166.8a23.72 23.72 0 0 0-21.4 13.3L136 32H16A16 16 0 0 0 0 48v32a16 16 0 0 0 16 16h416a16 16 0 0 0 16-16V48a16 16 0 0 0-16-16z']));
var $lattyware$elm_fontawesome$FontAwesome$Solid$upload = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'upload',
	512,
	512,
	_List_fromArray(
		['M296 384h-80c-13.3 0-24-10.7-24-24V192h-87.7c-17.8 0-26.7-21.5-14.1-34.1L242.3 5.7c7.5-7.5 19.8-7.5 27.3 0l152.2 152.2c12.6 12.6 3.7 34.1-14.1 34.1H320v168c0 13.3-10.7 24-24 24zm216-8v112c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V376c0-13.3 10.7-24 24-24h136v8c0 30.9 25.1 56 56 56h80c30.9 0 56-25.1 56-56v-8h136c13.3 0 24 10.7 24 24zm-124 88c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20zm64 0c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20z']));
var $author$project$Views$Navbar$viewLayoutButton = F2(
	function (currentLayout, layouts) {
		return $elm$core$List$isEmpty(layouts) ? A3(
			$author$project$Views$Bootstrap$bsButton,
			0,
			_Utils_ap(
				_List_fromArray(
					[
						$elm$html$Html$Attributes$title('Save your current layout to reload it later')
					]),
				$author$project$Views$Bootstrap$bsToggleModal($author$project$Conf$conf.b0.cs)),
			_List_fromArray(
				[
					$elm$html$Html$text('Save layout')
				])) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('btn-group')
				]),
			_Utils_ap(
				A2(
					$elm$core$Maybe$withDefault,
					_List_fromArray(
						[
							A3(
							$author$project$Views$Bootstrap$bsButton,
							0,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('dropdown-toggle'),
									$author$project$Views$Bootstrap$bsToggle(1),
									$author$project$Views$Bootstrap$ariaExpanded(false)
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Layouts')
								]))
						]),
					A2(
						$elm$core$Maybe$map,
						function (layout) {
							return _List_fromArray(
								[
									A3(
									$author$project$Views$Bootstrap$bsButton,
									0,
									_List_fromArray(
										[
											$elm$html$Html$Events$onClick(
											$author$project$Models$UpdateLayout(layout))
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('Update \'' + (layout + '\''))
										])),
									A3(
									$author$project$Views$Bootstrap$bsButton,
									0,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('dropdown-toggle dropdown-toggle-split'),
											$author$project$Views$Bootstrap$bsToggle(1),
											$author$project$Views$Bootstrap$ariaExpanded(false)
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('visually-hidden')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Toggle Dropdown')
												]))
										]))
								]);
						},
						currentLayout)),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$ul,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('dropdown-menu dropdown-menu-end')
							]),
						_Utils_ap(
							_List_fromArray(
								[
									A2(
									$elm$html$Html$li,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$a,
											_Utils_ap(
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('dropdown-item'),
														$elm$html$Html$Attributes$href('#')
													]),
												$author$project$Views$Bootstrap$bsToggleModal($author$project$Conf$conf.b0.cs)),
											_List_fromArray(
												[
													$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$plus),
													$elm$html$Html$text(' Create new layout')
												]))
										]))
								]),
							A2(
								$elm$core$List$map,
								function (l) {
									return A2(
										$elm$html$Html$li,
										_List_Nil,
										_List_fromArray(
											[
												A2(
												$elm$html$Html$a,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('dropdown-item'),
														$elm$html$Html$Attributes$href('#')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$span,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$title('Load layout'),
																$author$project$Views$Bootstrap$bsToggle(0),
																$elm$html$Html$Events$onClick(
																$author$project$Models$LoadLayout(l.R))
															]),
														_List_fromArray(
															[
																$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$upload)
															])),
														$elm$html$Html$text(' '),
														A2(
														$elm$html$Html$span,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$title('Update layout with current one'),
																$author$project$Views$Bootstrap$bsToggle(0),
																$elm$html$Html$Events$onClick(
																$author$project$Models$UpdateLayout(l.R))
															]),
														_List_fromArray(
															[
																$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$edit)
															])),
														$elm$html$Html$text(' '),
														A2(
														$elm$html$Html$span,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$title('Delete layout'),
																$author$project$Views$Bootstrap$bsToggle(0),
																$elm$html$Html$Events$onClick(
																$author$project$Models$DeleteLayout(l.R))
															]),
														_List_fromArray(
															[
																$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$trashAlt)
															])),
														$elm$html$Html$text(' '),
														A2(
														$elm$html$Html$span,
														_List_fromArray(
															[
																$elm$html$Html$Events$onClick(
																$author$project$Models$LoadLayout(l.R))
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(
																l.R + (' (' + ($elm$core$String$fromInt(
																	$pzp1997$assoc_list$AssocList$size(l.dp)) + ' tables)')))
															]))
													]))
											]));
								},
								layouts)))
					])));
	});
var $author$project$Models$ChangedSearch = function (a) {
	return {$: 10, a: a};
};
var $elm$html$Html$Attributes$autocomplete = function (bool) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var $lattyware$elm_fontawesome$FontAwesome$Solid$angleRight = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'angle-right',
	256,
	512,
	_List_fromArray(
		['M224.3 273l-136 136c-9.4 9.4-24.6 9.4-33.9 0l-22.6-22.6c-9.4-9.4-9.4-24.6 0-33.9l96.4-96.4-96.4-96.4c-9.4-9.4-9.4-24.6 0-33.9L54.3 103c9.4-9.4 24.6-9.4 33.9 0l136 136c9.5 9.4 9.5 24.6.1 34z']));
var $lattyware$elm_fontawesome$FontAwesome$Solid$angleDoubleRight = A5(
	$lattyware$elm_fontawesome$FontAwesome$Icon$Icon,
	'fas',
	'angle-double-right',
	448,
	512,
	_List_fromArray(
		['M224.3 273l-136 136c-9.4 9.4-24.6 9.4-33.9 0l-22.6-22.6c-9.4-9.4-9.4-24.6 0-33.9l96.4-96.4-96.4-96.4c-9.4-9.4-9.4-24.6 0-33.9L54.3 103c9.4-9.4 24.6-9.4 33.9 0l136 136c9.5 9.4 9.5 24.6.1 34zm192-34l-136-136c-9.4-9.4-24.6-9.4-33.9 0l-22.6 22.6c-9.4 9.4-9.4 24.6 0 33.9l96.4 96.4-96.4 96.4c-9.4 9.4-9.4 24.6 0 33.9l22.6 22.6c9.4 9.4 24.6 9.4 33.9 0l136-136c9.4-9.2 9.4-24.4 0-33.8z']));
var $author$project$Views$Navbar$columnSuggestion = F3(
	function (search, table, column) {
		var _v0 = column.ap;
		var name = _v0;
		return _Utils_eq(name, search) ? $elm$core$Maybe$Just(
			{
				O: A2(
					$elm$core$List$cons,
					$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$angleDoubleRight),
					_List_fromArray(
						[
							$elm$html$Html$text(
							' ' + ($author$project$Views$Helpers$formatTableId(table.b_) + '.')),
							A2(
							$elm$html$Html$b,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(
									$author$project$Views$Helpers$extractColumnName(column.ap))
								]))
						])),
				co: $author$project$Models$ShowTable(table.b_),
				V: 0 - 0.5
			}) : $elm$core$Maybe$Nothing;
	});
var $author$project$Views$Navbar$highlightMatch = F2(
	function (search, value) {
		return A2(
			$elm$core$List$drop,
			1,
			A3(
				$elm$core$List$foldr,
				F2(
					function (i, acc) {
						return A2(
							$elm$core$List$cons,
							A2(
								$elm$html$Html$b,
								_List_Nil,
								_List_fromArray(
									[
										$elm$html$Html$text(search)
									])),
							A2($elm$core$List$cons, i, acc));
					}),
				_List_Nil,
				A2(
					$elm$core$List$map,
					$elm$html$Html$text,
					A2($elm$core$String$split, search, value))));
	});
var $author$project$Views$Navbar$exactMatch = F2(
	function (search, text) {
		return _Utils_eq(text, search) ? 3 : 0;
	});
var $author$project$Views$Navbar$matchAtBeginning = F2(
	function (search, text) {
		return ((!(search === '')) && A2($elm$core$String$startsWith, search, text)) ? 2 : 0;
	});
var $author$project$Views$Navbar$matchNotAtBeginning = F2(
	function (search, text) {
		return ((!(search === '')) && (A2($elm$core$String$contains, search, text) && (!A2($elm$core$String$startsWith, search, text)))) ? 1 : 0;
	});
var $author$project$Views$Navbar$columnMatchingBonus = F2(
	function (search, table) {
		var columnNames = A2(
			$elm$core$List$map,
			function (c) {
				return $author$project$Views$Helpers$extractColumnName(c.ap);
			},
			$pzp1997$assoc_list$AssocList$values(table.N));
		return (!(search === '')) ? (A2(
			$elm$core$List$any,
			function (columnName) {
				return !(!A2($author$project$Views$Navbar$exactMatch, search, columnName));
			},
			columnNames) ? 0.5 : (A2(
			$elm$core$List$any,
			function (columnName) {
				return !(!A2($author$project$Views$Navbar$matchAtBeginning, search, columnName));
			},
			columnNames) ? 0.2 : (A2(
			$elm$core$List$any,
			function (columnName) {
				return !(!A2($author$project$Views$Navbar$matchNotAtBeginning, search, columnName));
			},
			columnNames) ? 0.1 : 0))) : 0;
	});
var $author$project$Views$Navbar$manyColumnBonus = function (table) {
	return (-1) / $pzp1997$assoc_list$AssocList$size(table.N);
};
var $author$project$Views$Navbar$shortNameBonus = function (name) {
	return (!$elm$core$String$length(name)) ? 0 : (1 / $elm$core$String$length(name));
};
var $author$project$Views$Navbar$tableShownMalus = function (table) {
	return (table.a6.di === 3) ? (-2) : 0;
};
var $author$project$Views$Navbar$matchStrength = F2(
	function (search, table) {
		var _v0 = table.bb;
		var name = _v0;
		return (((((A2($author$project$Views$Navbar$exactMatch, search, name) + A2($author$project$Views$Navbar$matchAtBeginning, search, name)) + A2($author$project$Views$Navbar$matchNotAtBeginning, search, name)) + $author$project$Views$Navbar$tableShownMalus(table)) + A2($author$project$Views$Navbar$columnMatchingBonus, search, table)) + (5 * $author$project$Views$Navbar$manyColumnBonus(table))) + $author$project$Views$Navbar$shortNameBonus(name);
	});
var $author$project$Views$Navbar$asSuggestions = F2(
	function (search, table) {
		return A2(
			$elm$core$List$cons,
			{
				O: A2(
					$elm$core$List$cons,
					$lattyware$elm_fontawesome$FontAwesome$Icon$viewIcon($lattyware$elm_fontawesome$FontAwesome$Solid$angleRight),
					A2(
						$elm$core$List$cons,
						$elm$html$Html$text(' '),
						A2(
							$author$project$Views$Navbar$highlightMatch,
							search,
							$author$project$Views$Helpers$formatTableId(table.b_)))),
				co: $author$project$Models$ShowTable(table.b_),
				V: 0 - A2($author$project$Views$Navbar$matchStrength, search, table)
			},
			A2(
				$elm$core$List$filterMap,
				A2($author$project$Views$Navbar$columnSuggestion, search, table),
				$pzp1997$assoc_list$AssocList$values(table.N)));
	});
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Views$Navbar$buildSuggestions = F2(
	function (search, tables) {
		return A2(
			$elm$core$List$take,
			30,
			A2(
				$elm$core$List$sortBy,
				function ($) {
					return $.V;
				},
				A2(
					$elm$core$List$concatMap,
					$author$project$Views$Navbar$asSuggestions(search),
					tables)));
	});
var $elm$html$Html$form = _VirtualDom_node('form');
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $author$project$Views$Navbar$viewSearchBar = F2(
	function (search, tables) {
		return $elm$core$List$isEmpty(tables) ? A2(
			$elm$html$Html$form,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('d-flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$input,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$type_('search'),
									$elm$html$Html$Attributes$class('form-control'),
									$elm$html$Html$Attributes$value(search),
									$elm$html$Html$Attributes$placeholder('Search'),
									$author$project$Views$Bootstrap$ariaLabel('Search'),
									$elm$html$Html$Attributes$autocomplete(false),
									$elm$html$Html$Events$onInput($author$project$Models$ChangedSearch),
									$elm$html$Html$Attributes$id($author$project$Conf$conf.b0.c9)
								]),
							_List_Nil)
						]))
				])) : A2(
			$elm$html$Html$form,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('d-flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('dropdown')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$input,
							_Utils_ap(
								_List_fromArray(
									[
										$elm$html$Html$Attributes$type_('search'),
										$elm$html$Html$Attributes$class('form-control'),
										$elm$html$Html$Attributes$value(search),
										$elm$html$Html$Attributes$placeholder('Search'),
										$author$project$Views$Bootstrap$ariaLabel('Search'),
										$elm$html$Html$Attributes$autocomplete(false),
										$elm$html$Html$Events$onInput($author$project$Models$ChangedSearch)
									]),
								$author$project$Views$Bootstrap$bsToggleDropdown($author$project$Conf$conf.b0.c9)),
							_List_Nil),
							A2(
							$elm$html$Html$ul,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('dropdown-menu')
								]),
							A2(
								$elm$core$List$map,
								function (s) {
									return A2(
										$elm$html$Html$li,
										_List_Nil,
										_List_fromArray(
											[
												A2(
												$elm$html$Html$a,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('dropdown-item'),
														A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
														$elm$html$Html$Events$onClick(s.co)
													]),
												s.O)
											]));
								},
								A2($author$project$Views$Navbar$buildSuggestions, search, tables)))
						]))
				]));
	});
var $author$project$Views$Navbar$viewNavbar = F4(
	function (search, currentLayout, layouts, tables) {
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$nav,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$id('navbar'),
						$elm$html$Html$Attributes$class('navbar navbar-expand-md navbar-light bg-white shadow-sm')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container-fluid')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_Utils_ap(
									_List_fromArray(
										[
											$elm$html$Html$Attributes$href('#'),
											$elm$html$Html$Attributes$class('navbar-brand')
										]),
									$author$project$Views$Bootstrap$bsToggleOffcanvas($author$project$Conf$conf.b0.cg)),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$img,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$src('assets/logo.png'),
												$elm$html$Html$Attributes$alt('logo'),
												$elm$html$Html$Attributes$height(24),
												$elm$html$Html$Attributes$class('d-inline-block align-text-top')
											]),
										_List_Nil),
										$elm$html$Html$text(' Schema Viz')
									])),
								A2(
								$elm$html$Html$button,
								_Utils_ap(
									_List_fromArray(
										[
											$elm$html$Html$Attributes$type_('button'),
											$elm$html$Html$Attributes$class('navbar-toggler'),
											$author$project$Views$Bootstrap$ariaLabel('Toggle navigation')
										]),
									$author$project$Views$Bootstrap$bsToggleCollapse('navbar-content')),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$span,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('navbar-toggler-icon')
											]),
										_List_Nil)
									])),
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('collapse navbar-collapse'),
										$elm$html$Html$Attributes$id('navbar-content')
									]),
								_List_fromArray(
									[
										A2($author$project$Views$Navbar$viewSearchBar, search, tables),
										A2(
										$elm$html$Html$ul,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('navbar-nav me-auto')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$li,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('nav-item')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$a,
														_Utils_ap(
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$href('#'),
																	$elm$html$Html$Attributes$class('nav-link')
																]),
															$author$project$Views$Bootstrap$bsToggleModal($author$project$Conf$conf.b0.bY)),
														_List_fromArray(
															[
																$elm$html$Html$text('?')
															]))
													]))
											])),
										A3(
										$author$project$Libs$Std$cond,
										$elm$core$List$length(tables) > 0,
										function (_v0) {
											return A2($author$project$Views$Navbar$viewLayoutButton, currentLayout, layouts);
										},
										function (_v1) {
											return A2($elm$html$Html$div, _List_Nil, _List_Nil);
										})
									]))
							]))
					]))
			]);
	});
var $author$project$View$viewToasts = A2(
	$elm$html$Html$div,
	_List_fromArray(
		[
			$elm$html$Html$Attributes$id('toast-container'),
			$elm$html$Html$Attributes$class('toast-container position-fixed bottom-0 end-0 p-3')
		]),
	_List_Nil);
var $author$project$View$viewApp = function (model) {
	return _Utils_ap(
		_List_fromArray(
			[$lattyware$elm_fontawesome$FontAwesome$Styles$css]),
		_Utils_ap(
			A4(
				$author$project$Views$Navbar$viewNavbar,
				model.a6.c8,
				model.a6.as,
				model.c4.cb,
				$pzp1997$assoc_list$AssocList$values(model.c4.dp)),
			_Utils_ap(
				$author$project$Views$Menu$viewMenu(model.c4),
				_Utils_ap(
					_List_fromArray(
						[
							A2($author$project$View$viewErd, model.bq, model.c4)
						]),
					_Utils_ap(
						A4(
							$author$project$Views$Modals$viewModals,
							model.X,
							model.c4,
							model.dl,
							A2($elm$core$Maybe$withDefault, '', model.a6.cr)),
						_List_fromArray(
							[$author$project$View$viewToasts]))))));
};
var $author$project$Main$view = function (model) {
	return {
		bm: $author$project$View$viewApp(model),
		dv: 'Schema Viz'
	};
};
var $author$project$Main$main = $elm$browser$Browser$document(
	{b4: $author$project$Main$init, dn: $author$project$Main$subscriptions, dz: $author$project$Main$update, dC: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	$elm$json$Json$Decode$succeed(0))(0)}});}(this));