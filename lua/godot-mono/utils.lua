local M = {}

---@summary
-- Gets the Godot executable path.
---@return string|nil # The path to the Godot executable, or nil if not found.
M.get_executable = function()
    if M.godot_executable ~= nil then
        return M.godot_executable
    end

    local extension = vim.fn.has("win32") == 1 and ".exe" or ""

    if vim.fn.executable("godot-mono" .. extension) == 1 then
        return "godot-mono" .. extension
    else
        vim.notify(
            "Godot executable not found. Please ensure Godot is installed and in your PATH. (e.g. 'godot-mono')",
            vim.log.levels.ERROR
        )
        return nil
    end
end

---@summary
-- Finds and returns the main scene path from project.godot.
---@return string|nil # Main scene path, or nil if not found.
M.find_main_scene = function()
    local project_file = vim.fn.findfile("project.godot", vim.fn.getcwd())

    local scene_path
    for line in io.lines(project_file) do
        scene_path = line:match('run/main_scene="res://([^"]+)"')
        if scene_path then
            return scene_path
        end
    end
end

return M
