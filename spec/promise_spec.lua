require 'promise'

describe("new", function()

	it('can construct', function()
		local promise = Promise:new()
		assert.truthy(promise.state)
		assert.truthy(promise.reject)
		assert.truthy(promise.resolve)
		assert.truthy(promise.notify)
		assert.truthy(promise.always)
		assert.truthy(promise.done)
		assert.truthy(promise.fail)
		assert.truthy(promise.progress)
	end)

end)

describe("resolve", function()

	it("should pass in the accepted value", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:done(function(x) test = x end)
		p:resolve(val)
		assert.equals(val, test)
	end)

	it("will directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:resolve(val)
		p:done(function(x) test = x end)
		assert.equals(val, test)
	end)

end)

describe("reject", function()

	it("should pass in the accepted value", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:fail(function(x) test = x end)
		p:reject(val)
		assert.equals(val, test)
	end)

	it("will directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:reject(val)
		p:fail(function(x) test = x end)
		assert.equals(val, test)
	end)

end)

describe("always", function()

	it("should fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:always(function(x) test = x end)
		p:resolve(val)
		assert.equals(val, test)
	end)

	it("should fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:always(function(x) test = x end)
		p:reject(val)
		assert.equals(val, test)
	end)

	it("will directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:resolve(val)
		p:always(function(x) test = x end)
		assert.equals(val, test)
	end)

	it("will directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:reject(val)
		p:always(function(x) test = x end)
		assert.equals(val, test)
	end)

end)

describe("done", function()

	it("should fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:done(function(x) test = x end)
		p:resolve(val)
		assert.equals(val, test)
	end)

	it("should not fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:done(function(x) test = x end)
		p:reject(val)
		assert.equals(test, nil)
	end)

	it("will directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:resolve(val)
		p:done(function(x) test = x end)
		assert.equals(val, test)
	end)

	it("will not directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:reject(val)
		p:done(function(x) test = x end)
		assert.equals(test, nil)
	end)

end)

describe("fail", function()

	it("should not fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:fail(function(x) test = x end)
		p:resolve(val)
		assert.equals(test, nil)
	end)

	it("should fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:fail(function(x) test = x end)
		p:reject(val)
		assert.equals(test, val)
	end)

	it("will not directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:resolve(val)
		p:fail(function(x) test = x end)
		assert.equals(test, nil)
	end)

	it("will directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise:new()
		p:reject(val)
		p:fail(function(x) test = x end)
		assert.equals(test, val)
	end)

end)

describe("notify", function()

	it("updates progress subscribers", function()
		local p = Promise:new()
		local count = 0
		p:progress(function(x) count = count + x end)
		p:notify(1)
		p:notify(2)
		assert.equals(count, 3)
	end)

end)

describe("when", function()

	it("returns a promise", function()
		local promise = when()
		assert.truthy(promise.state)
		assert.truthy(promise.reject)
		assert.truthy(promise.resolve)
		assert.truthy(promise.notify)
		assert.truthy(promise.always)
		assert.truthy(promise.done)
		assert.truthy(promise.fail)
		assert.truthy(promise.progress)
	end)

	it("resolves when all promieses are met", function()

		local p1 = Promise:new()
		local p2 = Promise:new()
		local y1, y2

		when(p1, p2):done(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p1:resolve(1)
		p2:resolve(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)
	end)

	it("is rejects if any of the promises are broken", function()
		local p1 = Promise:new()
		local p2 = Promise:new()
		local y1, y2

		when(p1, p2):fail(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p1:resolve(1)
		p2:reject(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)
	end)

	it("can handle non deferred values", function()
		local p1 = 1
		local p2 = Promise:new()
		local y1, y2

		when(p1, p2):fail(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p2:reject(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)

	end)

end)
