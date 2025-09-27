function conky_temp_color()
    local file = "/sys/class/hwmon/hwmon6/temp1_input"
    local f = io.open(file, "r")
    if not f then return "${color green}" end

    local raw = f:read("*all")
    f:close()

    local t = tonumber(raw) / 1000 -- convert from millidegrees to °C
    if not t then return "${color green}" end

    if t <= 40 then return "${color green}" end
    if t >= 80 then return "${color red}" end

    local ratio = (t - 40) / 40
    local red = math.floor(255 * ratio)
    local green = math.floor(255 * (1 - ratio))

    return string.format("${color #%02x%02x00}", red, green)
end

