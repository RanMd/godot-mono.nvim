local M = {}

M.last_scene = nil
M.godot_executable = nil

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

M.run_last_scene = function()
    if M.last_scene == nil then
        vim.notify("No scene was run yet!")
        return
    end

    M.run_scene(M.last_scene)
end

M.run_main_scene = function()
    local main_scene = M.find_main_scene()
    if main_scene == nil then
        vim.notify("No main scene found in project.godot", vim.log.levels.ERROR)
        return
    end

    M.run_scene(main_scene)
end

M.setup = function(opts)
    M.godot_executable = M.get_executable()

    vim.api.nvim_create_user_command("GodotRun", M.run, {})
    vim.api.nvim_create_user_command("GodotRunLast", M.run_last_scene, {})
    vim.api.nvim_create_user_command("GodotRunMain", M.run_main_scene, {})
end

return M
