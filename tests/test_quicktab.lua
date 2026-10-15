-- Regression tests for KOReader Jellyfin QuickTab
-- Run from repository root:
-- lua tests/test_quicktab.lua

local sort_calls = 0
local browse_calls = 0

local MenuSorter = {}

function MenuSorter:sort(items, order)
    sort_calls = sort_calls + 1
    return items
end

package.loaded["ui/menusorter"] = MenuSorter
package.loaded["gettext"] = function(text)
    return text
end

dofile("2-jellyfin-tab.lua")

local function makeMenu(with_jellyfin, reordered)
    local browse = {
        text = "Browse Books",
        callback = function()
            browse_calls = browse_calls + 1
        end,
        enabled_func = function()
            return true
        end,
    }

    local menu = {
        filemanager_settings = {
            icon = "appbar.filebrowser",
        },
    }

    if with_jellyfin then
        menu.jellyfin = {
            sub_item_table = reordered
                and {
                    browse,
                    { text = "Configure Server" },
                    { text = "Login" },
                }
                or {
                    { text = "Configure Server" },
                    { text = "Login" },
                    browse,
                },
        }
    end

    local order = {
        ["KOMenu:menu_buttons"] = {
            "filemanager_settings",
            "setting",
            "tools",
            "search",
            "main",
        },
    }

    return menu, order
end

local function countTab(buttons)
    local count = 0

    for _, name in ipairs(buttons) do
        if name == "jellyfin_tab" then
            count = count + 1
        end
    end

    return count
end

-- Test 1: normal Jellyfin menu
do
    local menu, order = makeMenu(true, false)
    MenuSorter:sort(menu, order)

    assert(menu.jellyfin_tab, "Jellyfin tab missing")
    assert(menu.jellyfin_quickbrowse, "Browse action missing")

    menu.jellyfin_quickbrowse.callback()

    assert(browse_calls == 1, "Browse callback was not called")
    print("PASS: Normal Jellyfin menu")
end

-- Test 2: Browse Books moved to another position
do
    local menu, order = makeMenu(true, true)
    MenuSorter:sort(menu, order)

    assert(menu.jellyfin_quickbrowse,
        "Reordered Browse Books was not found")

    menu.jellyfin_quickbrowse.callback()

    assert(browse_calls == 2,
        "Reordered browse callback was not called")

    print("PASS: Reordered Jellyfin menu")
end

-- Test 3: Jellyfin is not installed
do
    local menu, order = makeMenu(false, false)
    MenuSorter:sort(menu, order)

    assert(not menu.jellyfin_tab,
        "Tab should not exist without Jellyfin")

    print("PASS: Missing Jellyfin plugin")
end

-- Test 4: Menu is rebuilt multiple times
do
    local menu, order = makeMenu(true, false)

    MenuSorter:sort(menu, order)
    MenuSorter:sort(menu, order)
    MenuSorter:sort(menu, order)

    assert(countTab(order["KOMenu:menu_buttons"]) == 1,
        "Duplicate Jellyfin tabs created")

    print("PASS: Repeated menu builds")
end

-- Test 5: QuickTab uses its own icon
do
    local menu, order = makeMenu(true, false)
    MenuSorter:sort(menu, order)

    assert(menu.jellyfin_tab,
        "QuickTab is missing")

    assert(menu.jellyfin_tab.icon == "quicktab-fin",
        "QuickTab must use the custom fin icon")

    print("PASS: Custom QuickTab icon")
end

-- Test 6: Original Jellyfin menu remains unchanged
do
    local menu, order = makeMenu(true, false)

    local original_jellyfin = menu.jellyfin
    local original_subitems = menu.jellyfin.sub_item_table
    local original_buttons = {}

    for i, id in ipairs(order["KOMenu:menu_buttons"]) do
        original_buttons[i] = id
    end

    MenuSorter:sort(menu, order)

    assert(menu.jellyfin == original_jellyfin,
        "Original Jellyfin menu was replaced")

    assert(menu.jellyfin.sub_item_table == original_subitems,
        "Original Jellyfin submenu was replaced")

    -- Exclude our newly inserted tab from the comparison.
    local remaining_buttons = {}

    for _, id in ipairs(order["KOMenu:menu_buttons"]) do
        if id ~= "jellyfin_tab" then
            table.insert(remaining_buttons, id)
        end
    end

    assert(#remaining_buttons == #original_buttons,
        "Original menu tab count changed")

    for i, id in ipairs(original_buttons) do
        assert(remaining_buttons[i] == id,
            "Original menu tab order was changed")
    end

    print("PASS: Original Jellyfin menu preserved")
end

print("All QuickTab tests passed.")
