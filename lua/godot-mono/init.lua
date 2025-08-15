local M = {}

local utils = require("godot-mono.utils")

---@class GodotMonoOptions
---@field opts? { godot_executable: string } Optional nested options table.

---@type table<string, string>
local CONSTANTS = {
    MAIN_SCENE = "project.godot",
}

---@type string?
local last_scene = nil
---@type string?
local godot_executable = nil
---@type string[]
local build_command = nil
---@type vim.SystemOpts
local options = {}
---@type boolean
local has_main = false

---@param obj vim.SystemCompleted
---@param on_success function
local function handle_build(obj, on_success)
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
local function handle_run(obj)
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
local function run_scene(scene_name)
    if godot_executable == nil then
        vim.notify("Godot executable not set")
        return
    end

    local godot_command = { godot_executable }

    if scene_name ~= CONSTANTS.MAIN_SCENE then
        table.insert(godot_command, scene_name)
    end

    last_scene = scene_name

    vim.notify("Building scene")

    vim.system(build_command, options, function(obj)
        handle_build(obj, function()
            vim.notify("Running scene")
            vim.system(godot_command, options, handle_run)
        end)
    end)
end

---@summary
-- Opens a picker to select and run a Godot scene file.
local function select_scene()
    local snacks = require("godot-mono.providers.snacks").new({
        title = " Scenes",
        output = function(item)
            if item == nil then
                vim.notify("Error running scene", vim.log.levels.ERROR)
                return
            end

            local file = item.file

            run_scene(file)
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
local function run_last_scene()
    if last_scene == nil then
        vim.notify("No scene was run yet!")
        return
    end

    run_scene(last_scene)
end

---@summary
-- Runs the main scene as defined in project.godot.
local function run_main_scene()
    if not has_main then
        vim.notify(
            "No main scene defined in project.godot",
            vim.log.levels.ERROR
        )
        return
    end

    run_scene(CONSTANTS.MAIN_SCENE)
end

---@param opts? GodotMonoOptions Optional setup parameters
M.setup = function(opts)
    opts = (opts and opts.opts) or opts or {}
    has_main = utils.has_project_file()

    if not has_main then
        return
    end

    godot_executable = opts.godot_executable or utils.get_executable()

    build_command = { "dotnet", "build", "-c", "Debug" }

    options = { text = true, cwd = vim.fn.getcwd() }

    vim.api.nvim_create_user_command("GodotRun", select_scene, {})
    vim.api.nvim_create_user_command("GodotRunLast", run_last_scene, {})
    vim.api.nvim_create_user_command("GodotRunMain", run_main_scene, {})
end

return M
