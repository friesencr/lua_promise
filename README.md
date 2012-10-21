lua_promise
===========

A deferred value / promise akin to jquery's

A promise is a value that isn't there yet.  It provides a common interface for setting
up callbacks for when that value is resolved or otherwise. With the combination of the 'when'
function it gives complete control to the consumer of any async process.

Promise Example
```lua
-- provider of peoples
function get_list_of_people()
	local promise = Promise:new()
	talk_to_server(function(peeps)
		promise:resolve(peeps)
	end)
	return promise
end

-- consumer of people
get_list_of_people()
	:done(function(peoples)
		do_something(peoples)
	end)

```

The promise has has 2 methods for completing a promise.  They are resolve and reject.

Promise#resolve
Will call callbacks registered via done and always

Promise#reject
Will call callbacks registered via fail and always

The promise has 3 ways of consuming a value.  All of them require a callback function whos
first parameter is the value.  Those methods are always, done, and fail.

Promise#always
These callbacks will call regardless wether the promise is is resolved or failed

Promise#done
These callbacks will only call if the value is resolved

Promise#fail
These callbacks will only call if the value is rejected

Additionally a utility method for consuming promises is provided.  This is the 'when' method.
When can consume a series of values and returns a promise for when all of those values.  If all of
the values are resolved the 'done' callbacks are fired.  If any of the values fail the fail
callbacks are fired.  Always callbacks are always fired.  Non promise values can be passed in to
when, if the values are not promises those values are immediately resolved.  This is useful when
the client isnt aware of whether or not the values they are promises or not.  When the promise is
resolved it will call the callback with arguments in the same order they were specified.

```lua
promise1 = Promise:new()
normal_value = 'de'
promise2 = Promise:new()

when(promise1, normal_value, promise2)
	:done(function(a, b, c)
		a -- 'herp'
		b -- 'de'
		c -- 'derp'
	end)

promise1:resolve('herp')
promise2:resolve('derp')

```

Thanks :D
