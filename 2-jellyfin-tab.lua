-- Jellyfin top tab for KOReader 2026.07.1
-- File manager only.

local MenuSorter = require("ui/menusorter")
local originalSort = MenuSorter.sort

function MenuSorter:sort(items, order)
    if items
        and items.filemanager_settings
        and items.jellyfin
        and order
        and order["KOMenu:menu_buttons"] then

        local jellyfin = items.jellyfin
        local gettext = require("gettext")
        local browse

        for _, item in ipairs(jellyfin.sub_item_table or {}) do
            if item.text == gettext("Browse Books") and item.callback then
                browse = item
                break
            end
        end

        if browse and browse.callback then
            items.jellyfin_tab = {
                icon = "quicktab-fin",
            }

            items.jellyfin_quickbrowse = {
                text = "Browse Jellyfin Books",
                enabled_func = browse.enabled_func,
                callback = browse.callback,
            }

            order.jellyfin_tab = {
                "jellyfin_quickbrowse",
            }

            local buttons = order["KOMenu:menu_buttons"]
            local found = false

            for _, id in ipairs(buttons) do
                if id == "jellyfin_tab" then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(buttons, 4, "jellyfin_tab")
            end
        end
    end

    return originalSort(self, items, order)
end
