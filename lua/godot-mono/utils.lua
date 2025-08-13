local M = {}

---@summary
-- Gets the Godot executable path.
---@return string|nil # The path to the Godot executable, or nil if not found.
M.get_executable = function()
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
---@return boolean # True if main scene is found, false otherwise.
M.has_project_file = function()
    local project_file = vim.fn.findfile("project.godot", vim.fn.getcwd())

    if not project_file then
        return false
    end

    return true
end

return M
