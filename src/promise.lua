Promise = {}
Promise.__index = Promise

--
-- server functions
--

function null_or_unpack(val)
	if val then
		return unpack(val)
	else
		return nil
	end
end

function Promise:new()
	local obj = {
		is_deferred = true,
		_state = 'pending',
		_callbacks = {}
	}
	setmetatable(obj, Promise)
	return obj
end

function Promise:reject(...)
	assert(self:state() == 'pending')
	self._value = arg
	self._state = 'rejected'

	for i,v in ipairs(self._callbacks) do
		if v.event == 'always' or v.event == 'fail' then
			v.callback(null_or_unpack(arg))
		end
	end
	self._callbacks = {}
end

function Promise:resolve(...)
	assert(self:state() == 'pending')
	self._value = arg
	self._state = 'resolved'

	for i,v in ipairs(self._callbacks) do
		if v.event == 'always' or v.event == 'done' then
			v.callback(null_or_unpack(arg))
		end
	end
	self._callbacks = {}
end

function Promise:notify(...)
	assert(self:state() == 'pending')
	for i,v in ipairs(self._callbacks) do
		if v.event == 'progress' then
			v.callback(null_or_unpack(arg))
		end
	end
end


--
-- client function
--

function Promise:always(callback)
	if self:state() ~= 'pending' then
		callback(null_or_unpack(self._value))
	else
		table.insert(self._callbacks, { event = 'always', callback = callback })
	end
	return self
end

function Promise:done(callback)
	if self:state() == 'resolved' then
		callback(null_or_unpack(self._value))
	elseif self:state() == 'pending' then
		table.insert(self._callbacks, { event = 'done', callback = callback })
	end
	return self
end

function Promise:fail(callback)
	if self:state() == 'rejected' then
		callback(null_or_unpack(self._value))
	elseif self:state() == 'pending' then
		table.insert(self._callbacks, { event = 'fail', callback = callback })
	end
	return self
end

function Promise:progress(callback)
	if self:state() == 'pending' then
		table.insert(self._callbacks, { event = 'progress', callback = callback })
	end
	return self
end


--
-- utility functions
--

function Promise:state()
	return self._state
end

function when(...)
	local deferred = Promise:new()
	local returns = {}
	local total = # arg
	local completed = 0
	local failed = 0
	for i,v in ipairs(arg) do
		if (v and type(v) == 'table' and v.is_deferred) then
			local promise = v
			v:always(function(val)
				if promise:state() == 'rejected' then
					failed = failed + 1
				end
				completed = completed + 1
				returns[i] = val
				if completed == total then
					if failed > 0 then
						deferred:reject(null_or_unpack(returns))
					else
						deferred:resolve(null_or_unpack(returns))
					end
				end
			end)
		else
			returns[i] = v
			completed = completed + 1
		end
	end
	return deferred
end
