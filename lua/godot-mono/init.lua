local M = {}

local utils = require("godot-mono.utils")

---@type table<string, string>
local CONSTANTS = {
    MAIN_SCENE = "project.godot",
}

---@type string?
M.last_scene = nil
---@type string?
M.godot_executable = nil
---@type string[]?
M.build_command = nil
---@type vim.SystemOpts
M.options = {}
---@type boolean
M.has_main = false

---@param obj vim.SystemCompleted
---@param on_success function
M.handle_build = function(obj, on_success)
    if obj.code == 1 then
        local message = "Output:" .. obj.stdout
        vim.notify(
            message,
            vim.log.levels.ERROR,
            { title = "Build process failed with exit code: " .. obj.code }
        )
        return
    end

    vim.notify("Build completed successfully", vim.log.levels.INFO)
    on_success()
end

---@param obj vim.SystemCompleted
M.handle_run = function(obj)
    if obj.code == 1 then
        local message = "Output:" .. obj.stdout
        vim.notify(
            message,
            vim.log.levels.ERROR,
            { title = "Run process failed with exit code: " .. obj.code }
        )
        return
    end

    vim.notify("Run completed successfully", vim.log.levels.INFO)
end

---@summary
-- Runs the specified Godot scene using the Godot executable.
---@param scene_name string The name of the scene to run
M.run_scene = function(scene_name)
    if M.godot_executable == nil then
        vim.notify("Godot executable not set")
        return
    end

    local godot_command = { M.godot_executable }

    if scene_name ~= CONSTANTS.MAIN_SCENE then
        table.insert(godot_command, scene_name)
    end

    M.last_scene = scene_name

    vim.notify("Building scene")

    vim.system(M.build_command, M.options, function(obj)
        M.handle_build(obj, function()
            vim.notify("Running scene")
            vim.system(godot_command, M.options, M.handle_run)
        end)
    end)
end

---@summary
-- Opens a picker to select and run a Godot scene file.
M.select_scene = function()
    local snacks = require("godot-mono.providers.snacks").new({
        title = " Scenes",
        output = function(item)
            if item == nil then
                vim.notify("Error running scene", vim.log.levels.ERROR)
                return
            end

            local file = item.file

            M.run_scene(file)
        end,
    })

    if snacks == nil then
        return
    end

    snacks.provider.picker.pick({
        layout = {
            hidden = { "preview" },
            layout = {
                width = 0.4,
                height = 0.5,
            },
        },
        finder = "files",
        format = "file",
        ft = "tscn",
        title = snacks.title,
        confirm = snacks:display(),
    })
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
    if not M.has_main then
        vim.notify(
            "No main scene defined in project.godot",
            vim.log.levels.ERROR
        )
        return
    end

    M.run_scene(CONSTANTS.MAIN_SCENE)
end

---@param opts table Optional setup parameters
M.setup = function(opts)
    M.has_main = utils.has_project_file()

    if not M.has_main then
        return
    end

    vim.notify("Godot-Mono initialized", vim.log.levels.INFO)

    M.godot_executable = utils.get_executable()

    M.build_command = { "dotnet", "build", "-c", "Debug" }

    M.options = { text = true, cwd = vim.fn.getcwd() }

    vim.api.nvim_create_user_command("GodotRun", M.select_scene, {})
    vim.api.nvim_create_user_command("GodotRunLast", M.run_last_scene, {})
    vim.api.nvim_create_user_command("GodotRunMain", M.run_main_scene, {})
end

return M
