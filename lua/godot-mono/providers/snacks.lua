---@class GodotMono.Snacks
---@field output function The function to call when a selection is made
---@field provider table The path to the provider
---@field title string The title of the provider's window
local Snacks = {}

---@class GodotMono.SnacksArgs
---@field output function The function to call when a selection is made
---@field title string The title of the provider's window

---@param args GodotMono.SnacksArgs
function Snacks.new(args)
    local ok, snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("Snacks is not installed", vim.log.levels.ERROR)
        return
    end

    return setmetatable({
        output = args.output,
        provider = snacks,
        title = args.title,
    }, { __index = Snacks })
end

---@return function
function Snacks:display()
    return function(picker, item)
        picker:close()
        self.output(item)

        -- return true
    end
end

return Snacks
