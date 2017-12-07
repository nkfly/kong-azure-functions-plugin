return {
    fields = {
      function_app = { required = true, type = "string" },
      function_name = { type = "string" },
      function_route = { type = "string" },
      function_key = { type = "string", default = "" },
      function_clientid = { type = "string", default = "" },
      port = { type = "number", default = 443 },
      timeout = { required = true, type = "number", default = 60000  },
      keepalive = { required = true, type = "number", default = 60000  }
    }
  }
  