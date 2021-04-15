local home = os.getenv('HOME')
local prompt = home == '/root' and '# ' or '» '
local colors = {
    default = '0';
    red = '31';
    green = '32';
    yellow = '33';
    magenta = '35';
    cyan = '36';
}

local function battery ()
    local capacity = io.open('/sys/class/power_supply/BAT0/capacity')
    local status = io.open('/sys/class/power_supply/BAT0/status')
    local message = capacity:read('*line') .. '% '
    local color = status:read('*line') == 'Charging' and 'green' or 'red'
    capacity:close()
    status:close()
    return message, color
end

local function dir ()
    local cmd = io.popen('pwd')
    local output = cmd:read('*line')
    cmd:close()

    if home and output:find(home) == 1 then
        return output:gsub(home, '~')
    else
        return output
    end
end

local function git () 
    local cmd = io.popen('git rev-parse --abbrev-ref HEAD 2> /dev/null')
    local branch = cmd:read('*line')
    cmd:close()
    return branch and branch .. ' ' or ""
end

local function write (output, color)
    io.write('\001\027[', color and colors[color] or colors.default, 'm\002')
    io.write(output)
end

write('\n')
write(os.date('%H:%M:%S '), 'cyan')
write(battery())
write(dir() .. '\n', 'magenta')
write(git(), 'yellow')
write(prompt)
