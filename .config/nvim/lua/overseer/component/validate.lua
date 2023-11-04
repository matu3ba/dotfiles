local constants = require("overseer.constants")
-- local overseer = require "overseer"
local find_index_task = function(task_list, task_name)
  local j = -1
  for i = 1, #task_list do
    if task_list[i].name == task_name then
      j = i
      break
    end
  end
  return j
end

return {
  desc = "Create and execute derived task to validate result",
  params = { -- parameters passed to component
    type = "string" -- task name as dependency
  },
  editable = false, -- editing disallowed
  serializable = true, -- serializing disabled
  constructor = function(params)
    return {
      on_init = function(self, task)
        local task_list = require("overseer").list_tasks()
        local fin_i = find_index_task(task_list, params[1])
        if fin_i == -1 then
          -- idea: add things to result of job
          task:finalize(constants.STATUS.FAILURE)
        else
          task.name = "validate" .. task.name
          task.cmd = task_list[fin_i].cmd
          task.cwd = task_list[fin_i].cwd
          task.env = task_list[fin_i].env
          self.expected_output = task_list[fin_i].result
          self.expected_exitcode = task_list[fin_i].exit_code
        end
      end,
      ---@return nil|boolean
      on_reset = function(self, task) -- reset => task runs again
        local _ = task
        local task_list = require("overseer").list_tasks()
        local fin_i = find_index_task(task_list, params[1])
        if fin_i == -1 then
          task:finalize(constants.STATUS.FAILURE)
        else
          if self.expected_output ~= task_list[fin_i].result then
            -- TODO how to provide reason for exit failure?
            task:finalize(constants.STATUS.FAILURE)
          end
          if self.expected_exitcode ~= task_list[fin_i].exit_code then
            task:finalize(constants.STATUS.FAILURE)
          end
        end
      end,
      ---@param code number The process exit code
      on_exit = function(self, task, code)
        if self.expected_exitcode == code then
          task:finalize(constants.STATUS.SUCCESS)
        else
          task:finalize(constants.STATUS.FAILURE)
        end
      end,
    }
  end,
}
