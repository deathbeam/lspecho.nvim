local M = {}

local series = {}

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

    vim.api.nvim_command(string.format('echo "%s"', string.sub(out, 1, vim.v.echospace)))
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
        log({
            client = client_name or (cur and cur.client),
            title = value.title or (cur and cur.title),
            message = (value.message or (cur and cur.message)) .. ' - Done',
        })
        series[token] = nil
    end
end

function M.setup()
    local old_handler = vim.lsp.handlers["$/progress"]
    vim.lsp.handlers['$/progress'] = function(...)
        if old_handler then
            old_handler(...)
        end
        lsp_progress(...)
    end
end

return M
