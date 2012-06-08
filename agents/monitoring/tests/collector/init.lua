--[[
Copyright 2012 Rackspace

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]

local async = require('async')

local run = require('monitoring/collector').run
local request = require('monitoring/collector/http/utils').request
local setTimeout = require('timer').setTimeout

local exports = {}

exports['test_traceroute'] = function(test, asserts)
  local collector

  async.series({
    function(callback)
      collector = run({p = 7889, h = '127.0.0.1'})
      setTimeout(500, callback)
    end,

    function(callback)
      -- Test invalid route
      request('http://127.0.0.1:7889/inexistent', 'GET', nil, nil, {parseResponse = true}, function(err, res)
        asserts.ok(not err)
        asserts.equals(res.status_code, 404)
        asserts.dequals(res.body, {error = 'Path "/inexistent" not found'})
        callback()
      end)
    end,

    function(callback)
      -- Test missing target argument
      request('http://127.0.0.1:7889/v1.0/traceroute', 'GET', nil, nil, {parseResponse = true}, function(err, res)
        asserts.ok(not err)
        asserts.equals(res.status_code, 400)
        asserts.dequals(res.body, {error = 'Missing a required "target" argument'})
        callback()
      end)
    end,

    function(callback)
      -- Test traceroute
      request('http://127.0.0.1:7889/v1.0/traceroute?target=127.0.0.1', 'GET', nil, nil, {parseResponse = true}, function(err, res)
        asserts.ok(not err)
        asserts.equals(res.status_code, 200)
        asserts.dequals(#res.body, 1)
        asserts.dequals(res.body[1]['number'], 1)
        asserts.dequals(res.body[1]['ip'], '127.0.0.1')
        asserts.dequals(#res.body[1]['rtts'], 3)
        callback()
      end)
    end
  },

  function()
    collector:stop()
    test.done()
  end)
end

return exports
