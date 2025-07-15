--- @type LazySpec
return {
  "mfussenegger/nvim-dap",
  cmd = "VeryLazy",
  config = function()
    local dap = require "dap"
    dap.configurations.python = {
      {
        name = "Python: Django",
        type = "python",
        request = "launch",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver", "--noreload", "9000" },
        django = true,
        justMyCode = true,
        pythonPath = function()
          local venv_path = os.getenv "VIRTUAL_ENV"
          if venv_path then return venv_path .. "/bin/python" end
          return "/usr/bin/python3"
        end,
      },
      {
        name = "Python: Chirpstack",
        type = "python",
        request = "launch",
        program = "${workspaceFolder}/src/chirpstack.py",
        args = { "configure", "-id=dd962157-6467-44ab-a982-679c06358361", "--all" },
        justMyCode = true,
        pythonPath = function()
          local venv_path = os.getenv "VIRTUAL_ENV"
          if venv_path then return venv_path .. "/bin/python" end
          return "/usr/bin/python3"
        end,
      },
      {
        name = "Python: Jarvisui",
        type = "python",
        request = "launch",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver", "--noreload", "0:8000" },
        django = true,
        justMyCode = true,
        pythonPath = function()
          local venv_path = os.getenv "VIRTUAL_ENV"
          if venv_path then return venv_path .. "/bin/python" end
          return "/usr/bin/python3"
        end,
      },
    }
  end,
}
