local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local http = require "resty.http"
local pl_string = require "pl.stringx"

local req_get_method = ngx.req.get_method
local req_get_body_data = ngx.req.get_body_data
local ngx_get_headers = ngx.req.get_headers
local ngx_req_read_body = ngx.req.read_body

local ngx_log = ngx.log

local AzureFunctionsHandler = BasePlugin:extend()

function AzureFunctionsHandler:new()
  AzureFunctionsHandler.super.new(self, "azure-functions")
end

function AzureFunctionsHandler:access(conf)
  AzureFunctionsHandler.super.access(self)

  local host = string.format("%s.azurewebsites.net", conf.function_app)

  -- Trigger request
  local client = http.new()
  client:connect(host, conf.port)
  client:set_timeout(conf.timeout)

  if conf.port == 443 then
    local ok, err = client:ssl_handshake()
    if not ok then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end
  end

  local queryString = ""
  local keys = pl_string.split(ngx.var.request_uri, "?")
  if #keys > 1 then
    queryString = "?" .. keys[2]
  end

  local path
  if conf.function_name ~= nil then
    path = string.format("/api/%s", conf.function_name)
  else
    -- remove starting slash
    local request_uri = keys[1]:sub(2, -1)

    local route_groups = pl_string.split(conf.function_route, "/")
    local uri_groups = pl_string.split(request_uri, "/")

    if #route_groups ~= #uri_groups then
      ngx.log(ngx.ERR, "path mapping to Azure Functions route not correct")
      return ngx.exit(400)
    end

    for i = 1, #route_groups do
      local start_character = route_groups[1]:sub(1, 1)
      local end_character = route_groups[1]:sub(-1, -1)

      if start_character == '{' and end_character == '}' then
        route_groups[i] = uri_groups[i]
      end
    end

    path = route_groups[1]

    for i = 2, #route_groups do
      path = path .. "/" .. route_groups[i]
    end
  end
  
  local headers = ngx_get_headers()
  if conf.function_key ~= "" then
    headers['x-functions-key'] = conf.function_key
  end

  if conf.function_clientid ~= "" then
    headers['x-functions-clientid'] = conf.function_clientid
  end

  local method = req_get_method()
  local res
  local err
  if method == "GET" then
    res, err = client:request {
      method = method,
      path = path .. queryString,
      headers = headers
    }
  else
    ngx_req_read_body()
    local body = req_get_body_data()

    if body == nil then
      body = ""
    end

    headers['content-length'] = tostring(#body)

    res, err = client:request {
      method = method,
      path = path .. queryString,
      body = body,
      headers = headers
    }
  end

  if not res then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  local body = res:read_body()

  local headers = res.headers

  local ok, err = client:set_keepalive(conf.keepalive)
  if not ok then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  ngx.status = res.status

  -- Send response to client
  for k, v in pairs(headers) do
    ngx.header[k] = v
  end

  ngx.say(body)

  return ngx.exit(res.status)
end

AzureFunctionsHandler.PRIORITY = 750

return AzureFunctionsHandler
