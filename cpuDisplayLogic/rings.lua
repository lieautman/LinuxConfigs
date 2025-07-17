settings_table = {
    {
        name='cpu', arg='cpu0', max=100, x=60, y=120,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0x00ffff, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu1', max=100, x=160, y=120,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0x00ff99, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu2', max=100, x=260, y=120,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xffcc00, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu3', max=100, x=360, y=120,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xff3300, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu4', max=100, x=60, y=250,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0x9933ff, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu5', max=100, x=160, y=250,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xff6699, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu6', max=100, x=260, y=250,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0x66ff33, fg_alpha=0.8
    },
    {
        name='cpu', arg='cpu7', max=100, x=360, y=250,
        radius=40, thickness=6, start_angle=0, end_angle=360,
        bg_colour=0xffffff, bg_alpha=0.1, fg_colour=0xff6600, fg_alpha=0.8
    }
}

require 'cairo'
unpack = unpack or table.unpack
local font_name = "DejaVu Sans Mono"
local font_size_label = 14
local font_size_load = 12

function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255.0,
           ((colour / 0x100) % 0x100) / 255.0,
           (colour % 0x100) / 255.0,
           alpha
end

function draw_ring(cr, t, pt)
    local xc, yc, ring_r, ring_w = pt.x, pt.y, pt.radius, pt.thickness
    local sa = pt.start_angle * (2 * math.pi / 360) - math.pi / 2
    local ea = pt.end_angle * (2 * math.pi / 360) - math.pi / 2

    local bgc, bga = pt.bg_colour, pt.bg_alpha
    local fgc, fga = pt.fg_colour, pt.fg_alpha

    -- Background ring
    cairo_arc(cr, xc, yc, ring_r, sa, ea)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)

    -- Foreground arc
    local angle = (ea - sa) * t
    cairo_arc(cr, xc, yc, ring_r, sa, sa + angle)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
    cairo_stroke(cr)
end

function draw_ticks(cr, pt, tick_count, tick_length, tick_thickness)
    local xc, yc, radius = pt.x, pt.y, pt.radius
    local sa = pt.start_angle * (2 * math.pi / 360) - math.pi / 2
    local ea = pt.end_angle * (2 * math.pi / 360) - math.pi / 2
    local angle_step = (ea - sa) / (tick_count - 1)

    cairo_set_source_rgba(cr, 1, 1, 1, 0.4)
    cairo_set_line_width(cr, tick_thickness)

    for i = 0, tick_count - 1 do
        local angle = sa + i * angle_step
        local x_outer = xc + (radius + tick_length / 2) * math.cos(angle)
        local y_outer = yc + (radius + tick_length / 2) * math.sin(angle)
        local x_inner = xc + (radius - tick_length / 2) * math.cos(angle)
        local y_inner = yc + (radius - tick_length / 2) * math.sin(angle)

        cairo_move_to(cr, x_inner, y_inner)
        cairo_line_to(cr, x_outer, y_outer)
        cairo_stroke(cr)
    end
end

function draw_labels(cr, pt)
    local labels = {
        {0.25, "25%"},
        {0.5,  "50%"},
        {0.75, "75%"},
        {1.0,  "100%"}
    }
    local radius = pt.radius - 12  -- inside the ring
    local sa = pt.start_angle * (2 * math.pi / 360) - math.pi / 2
    local ea = pt.end_angle * (2 * math.pi / 360) - math.pi / 2

    for _, label in ipairs(labels) do
        local t = label[1]
        local text = label[2]
        local angle = sa + (ea - sa) * t
        local x = pt.x + radius * math.cos(angle)
        local y = pt.y + radius * math.sin(angle)
        draw_text_centered(cr, text, x, y, 10, font_name, {1, 1, 1, 0.6})
    end
end


function draw_needle(cr, t, pt)
    local xc, yc, radius = pt.x, pt.y, pt.radius
    local sa = pt.start_angle * (2 * math.pi / 360) - math.pi / 2
    local ea = pt.end_angle * (2 * math.pi / 360) - math.pi / 2
    local angle = sa + (ea - sa) * t

    local needle_length = radius - 6
    local tip_x = xc + needle_length * math.cos(angle)
    local tip_y = yc + needle_length * math.sin(angle)

    local base_width = 4
    local base_angle_offset = math.pi / 60
    local left_x = xc + 8 * math.cos(angle - base_angle_offset)
    local left_y = yc + 8 * math.sin(angle - base_angle_offset)
    local right_x = xc + 8 * math.cos(angle + base_angle_offset)
    local right_y = yc + 8 * math.sin(angle + base_angle_offset)

    cairo_move_to(cr, left_x, left_y)
    cairo_line_to(cr, tip_x, tip_y)
    cairo_line_to(cr, right_x, right_y)
    cairo_close_path(cr)

    cairo_set_source_rgba(cr, 1.0, 0.2, 0.2, 0.8)  -- red translucent needle
    cairo_fill(cr)
end

function draw_text_centered(cr, text, x, y, font_size, font_face, color)
    cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, font_size)

    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)

    local text_x = x - (extents.width / 2 + extents.x_bearing)
    local text_y = y - (extents.height / 2 + extents.y_bearing)

    cairo_move_to(cr, text_x, text_y)
    cairo_set_source_rgba(cr, unpack(color))
    cairo_show_text(cr, text)
end

function conky_ring_stats()
    if conky_window == nil then return end

    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    local cr = cairo_create(cs)

    for i in ipairs(settings_table) do
        local pt = settings_table[i]
        local value = tonumber(conky_parse(string.format('${%s %s}', pt.name, pt.arg))) or 0
        local t = value / pt.max

        draw_ticks(cr, pt, 11, 8, 1.2)
        draw_ring(cr, t, pt)
        draw_labels(cr, pt)
        draw_needle(cr, t, pt)

        local text_color = {0.4, 0.8, 1.0, 1.0}
        draw_text_centered(cr, "Core " .. pt.arg:sub(4), pt.x, pt.y - pt.radius - 20, font_size_label, font_name, text_color)
        draw_text_centered(cr, string.format("%.0f%%", value), pt.x, pt.y + pt.radius + 10, font_size_load, font_name, text_color)
    end
end

