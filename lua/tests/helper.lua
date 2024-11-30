local os = require("os")

local Helper = {}

Helper.templateValid = [[//
//  Test.swift
//  guil.nvim
//
//  Created by ha100 on 30/11/2024.
//  Copyright © 2024 ha100. All rights reserved.
//
]]

Helper.templateNew = [[//
//  Test.swift
//  guil.nvim
//
//  Created by ha100 on 28/01/1985.
//  Copyright © 2000 ha100. All rights reserved.
//


]]

Helper.template = [[//
//  Test.swift
//  guil.nvim
//
//  Created by ha100 on 28/01/1985.
//  Copyright © 2000 ha100. All rights reserved.
//

struct Sample {

    let soYouKnow: Bool
}
]]

function Helper.update_dates(content)
    local now = os.time()
    local formatted_date =
        string.format("%02d/%02d/%04d", os.date("*t", now).day, os.date("*t", now).month, os.date("*t", now).year)
    local current_year = os.date("%Y", now)

    content = string.gsub(content, "(Created by .- on )%d%d/%d%d/%d%d%d%d", "%1" .. formatted_date)
    content = string.gsub(content, "(Copyright © )%d%d%d%d(.*)", "%1" .. current_year .. "%2")

    return content
end

function Helper.read_file(path)
    local file = io.open(path, "r")
    assert(file, "Failed to open file: " .. path)
    local content = file:read("*a")
    file:close()
    return content
end

return Helper
