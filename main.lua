local M = {}

M.config = {
    separators = {
        left = "",
        right = "",
    },
    mode = {
        normal = "NORMAL",
        select = "SELECT",
        unset = "UNSET",
    },
}

---Merges t2 into t1
---@param t1 table
---@param t2 table
local function table_merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k]) == "table") then
            table_merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

function M.setup(_, opts)
    table_merge(M.config, opts or {})

    -- set statusline functions
    function Status:mode()
        local name = M.config.mode.normal
        -- self object represents statusline
        local main = self:style().main
        local alt = self:style().alt

        if cx.active.mode.is_select then
            name = M.config.mode.select
        elseif cx.active.mode.is_unset then
            name = M.config.mode.unset
        end

        return ui.Line({
            ui.Span(" " .. name .. " "):style(main),
            ui.Span(M.config.separators.left):fg(main.bg):bg(alt.bg)
        })
    end

    function Status:size()
        local alt = self:style().alt
        local hovered = cx.active.current.hovered
        if not hovered then return ui.Span(M.config.separators.left):fg(alt.bg) end

        local size = ya.readable_size(hovered:size() or hovered.cha.len)
        return ui.Line({
            ui.Span(" " .. size .. " "):style(alt),
            ui.Span(M.config.separators.left):fg(alt.bg)
        })
    end

    function Status:name()
        local hovered = cx.active.current.hovered
        if not hovered then return ui.Span("") end

        local linked = ""
        if hovered.link_to ~= nil then
            linked = " -> " .. tostring(hovered.link_to)
        end

        return ui.Span(" " .. hovered.name .. linked)
    end

    function Status:percent()
        local alt = self:style().alt
        ---@type integer|string
        local percent = 0
        local cursor = cx.active.current.cursor
        local length = #cx.active.current.files

        if cursor ~= 0 and length ~= 0 then
            percent = math.floor((cursor + 1) * 100 / length)
        end

        if percent == 0 then
            percent = "Top"
        elseif percent == 100 then
            percent = "Bot"
        else
            percent = string.format("%d%%", percent)
        end

        return ui.Line({
            ui.Span(" "),
            ui.Span(M.config.separators.right):fg(alt.bg),
            ui.Span(" " .. percent .. " "):style(alt)
        })
    end

    function Status:position()
        local main = self:style().main
        local alt = self:style().alt
        local cursor = cx.active.current.cursor
        local lenght = #cx.active.current.files

        return ui.Line({
            ui.Span(M.config.separators.right):fg(main.bg):bg(alt.bg),
            ui.Span(string.format(" %d/%d ", cursor + 1, lenght)):style(main)
        })
    end
end

return M
