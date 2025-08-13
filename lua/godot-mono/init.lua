local M = {}

local utils = require("godot-mono.utils")

M.last_scene = nil
M.godot_executable = nil

---@summary
-- Opens a picker to select and run a Godot scene file.
M.run = function()
    local snacks = require("snacks")
    snacks.picker.pick({
        layout = {
            hidden = { "preview" },
            layout = {
                width = 0.4,
                height = 0.5,
            },
        },
        title = " Scenes",
        finder = "files",
        format = "file",
        ft = "tscn",
        confirm = function(picker, item)
            picker:close()
            if item == nil then
                vim.notify("Error running scene", vim.log.levels.ERROR)
                return
            end

            local file = item.file

            M.run_scene(file)
        end,
    })
end

---@summary
-- Runs the specified Godot scene using the Godot executable.
---@param scene_name string The name of the scene to run
M.run_scene = function(scene_name)
    if M.godot_executable == nil then
        vim.notify("Godot executable not set")
        return
    end

    local godot_command = { M.godot_executable, scene_name }

    M.last_scene = scene_name

    vim.notify("Running Godot scene: " .. vim.inspect(godot_command))

    -- Run the Godot command asynchronously
    vim.system(godot_command, { text = true }, function(obj)
        if obj.stderr and #obj.stderr > 0 then
            vim.notify(obj.stderr, vim.log.levels.ERROR)
        end
    end)
end

---@summary
-- Runs the last Godot scene that was executed.
M.run_last_scene = function()
    if M.last_scene == nil then
        vim.notify("No scene was run yet!")
        return
    end

    M.run_scene(M.last_scene)
end

---@summary
-- Runs the main scene as defined in project.godot.
M.run_main_scene = function()
    local main_scene = utils.find_main_scene()
    if main_scene == nil then
        vim.notify("No main scene found in project.godot", vim.log.levels.ERROR)
        return
    end

    M.run_scene(main_scene)
end

---@param opts table Optional setup parameters
M.setup = function(opts)
    M.godot_executable = utils.get_executable()

    vim.api.nvim_create_user_command("GodotRun", M.run, {})
    vim.api.nvim_create_user_command("GodotRunLast", M.run_last_scene, {})
    vim.api.nvim_create_user_command("GodotRunMain", M.run_main_scene, {})
end

return M
