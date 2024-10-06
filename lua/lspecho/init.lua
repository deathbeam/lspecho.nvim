local M = {}

local series = {}
local last_message = ''
local timer = vim.loop.new_timer()

local function escape_string(str)
    return str:gsub('([\\"])', '\\%1')
end

local function clear()
    timer:stop()
    timer:start(
        M.config.decay,
        0,
        vim.schedule_wrap(function()
            last_message = ''
            if M.config.echo then
                vim.api.nvim_command('redraw | echo ""')
            end
        end)
    )
end

local function log(msg)
    local client = msg.client or ''
    local title = msg.title or ''
    local message = msg.message or ''
    local percentage = msg.percentage or 0

    local out = ''
    if client ~= '' then
        out = out .. '[' .. client .. ']'
    end

    if percentage > 0 then
        out = out .. ' [' .. percentage .. '%]'
    end

    if title ~= '' then
        out = out .. ' ' .. title
    end

    if message ~= '' then
        if title ~= '' and vim.startswith(message, title) then
            message = string.sub(message, string.len(title) + 1)
        end

        message = message:gsub('%s*%d+%%', '')
        message = message:gsub('^%s*-', '')
        message = vim.trim(message)
        if message ~= '' then
            if title ~= '' then
                out = out .. ' - ' .. message
            else
                out = out .. ' ' .. message
            end
        end
    end

    last_message = out
    if M.config.echo then
        vim.api.nvim_command(
            string.format('redraw | echo "%s"', escape_string(string.sub(out, 1, vim.v.echospace)))
        )
    end
end

local function lsp_progress(err, progress, ctx)
    if err then
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or ''
    local token = progress.token
    local value = progress.value

    if value.kind == 'begin' then
        series[token] = {
            client = client_name,
            title = value.title or '',
            message = value.message or '',
            percentage = value.percentage or 0,
        }

        local cur = series[token]
        log({
            client = cur.client,
            title = cur.title,
            message = cur.message .. ' - Starting',
            percentage = cur.percentage,
        })
    elseif value.kind == 'report' then
        local cur = series[token]
        log({
            client = client_name or (cur and cur.client),
            title = value.title or (cur and cur.title),
            message = value.message or (cur and cur.message),
            percentage = value.percentage or (cur and cur.percentage),
        })
    elseif value.kind == 'end' then
        local cur = series[token]
        local msg = value.message or (cur and cur.message)
        msg = msg and msg .. ' - Done' or 'Done'
        log({
            client = client_name or (cur and cur.client),
            title = value.title or (cur and cur.title),
            message = msg,
        })
        series[token] = nil
        clear()
    end
end

M.config = {
    echo = true, -- Echo progress messages, if set to false you can use .message() to get the current message
    decay = 3000, -- Message decay time in milliseconds
}

function M.message()
    return last_message
end

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
    local old_handler = vim.lsp.handlers['$/progress']
    vim.lsp.handlers['$/progress'] = function(...)
        if old_handler then
            old_handler(...)
        end
        lsp_progress(...)
    end
end

return M
