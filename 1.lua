local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
-- ============================================================
-- ESP V3 SYSTEM (ported COMPLETELY from ZN KNOX)
-- Config: _G.JINSHIFORYOUConfig.EspV3_* | Menu: ESP V3 section
-- On/Off: menu switches | Bridge: _G.ESPV3Bridge
-- ============================================================
local function Valid(obj)
    if not obj then return false end
    if slua and slua.isValid then
        local ok, v = pcall(slua.isValid, obj)
        if not ok or not v then return false end
    end
    return true
end
-- [ICON-FIX] Multi-package save-path detector (all PUBG variants)
local function _ZN_GetSavePaksDir()
    if _G._ZN_SaveDir then return _G._ZN_SaveDir end
    local packages = {
        "com.tencent.ig",
        "com.rekoo.pubgm",
        "com.pubg.krmobile",
        "com.vng.pubgmobile",
        "com.pubg.imobile",
        "com.tencent.tmgp.pubgmhd",
    }
    local suffixes = {
        "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/files/",
    }
    for _, pkg in ipairs(packages) do
        for _, sfx in ipairs(suffixes) do
            local dir = "/storage/emulated/0/Android/data/" .. pkg .. sfx
            local test = io.open(dir .. ".wtest", "w")
            if test then
                test:close()
                os.remove(dir .. ".wtest")
                _G._ZN_SaveDir = dir
                if _G.ZN_Dbg then _G.ZN_Dbg("ICON save-dir=" .. dir) end
                return dir
            end
        end
    end
    _G._ZN_SaveDir = "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/"
    if _G.ZN_Dbg then _G.ZN_Dbg("ICON save-dir=FALLBACK") end
    return _G._ZN_SaveDir
end
_ZN_GetSavePaksDir()

    -- ============================================================
    -- ESP V3: snaplines + name + player/bot counter (icons: victortipvala-sys/esp-icons)
    -- ============================================================
    _G.JINSHIFORYOUConfig = _G.JINSHIFORYOUConfig or {}
    if _G.JINSHIFORYOUConfig.EspV3_Master == nil then _G.JINSHIFORYOUConfig.EspV3_Master = true end
    for _, _ek in ipairs({"EspV3_Count","EspV3_Box","EspV3_Line","EspV3_Health","EspV3_Name","EspV3_Dist","EspV3_Weapon","EspV3_Flag","EspV3_State"}) do
        if _G.JINSHIFORYOUConfig[_ek] == nil then _G.JINSHIFORYOUConfig[_ek] = true end
    end
    pcall(function() local _f0 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "w") if _f0 then _f0:write("boot" .. string.char(10)) _f0:close() end end)
    _G.ZN_Dbg = function(m) pcall(function() local f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a") if f then f:write(tostring(m) .. string.char(10)) f:close() end end) end
    -- [ICON-FIX] Embedded base64 icons — CORRECT decoder + correct write path
    pcall(function()
        local dir = _G._ZN_SaveDir or _ZN_GetSavePaksDir()
        if _G.ZN_Dbg then _G.ZN_Dbg("ICON base64 write-dir=" .. dir) end
        local function _need(p)
            local f = io.open(p, "r")
            if f then f:close() return false end
            return true
        end
        -- [ICON-FIX] Correct base64 decoder (4 chars -> 3 bytes)
        local function _b64d(data)
            local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            data = string.gsub(data, '[^' .. b .. '=]', '')
            return (data:gsub('.', function(x)
                if x == '=' then return '' end
                local r, f = '', (b:find(x, 1, true) or 0) - 1
                for i = 6, 1, -1 do
                    r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
                end
                return r
            end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
                if #x ~= 8 then return '' end
                local cc = 0
                for i = 1, 8 do
                    cc = cc + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
                end
                return string.char(cc)
            end))
        end
        -- [ICON-FIX] Embedded base64 strings — unchanged
        local _icons = { {"ic_danger_enemy.png", [[iVBORw0KGgoAAAANSUhEUgAAAIAAAABACAYAAADS1n9/AAAMG0lEQVR42u2deXAUVR7HP6+nZ5LJ5L5mMgkTCEfCEYKcBjbhUlAUOcRVwFJ0LXZ1BTGiCAkW4MUNWmgJurIetZRaJbVatRSCIOFaWQiKIKcJRwhJCBASkkCO6f0jN2RyzPRMQjK/qqk+5r3+dffv+37v9/u+7n4CJ8l6MxYBKUIwQwi0Aqj7k0T9bXHbtmRjf/U+iSbq19mm+nj2HquRuvXO1UY5qZG6al2rnXJeVtvwi0AymUlBsADwoA2IwC22RFUAfGghQKngSwXGCVcaVLgN3uoAWB1BoFLOXiGIcbfYu8e7SWqcxPvd8NBZ2QzNM75wW1g1b0dbAIAo5gMg0d2CW95CW/teOQyA98wMBZ51G/juFIcAoIAQgrXtudG3d2/mEADWmXgAhUFuA3dUDyB4wm3QDpoGbuyMZ0EpE4WLDVidQUgennh36YHW24fijFOUXb3stqYrAVBYQj80+LqyhUo6DyyPPkXExOkEDU6sl0/ezM4k+7tNZH31CSUZp9pH/CGc7+3s7gIUie6O5K3elig6T5jabH2m+8YzavvvxL27gaAhw++4O56mCDrPfJX4rUfpvmAlGi+DO/5wKgAE3RxR3O3xZ4lf+SkaT32TZaNnpXDvJ99hsEQ1fVNlLZbnXqH/v35CF2x0xyNqAmA9aFebeHVNGL+gsMARxVm7tqLx8CR0SGKj5XrOWUSvV95s8fF9Ygdyz6ZdyD5+zotHOlIWsCKMJwvNHEewHIjDwXGEy2n7KSu8TljiGIQso/P1v6OMcfhYYmYvtFuHV1Q00Uv/4c4YGhFNUwUW9UY3TuIbIVggILCxcekG99kog9VKcL/BdBo7kZ7PJaH19SM79YfaMW5ZJuGzLegCgmx3Q1YrRWeOowsKsVnG0K0Xhb8e4Oa5M80737a0rwX17JTrTXoAr6tsRDDJGei7lPoDOv9ALh/cy8Vt39X7zzJxOobIro3Wz/3xe46/ldSknshZC91N3Z4uYIWRLorCVGcpz9q1FYCL278n9+fUei6503jbHJO1rJQDMx7k0F8nkZe6lR0DQ8lP22+zvO898XiGR7YrwwlXAKBcENkSXS3NWwNjB1BeUowpccwd+X5II8GhpNXRa+EaUBQAwiZMw79/fKO6/f90f9s2YCs91NJ4IKdwvu6ZqH1SQ1dtRNZ7YRo2GiFJYLVWdjthEWj0Xo1Xtlrx7hqDX+yA5gWEXXq4U8CWAmB+DunLTBwEBjpDeUHGKQL79McjMJiAPv3JP3IQoNHAr4b4CYsgYetvCI1M2fVrTV+of1CHNLDDaaACK5ylPHvvjpr1sKpuQBcQRFzyyqYN6u2L0FTiV+sX0GT54DGTCBr9SIczsMMAmJfNN8AhpwBgXy0ATAmVAOiTtJjgwQnquzq/AKJXfYFU1bW4OYDmxACVN0pZamW2RsMete9b7oHdWMvLkGQtwQPikQ3eeEfWZ5hv5eWQ89OWO4wmbCxr1gX4D0pAb6lNJTXevuiCQrmVedZt+eYSQQDbi7gwxoduAvqqRVwIQCkrxTx8LAazBaHRcOXQfkqvXiZs5IMAFP5xgt3TRqPReaJUlFNekE9ZQf6dy8LaX0XVsjQnizNvvYxX5+54RUUDUHTyNzI3LEMoyl1N+kgqEkHNpnOtEvMlK5MBLzWDpku7txEycFhlN5A4hsOLXgKrlcC4QRxdPp+4hauJGG/fcyemCdM59vcpFKTtQx/RmfPr3qzJNDpCjq+6rlUmFgrBEjVfn9L5+DF+x+/ojWYK00+yZWQMAvDwCyD+482EDBnu0AWWF+RzfM40ru3aou7rWNj/upgzXhWzU863aDRQyHxQmRioJ9EzXkRvNAPgExWNl9lS2Td5GRw2PoDs64/foASXtpq7KcBsEQCSMrkKFKmlvNPYifR9ZUl9t12VDpZcyqQw/aQqevL3/agqS9eh0kBniX9MLMPWflHJANYRYx1aOP3LjxzWU5xximv7d3TIHN9ZALihhmK/qGhkg/cd+43VtDCQsWkDRefTHdKTsWJ+zZiBW9QBwCVVOICDe2vWlYqKmnWdfyABfSuZ54qSYg7NnYG19JZ9RNPmz7m89Vu3lVUGwG41gqaS3EvcqGrdR5YnU5he+ySvMaG2G8g7sJv/zZraYhDkbf83J+b9pd0ZTO3uq0kiaHk4/UYZ8HzYG//JvpQKiX1WeFCAsblpi619QX0HUph+irRFc/Dv2ZfAqpE9SdZy9puNNeWK/jhBzs7/EDxkOLrA4Mb5itJbpK9+g9NLZoO1wnkkjZ3Hc/RrI2o/EdQ0FWyliywx1Grlxg0rICEkO8mg2yX9639y5ZefK939zZKa/b49eiMkCd/uPTHfP4EzHy3j+tE0do7pQ8QjU+k05WkCByciaXW1wd65M+Ru3cyFjWspzclCCAgYlIB3TF+yvvig9VqoaEceZXUE+qRMStaYmCskVqhJqgxY/B49nplNcdZ59jzzMMaho+iVtBjZy5u8/TtJmzuDW9kXa+pqtDr05k5oDT6UZmdSdi2v9ngaDRFPvkD35FVYy8ooOLiHk68+TVletn3f9GmIpLGjrjO/N2QvEWSz6rJwIpQKXhJgkQRdhKCHUPATgutCQQiBr9oAMI8cx87HR9BrVgpRTzzH4ZTnkQ0+xCavRCkrJeOzdZzbtIHis6cbvCmyl4HQ+ybQZdZCDF1jyD+Qytm1b9AteTWyXyBHZ4zh1m117Wbp2gkAbHYBJRfJ8jQiI5gMyDX8n4KfM1zRzSu5pM4YR7+UVZhGPICQZSQPTyStFiFJCA9Pus6cS9eZcynKOMW1w/+lNC+HiuIi9OZO6M0WAgYnIulqv0ul8TJQXliANtiIbPAh7qs9HH1yFCWnj7nD/+Z2AcvNDMNKVyEIlxTihCBegEVtXl2SNcS9vhRj/EgOLfgbsa+9gzFBnef4ygvyOfHydHz7DcE46SmOPDqE8iu5bg/Q1FjAUhPPK1b2CMGnQiEeWJ90iUgF5qiNwMhHphIzcy5e4ZFoDT54BKj3CJfs64+H2YLsH4hHRGdiPvwWJKn9tVa1j7nMxBRggSToKqjp89MEpArBnOZ4gOa0KH2IiYd2/I6uGY92qSVn304ie+OaNuUBHBmBdIoHUCSyBWwDDlM7CNSfOh5ADVQOWLTWpcYHsCS9iUfVyKNqrUm4vgU77B1v3/E1aP4w8gyCZKx0dvYJ+PXoTaeHHnM9Bao3YJ75GmcXv9iqLrhNUcErjBjOmNiuCD4G5xsfoNcL8+4YEXSVhEx5Fm1QaLs2cIsAUArvKjDCVcq13j5EPvzn1rt4Tz1B46d16DSwHgAUSHCl8vBRD9XL21tDAsdOdgOgDgL2uRoArS3e9wxFdnEA2mYBUF7OfASnXZW3Bsb2b/3cWqPBKyauzef4zopP5CVGXlcgVCPIRiFV0TBSlPMZMNqZUbHGwxNfF7+waUv00X0p/Pmnu47EUQUACrwj4JyiECLAIMopQuE0gnKh8nwCdcUz2IiQ5TZxE3SmcIcterdmEJKAH4FIoPq7agYE/XCi8aszgLYiGoNPh/ggVMMeQLBfUggGegE6VykuvX6NI2sW2XzHry7F2WiZqhWb/1VvC9vHKTnxa4cNAsXbwYRVaDhRw/W3kbdnmuLlm1sXXDRxE607sZSdcl5KzuMSCrPaHDJxi8vSwDdy+VzAOreB26ibdgUPkJLDLOAloLwt561uAzuRCErJ4X2sjAMK3AZs+ySO6gAASM5lm2IlAYWLbtO2f2/W4Dhsci5HhMy9QJrbwB0gCGxI5l0ks8STYSisAcruKoO6ZxJVF/xLA/CT9cRKChYEFqFgkQQWQc3Pz5V5tZoTR7eJyZ9x/HUxe3kAVRrH+ij8SkuxaBQsKIRqKh8bDxUQXLW0CAiuJpucMHP4GaHwZbU7k6R6rq2bBI8Kgb7qYt+WFMqkKmRUHWuEgOGichq8lgAgX0CmBJkILmiojJuk29yrdPs+qZH/6i6lRv6rU8YBue5S7/h1b3RFRZhlBTMKBgFmAR4ShCngKYFJgJekECoEBiEIqbrh4YKqKegbBsChBzJsf8304AC0hVcIx0DeyGMNf98grQuRVpmnhMJjVdPdZwN5Am5oBGcluKFAnqSQJUNmmY4LvY+p862E1pT/A0yWGDod/ujuAAAAAElFTkSuQmCC]]}, {"ic_clear_boot.png", [[iVBORw0KGgoAAAANSUhEUgAAAIAAAABACAYAAADS1n9/AAALGElEQVR42u1de1BU1xn/ffcuC8siDxUhCL4QHEBsFCTG56Sx8ZFo6oPYcdIYY4Muamw7Y5qaToNtiUmnCZpEXOgjyRQSIzbRMRhfkzhqUVsDQQWrJAryUFDkjbDLvad/wPJY9gn7hPsxw91793z3nnO/3/3O9/3OuWcJA5AlW5d4NimbHhcIsziOjQAwhmPcRYGEk3mpeWWQxG2E4jbPvAUAHEedB7q2IICIera67zr3g0BQ9CnT+Q8cR5UM0PbRJQBcZ5nufZ0OB3SdHuC4zo2+ru4z13Md/bqBAOJ1zeI660IGyurO0as9QO8yner65+hzHt29ItLTNXyOfnVBv/aIINwm4qoBlIGj480+DedyYnI0dgdA/OaZrJ+RDQHAwNYQAPrcHANlDQPAtI7RrX59OWMGIZOAtkTH1LUHpKsHaAN6LSA6IMr4XR9NzyixFwC4IeXP2JBqjZKA9bwgFP/i0ssfb8jbMFICgK3xwtwCMTIQXiBP/rsNBZvmSABwJQ/D9HeZyf1BXjyMg3g6qSBprQSAIQogS7wBI3yUVJD0tN0A4Ei36C33RtKCl5GxTo03V6dixvgZEkjMd1kejJCz8erGH7mGBxggqgmEnStTsOaxNQgfE46EiQl4a/UuxEkgsEQUTKS/prAUzvkAMIsPw/3i5KBwzJjQ19hEhFXxqyTzWuYOZlZdrdritjGAr8LP4HE/I8eNBl6MDWMQ0Gsp36TI3BIAN+7eQEt7S7/jBWUFEldguTxyZ/Sd5W4JgKa2Jrz15dto07b1GP92AT65+IlzI3MzXZjrAYjWD45kcKLkleQh8YPnkJqYisP5h3Dmxtm+/P5QSf3s25w5bukBdNKqaUVjawPuNNwdllyADciigKQrSeGD8wB2QKm/0h+ho0Ihk8n6j+ABPf8I8PX2Q0RQBLzl3j2jaboyeoNNjQ8bUdlYCYEJwwcwZNqjEHF/3FicfIxn+Dw9Jr3Zqg4kfvNMBthgFLBrP3Z8LJIXqTA1bKrd7slD7UPkXs1F1qVsaASNZaN/Q2XE02RZqgaJO8VW8W+Z8Zlah3cB86Pn4731e+xqfABQeCiwevpqvL38LchlcokT6HEPQWCUzin4IlWxaqFDARCgDMCOlb+FjHdcXDklaArWJayT7N5fIhhDrqpItdxhAFgatxRKT6XDW7okejHkvHVeYJiQR3Iw7AYzHd3ZDABRoVFOaaWXzAvjRo5zLFfgJvhhhIkbijcEOAQASk9vpzVUKVc690abmwfAnFUv1IdFh9W7NA8giQVcwQC7LGL4NIVSRPM8QNdFrGLgLOQORCbixOWTuFxeCIVcgccmP4aESQlm9epb63Hk8hFU1lchcEQgFkU/hdCAUAkclksbePZny4ggO0mH2IHt2a+ioLSgO1f9/NIXSExIRPJClVG98gfl2H5wOx601nXnuYcLD+O1xb/B7EmzJdNa9oS+o45Sl9o1C/CQeSBDpYZqkWFj5pzPQf6tfMyJnI3s5CxkbshARHAEDv7noMlRv7RTu/GgpQ4vzl6HrJf+iZ3LUiCXeWD313sMjiAG+gQiffVeLIlaLNm9U24qfBWpducBQgJCEBMWg7lRhscjLpRcAEccdvx0B8aOHIuI4Aj8evGvAAAXf7hoUKe5vRlXKq4gOiQaaxPWInBEIGZNnIVV01ehsa0R16uv99MJHz0J40eOR1xYvGT6zp55S1pY2kOHEkGGRCNowXM8PHiPnuS0i7nTCh1GKt/5p5/be/A6Pe3AKjN85o38a1/Mvq8sLWxXAMyYMB1aQYs9x95Dm7YN9S31+ODUXgDA9PGPGkknlYgIikBheSGOFx0HYwwlNSX4ouALeMo8MSV4ilNSO/cBEEu1prRdg8Dn5z2Ps9fPIbcgF7nf5XYHdPOnzMfcyLl93L5SruzOQrYtfAXbc17FOyffxbun0jrfrQOHzT/eDH+Fv/ukciZG8RhY9zuKNpRCdYy6wGUAoJArkPlyBvbn7Udh+WUo5ArMmjwLy6Y/05MpCB1I/ngzno17FqviVgIAIoMikfFzNT67dABlD8owymcUlsU+g2mh04YXF2A9PpqtVbAKAP24AgvcopeHF15c8KLR7w/lH0ZVfRWy8rKwKOYp+Hj5AACC/YKx7clXpIjOOhGtVXAqE9jU1oSsvKzuz9kXsiUTDk7s6wFsLe3adqyIW9E9A2iM7xjJhIPrN864FQBGjxiNdXNfsN/tsJbeduvkny5puPa9vbpn2vr91tHvR7x/z2UB4PDnw07jHa4RM7IHckG+XlWkGsXAxqEYEEThUwAn7AaA6vpq3Km7i8LSywgZ+YjTGl9aW4bm9mYU3S1y9E23Ryo30PjvL+qYjJNJPyT5ZYZnNljsOHSTQi2aIIle6wTpTQbd/VIa4sNNU7G7Du/CiaKThtf5MTBB0lfhizdXpCIyKNLkeXd8+ToKqwqN1rfPOkIWTiDtM6HTwvqamiw7IF3OqnrXAvAF4AGgDkAJgHJG+P5B1P3XcyhHcHoWUHj7slXlG9saUVLz/fDK/fW6LCtkVJfxASAAQAKAaQR20ZjxB9YFDKJf5Dneah3ZAHSGqTQCdIQxlg+OKgGMIlGsVkerD7lMEJj8ExXOXj/X82KI3lx5oPdLIYQRXj6YNelxybQWGL+jQxYj89D6E6NkMLYTgA+IsLEoOTED6QftDgBRNE9CzYmcgzmRNl/nCKIoDHcAeMlk2qNgFNv1IN0D8BUj+rdCIz9lStFmMUBNQ43TWl/TfM/ifnWIihyg2F77gQASibFftsvb/7DpqvHVxWwGgLPXzjml5bdqb6G6qdqmXMEQAtAEBmwF0blNRarTm4o3TbUbAM7fOI9vb37rcGLn7xf+4dKRvAvJAsbobNK1LbF2AQBjDL/f/wbybxU4pDUaQYO0b9KQX57vZpkecxqACPAnUdhidRBoKYXa+LAR2z7chgXRCzAvah6C/MZ0X7lfVUjvsH4ZXYagV0YrdOB6zXUcLz6Gey333YaqtacXtIbeJuD+4LMAM1zAmWtncOZ/Z/qvMj4QdgxmFlWWxBq5qYXmHcfzAGYA41qc+lAVOg9OXEuk8FMVqx4XRfLleFblmqOBFqyKIYlVfX8Lg9gKkb6VQRjJgFaO2BUmwmtIvhuon8oN67UEO58fJUBPAtAtOe/NgHhGqJZJz4f1XdYQEA2AawSmlt4OtkUq537rB8gZIKtltbkSAFzF41jDFdggJpCBW5MTk6PhLCYkmGQndwGQGWkAkLg3Zm+RTdPAfqmcFLm7Ik6+Y6KwOjM28wfdMc5FUSp5HFu7fYbPvH29Zvc2vk09gCMCLzLNJkkex7CIRHhjX8y+Pxn6cuimgRIgAOAuA61XR6cfM1ZA4gF0eDH03qP7AagKQCUYVTBi/+UEqNXT0utMKcgYUKprsNmxFYM3hfW6iQZG+fTyD5MnJ3Sva2iiqAxAqA08RDsId/QqqABYUK8DtQxoMlKXMAC8pYAZ5HhHCwPugVDBMdSIhAoiqgTECgJVUAduBz8adNvcimBWm8SVZWHGsnEeQkcIEY0lohDGKIR4FgyiCQR4MaJgIvgTkX+vEUSBQKfBsWy5p/zznOdy+rxA8XT22gA5r1nGEfMmjm7eH33/69NPnDa4lMmaIz97CIKXsZ+CNTHSeYeI2gHUEEetINQS0AQO9wh8HQhVjKGaSKxjYNUtvi1V9vwN4WHRSy79cGmwHHIvDTRtR9cfHfQPEyQeSORJwf8OHMABAjEqB8915VTUwIuo13WuJFIZL+dZKUorjIFJEkmcJv8HntCxqwTldwwAAAAASUVORK5CYII=]]} }
        for _, it in ipairs(_icons) do
            local p = dir .. it[1]
            if _need(p) then
                local ok, bin = pcall(_b64d, it[2])
                if ok and bin and #bin > 100 and bin:sub(1, 4) == "\137PNG" then
                    local w = io.open(p, "wb")
                    if w then w:write(bin) w:close() end
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON wrote " .. p) end
                else
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON b64 fail " .. it[1]) end
                end
            end
        end
    end)
    -- [ICON-FIX] Prefetch: jsDelivr CDN → GitHub raw → old worker (in that order)
    pcall(function()
        if _G._espIconPrefetch then return end
        _G._espIconPrefetch = true
        local MM = ModuleManager
        if not MM then pcall(function() MM = require("GameLua.GameCore.Module.ModuleManager") end) end
        local http = nil
        if MM and MM.GetModule and MM.CommonModuleConfig then
            pcall(function() http = MM:GetModule(MM.CommonModuleConfig.http_manager) end)
        end
        if not (http and http.Post) then return end
        local SAVE = _G._ZN_SaveDir or _ZN_GetSavePaksDir()
        local function prefetchOne(urls, filename, idx)
            idx = idx or 1
            if idx > #urls then
                if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch failed all " .. filename) end
                return
            end
            local sp = SAVE .. filename
            local f0 = io.open(sp, "r")
            if f0 then f0:close() return end
            if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch " .. filename .. " try#" .. idx) end
            http:Post(urls[idx],
                { ["User-Agent"] = "game=ShadowTrackerExtra engine=UE4 platform=Android" },
                "", nil, function(s, resp)
                if s and resp and #resp > 100 then
                    pcall(function()
                        local w = io.open(sp, "wb")
                        if w then w:write(resp) w:close() end
                        if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch OK " .. filename .. " size=" .. #resp) end
                    end)
                else
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch fail# " .. idx .. " " .. filename) end
                    prefetchOne(urls, filename, idx + 1)
                end
            end, 15)
        end
        prefetchOne({
            "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_danger_enemy.png",
            "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_danger_enemy.png",
            "https://late-feather-24ce.victortipvala.workers.dev/icon_player.png",
        }, "ic_danger_enemy.png", 1)
        prefetchOne({
            "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_clear_boot.png",
            "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_clear_boot.png",
            "https://late-feather-24ce.victortipvala.workers.dev/icon_bot.png",
        }, "ic_clear_boot.png", 1)
    end)
local ESPV3Bridge = (function()
    local _ESPV3_DBG = "/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt"
    local function _edbg(m)
        pcall(function()
            local f = io.open(_ESPV3_DBG, "a")
            if f then f:write(tostring(m) .. string.char(10)) f:close() end
        end)
    end
-- R4: requested options are separate from renderer status.
-- One cancellable 20 Hz timer; existing FastTick supervises it and provides a fallback.
local initializeRenderer = (function()
-- ESP V3: cleaned & corrected renderer section
-- Returns initializer; loading module does NOT initialize it.

local recoveredStrings = {
    [1]  = "SlateBlueprintLibrary",
    [2]  = "/Script/UMG.SlateBlueprintLibrary",
    [3]  = "WidgetLayoutLibrary",
    [4]  = "/Script/UMG.WidgetLayoutLibrary",
    [5]  = "Vector2D",
    [6]  = "Vector",
    [7]  = "LinearColor",
    [8]  = "SlateColor",
    [9]  = "/Script/SlateCore.SlateColor",
    [10] = "Player",
    [11] = "Bot",
    [12] = "Head",
    [13] = "head",
    [14] = "root",
    [15] = "Root",
    [16] = "Prone",
    [17] = "Crouch",
    [18] = "Fist",
    [19] = "Open",
    [20] = "Knocked",
    [21] = "Cover",
    [22] = "AsyncTaskDownloadImage",
    [23] = "/Script/UMG.AsyncTaskDownloadImage",
    [24] = "/Script/UMG.CanvasPanel",
    [25] = "/Script/UMG.Border",
    [26] = "/Script/UMG.Image",
    [27] = "/Script/UMG.TextBlock",
    [28] = "GameLua.Mod.BaseMod.Common.UI.InGameUITools",
    [29] = "client.slua_ui_framework.util",
    [30] = "common.asset_util",
    [31] = "GameLua.GameCore.Module.ModuleManager",
    [32] = "client.slua.logic.image_download.image_download_mgr",
    [33] = "ic_danger_enemy.png",
    [34] = "ic_clear_boot.png",
    [35] = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png.T_icon_flag_iland_png",
    [36] = "RegionConfig",
}

local URL_PLAYER     = "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_danger_enemy.png" -- [ICON-FIX] -- [FIXED]
local URL_PLAYER_CDN = "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_danger_enemy.png" -- [ICON-FIX]
local URL_BOT        = "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_clear_boot.png" -- [ICON-FIX] -- [FIXED]
local URL_BOT_CDN    = "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_clear_boot.png" -- [ICON-FIX]

local function decodeRecoveredString(index)
    return recoveredStrings[index]
end

-- ============================================================
-- MAIN INITIALIZER
-- ============================================================
local LoadESPV3System
function LoadESPV3System()
    -- Guard: already loaded?
    -- Instance-owned initialization: failed imports can be retried.

    -- ---------------------------------------------------------
    -- Engine class handles (resolved lazily inside LoadESPV3System)
    -- ---------------------------------------------------------
    local SlateBlueprintLibrary, WidgetLayoutLibrary
    local Vector2D, Vector, LinearColor, SlateColor
    local zeroVector, whiteColor, redColor, greenColor, yellowColor, blueColor
    local redSlateColor, greenSlateColor

    -- ---------------------------------------------------------
    -- Safe object validation
    -- ---------------------------------------------------------
    local function isValidObject(obj)
        if not obj then return false end
        if slua and slua.isValid then
            local ok, valid = pcall(slua.isValid, obj)
            return ok and valid == true
        end
        return true
    end

    -- ---------------------------------------------------------
    -- Import engine classes
    -- ---------------------------------------------------------
    local function importEngineClasses()
        if not import then return end
        local function importFn(name)
            local ok, value = pcall(import, name)
            if ok then return value end
        end

        SlateBlueprintLibrary = importFn("SlateBlueprintLibrary", nil)
            or importFn("/Script/UMG.SlateBlueprintLibrary", nil)

        WidgetLayoutLibrary = importFn("WidgetLayoutLibrary", nil)
            or importFn("/Script/UMG.WidgetLayoutLibrary", nil)

        Vector2D      = importFn("Vector2D", nil)
        Vector        = importFn("Vector", nil)
        LinearColor   = importFn("LinearColor", nil)
        SlateColor    = importFn("SlateColor", nil)
            or importFn("/Script/SlateCore.SlateColor", nil)
    end
    importEngineClasses()
    assert(Vector2D and Vector and LinearColor and CGame and CGame.NewObjectFromPath,
        "ESP V3: engine widget/vector APIs unavailable")
    assert(UEnums and UEnums.ESlateVisibility, "ESP V3: visibility enums unavailable")

    local function readBool(object, member, fallback)
        local value = object[member]
        if type(value) == "function" then value = value(object) end
        if value == nil then return fallback end
        return value == true or value == 1
    end

    -- ---------------------------------------------------------
    -- Build color constants (safe fallbacks)
    -- ---------------------------------------------------------
    if Vector2D then
        zeroVector = Vector2D(0, 0)
    end

    if LinearColor then
        whiteColor  = LinearColor(1.0, 1.0, 1.0, 1.0)
        redColor    = LinearColor(1.0, 0.15, 0.15, 1.0)
        greenColor  = LinearColor(0.0, 1.0, 0.05, 1.0)
        yellowColor = LinearColor(1.0, 0.95, 0.0, 1.0)
        blueColor   = LinearColor(0.18, 0.62, 1.0, 1.0)
    end

    -- Native SLua builds differ in their struct constructor overloads.
    local function toSlateColor(color)
        if not SlateColor then return color end
        local ok, wrapped = pcall(SlateColor, color)
        if ok and wrapped then return wrapped end
        ok, wrapped = pcall(function()
            local result = SlateColor()
            result.SpecifiedColor = color
            return result
        end)
        if ok and wrapped then return wrapped end
        return color
    end

    -- SlateColor wrappers (fall back to LinearColor if unavailable)
    if SlateColor and redColor then
        redSlateColor = toSlateColor(redColor)
    else
        redSlateColor = redColor
    end

    if SlateColor and greenColor then
        greenSlateColor = toSlateColor(greenColor)
    else
        greenSlateColor = greenColor
    end

    -- ---------------------------------------------------------
    -- Icon URL tables (2 entries: primary + CDN fallback)
    -- ---------------------------------------------------------
    local playerIconURLs = { URL_PLAYER, URL_PLAYER_CDN }
    local botIconURLs    = { URL_BOT,    URL_BOT_CDN }

    -- ---------------------------------------------------------
    -- Image cache + counter dimensions
    -- ---------------------------------------------------------
    local imageCache      = {}
    -- Counter presets: Compact(55x32/t14) Standard(65x36/t16) Large(75x42/t18) XL(90x50/t20)
    local counterIconSize = 65  -- Standard width
    local counterTextSize = 36  -- Standard height

    -- ---------------------------------------------------------
    -- File existence check
    -- ---------------------------------------------------------
    local function fileExists(path)
        if not path or path == "" then return false end
        local f = io.open(path, "r")
        if f then
            f:close()
            return true
        end
        return false
    end

    -- ---------------------------------------------------------
    -- Asset search paths (per PUBG package variant)
    -- ---------------------------------------------------------
    local function getAssetSearchPaths(filename)
        local saveDir = _G._ZN_SaveDir or _ZN_GetSavePaksDir() -- [ICON-FIX]
        local paths = {
            saveDir .. filename,  -- [ICON-FIX]
            "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.tencent.tmgp.pubgmhd/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/Documents/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "ShadowTrackerExtra/Saved/Paks/" .. filename,
            "../../ShadowTrackerExtra/Saved/Paks/" .. filename,
            "../../../ShadowTrackerExtra/Saved/Paks/" .. filename,
        }

        -- Add HOME-relative path if available
        pcall(function()
            if os and os.getenv then
                local home = os.getenv("HOME")
                if home and home ~= "" then
                    table.insert(paths, 1,
                        home .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. filename)
                end
            end
        end)

        return paths
    end

    -- ---------------------------------------------------------
    -- loadWidgetImage: try local files -> remote download -> fallback
    -- ---------------------------------------------------------
    -- ════════════════════════════════════
    -- ICON LOADER (FIXED)
    -- ════════════════════════════════════
    local function loadWidgetImage(imageWidget, remoteURLs, filename, cacheKey, counterData)
        if not imageWidget or not isValidObject(imageWidget) then return end
        if not _G._espImgProbeDone then
            _G._espImgProbeDone = true
            _G.ZN_Dbg("imgmod probe run")
            pcall(function()
                local a1, a2, a3 = "0", "0", "0"
                pcall(function()
                    local A = import("AsyncTaskDownloadImage", nil) or import("/Script/UMG.AsyncTaskDownloadImage", nil)
                    if A and A.DownloadImage then a1 = "1" end
                end)
                pcall(function()
                    local m = package.loaded["client.slua.logic.image_download.image_download_mgr"]
                    if not m then local okk, mm = pcall(require, "client.slua.logic.image_download.image_download_mgr") if okk then m = mm end end
                    if m and m.DownloadImageByHttpWrapper then a2 = "1" end
                    if a2 == "0" then
                        local MM = _G.ModuleManager or package.loaded["GameLua.GameCore.Module.ModuleManager"]
                        if MM and MM.GetModule and MM.CommonModuleConfig and MM.CommonModuleConfig.image_download_mgr then a2 = "1" end
                    end
                end)
                pcall(function()
                    local u = package.loaded["client.slua_ui_framework.util"]
                    if not u then local okk, uu = pcall(require, "client.slua_ui_framework.util") if okk then u = uu end end
                    if u and u.SetTexture then a3 = "1" end
                end)
                _G.ZN_Dbg("imgmod async=" .. a1 .. " mgr=" .. a2 .. " util=" .. a3)
            end)
        end
        local function iconEnabled()
            local cfg = _G.JINSHIFORYOUConfig or {}
            return cfg.EspV3_Master and cfg.EspV3_Count
                and not (counterData and counterData.Disposed)
        end
        if not iconEnabled() then return end

        -- Already cached?
        local cached = imageCache[cacheKey]
        if cached and isValidObject(cached) then
            pcall(function()
                imageWidget:SetBrushFromTexture(cached, false)
                imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            if counterData then
                if cacheKey == "Player" then counterData.PlayerLoaded = true counterData.PlayerRetryCount = 0 counterData.PlayerRetryMaxed = nil end -- [FIXED]
                if cacheKey == "Bot"    then counterData.BotLoaded = true counterData.BotRetryCount = 0 counterData.BotRetryMaxed = nil end -- [FIXED]
            end
            return
        end

        -- Applies a loaded texture and updates cache
        local function applyTexture(tex)
            if not iconEnabled() then return false end
            if not tex or not isValidObject(tex) then
                if not _G["_pngInv"..cacheKey] then _G["_pngInv"..cacheKey] = true _edbg("invalid "..tostring(cacheKey)) end
                return false
            end
            if not isValidObject(imageWidget) then return false end

            imageCache[cacheKey] = tex
            if not _G["_pngOk"..cacheKey] then _G["_pngOk"..cacheKey] = true _edbg("applied "..tostring(cacheKey)) end
            if counterData then
                if cacheKey == "Player" then counterData.PlayerLoaded = true counterData.PlayerRetryCount = 0 counterData.PlayerRetryMaxed = nil end -- [FIXED]
                if cacheKey == "Bot"    then counterData.BotLoaded = true counterData.BotRetryCount = 0 counterData.BotRetryMaxed = nil end -- [FIXED]
            end
            pcall(function()
                imageWidget:SetBrushFromTexture(tex, false)
                imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            return true
        end

        -- 1) Try local file paths
        for _, path in ipairs(getAssetSearchPaths(filename)) do
            if fileExists(path) then
                if not _G["_pngLf"..filename] then _G["_pngLf"..filename] = true _edbg("local found "..tostring(filename)) end
                local texture = nil
                pcall(function()
                    local assetUtil = package.loaded["common.asset_util"]
                    if not assetUtil then
                        assetUtil = require("common.asset_util")
                    end
                    if assetUtil and assetUtil.GetAssetSync then
                        texture = assetUtil.GetAssetSync(path)
                    end
                end)
                if not texture then
                    pcall(function()
                        if CGame and CGame.LoadObject then
                            texture = CGame:LoadObject(path)
                        end
                    end)
                end
                if texture and applyTexture(texture) then
                    return
                end
            end
        end
        if not _G["_pngLn"..filename] then _G["_pngLn"..filename] = true _edbg("local miss "..tostring(filename)) end

        -- 2) Try remote download
        local function tryRemote(index)
            if index > #remoteURLs then
                if not _G["_pngFail"..cacheKey] then _G["_pngFail"..cacheKey] = true _edbg("failed "..tostring(cacheKey)) end
                return
            end
            local url = remoteURLs[index]
            local succeeded = false

            if not iconEnabled() then return end
            if not _G["_pngSt"..cacheKey] then _G["_pngSt"..cacheKey] = true _edbg("started "..tostring(cacheKey)) end

            -- 2b) image_download_mgr (game-supported HTTP image pipeline)
            if not succeeded then
                pcall(function()
                    local moduleManager = _G.ModuleManager or package.loaded["GameLua.GameCore.Module.ModuleManager"]
                    if not moduleManager then pcall(function() moduleManager = require("GameLua.GameCore.Module.ModuleManager") end) end
                    local mgr = nil
                    if moduleManager and moduleManager.GetModule and moduleManager.CommonModuleConfig then
                        pcall(function() mgr = moduleManager:GetModule(moduleManager.CommonModuleConfig.image_download_mgr) end)
                    end
                    if not mgr then mgr = package.loaded["client.slua.logic.image_download.image_download_mgr"] end
                    if not mgr then pcall(function() mgr = require("client.slua.logic.image_download.image_download_mgr") end) end
                    if mgr and mgr.DownloadImageByHttpWrapper then
                        mgr:DownloadImageByHttpWrapper(url,
                            function(tex)
                                if not succeeded and iconEnabled() and tex then succeeded = applyTexture(tex) end
                            end,
                            function()
                                if not succeeded and iconEnabled() then tryRemote(index + 1) end
                            end)
                    else
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end
                end)
            end
            local ok = pcall(function()
                local AsyncTask = import("AsyncTaskDownloadImage", nil)
                    or import("/Script/UMG.AsyncTaskDownloadImage", nil)
                if not (AsyncTask and AsyncTask.DownloadImage) then return end
                local task = AsyncTask.DownloadImage(url)
                if not (task and task.OnSuccess) then return end
                task.OnSuccess:Add(function(tex)
                    if not succeeded and iconEnabled() and tex then
                        succeeded = applyTexture(tex)
                    end
                end)
                if task.OnFail then
                    task.OnFail:Add(function()
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end)
                end
            end)
            -- 2c) slua_ui_framework util
            if not succeeded then
                pcall(function()
                    local util = package.loaded["client.slua_ui_framework.util"]
                    if not util then pcall(function() util = require("client.slua_ui_framework.util") end) end
                    if util and util.SetTexture then
                        util.SetTexture(imageWidget, url, {
                            sync = false,
                            onDownloadSuccess = function(tex)
                                if not succeeded and iconEnabled() and tex then succeeded = applyTexture(tex) end
                            end,
                        })
                    else
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end
                end)
            end
            -- Missing downloader is nonfatal: text counts still work.
        end
        tryRemote(1)
    end

    -- =========================================================
    -- ESP STATE TABLE
    -- =========================================================
    local ESP = {
        bActive = true,
        ESPCanvas = nil,

        BoxWidgets  = {},
        LineWidgets = {},

        CounterData = {
            ImgPlayer = nil, SlotPlayer    = nil,
            ImgBot    = nil, SlotBot       = nil,
            TxtPlayer = nil, SlotTxtPlayer = nil,
            TxtBot    = nil, SlotTxtBot    = nil,
            LastPlayerCount = -1,
            LastBotCount    = -1,
            PlayerLoaded    = false,
            BotLoaded       = false,
            LastDownloadRetry = 0,
            bCreated = false,
            PlayerRetryCount = 0, BotRetryCount = 0, -- [FIXED]
        },

        HealthColor      = { R = 0.0, G = 1.0, B = 0.0, A = 1.0 },
        HealthBgColor    = { R = 0.0, G = 0.0, B = 0.0, A = 0.85 },
        HealthBarWidth   = 4.0,
        CornerColor      = { R = 1.0, G = 1.0, B = 1.0, A = 1.0 },
        CornerThickness  = 2.0,
        CornerLengthRatio = 0.28,
        SnapLineThickness = 1.5,
        SnapLineOriginY   = 72,

        _CanvasScaleX = 1.0,
        _CanvasScaleY = 1.0,
        _CanvasOffsetX = 0.0,
        _CanvasOffsetY = 0.0,
        _LastCanvas = nil,
        _LastTransformTime = 0,
        _LastHeavyUpdateTime = 0,
        _LastVisCheckTime = 0,
        _VisCheckCache = {},
    }

    ESP.OwnedWidgets = {}
    local function newWidget(path, parent)
        local widget = CGame:NewObjectFromPath(path, parent)
        if widget then ESP.OwnedWidgets[widget] = true end
        return widget
    end
    local function removeWidget(widget)
        if not widget then return end
        pcall(function()
            if isValidObject(widget) then
                widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                if widget.RemoveFromParent then widget:RemoveFromParent() end
            end
        end)
        ESP.OwnedWidgets[widget] = nil
    end
    local function removeBox(box)
        if not box then return end
        for _, corner in pairs(box.Corners or {}) do removeWidget(corner.widget) end
        for _, name in ipairs({"CornerContainer", "BgWidget", "HealthWidget",
            "WeaponWidget", "FlagWidget", "NameWidget", "DistWidget", "StateWidget"}) do
            removeWidget(box[name])
        end
    end

    -- =========================================================
    -- CANVAS LOOKUP
    -- =========================================================
    local function esp_GetMainCanvas()
        local uiTools = package.loaded["GameLua.Mod.BaseMod.Common.UI.InGameUITools"]
        if not uiTools then
            pcall(function()
                uiTools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
            end)
        end
        if not uiTools then return nil end

        local baseUI = nil
        if uiTools.GetMainControlBaseUI then
            baseUI = uiTools.GetMainControlBaseUI()
        end
        if not isValidObject(baseUI) then return nil end

        local canvas = nil
        if baseUI.CanvasPanel_0 and isValidObject(baseUI.CanvasPanel_0) then
            canvas = baseUI.CanvasPanel_0
        elseif baseUI.CanvasPanel_42 and isValidObject(baseUI.CanvasPanel_42) then
            canvas = baseUI.CanvasPanel_42
        end

        if canvas then
            ESP.ESPCanvas = canvas
        end
        return canvas
    end
    ESP.GetMainCanvas = esp_GetMainCanvas

    -- =========================================================
    -- WIDGET CREATION HELPERS
    -- =========================================================
    -- Adapted from the supplied reference's safeSetColor, with SlateColor fallback.
    -- Do not let an unsupported optional colour setter kill every ESP component.
    local function safeSetColor(widget, color)
        if not widget or not color or not isValidObject(widget) then return false end
        for _, method in ipairs({"SetColorAndOpacity", "SetBrushColor"}) do
            local ok = pcall(function() widget[method](widget, color) end)
            if ok then return true end
        end
        local ok = pcall(function() widget:SetColorAndOpacity(toSlateColor(color)) end)
        if not ok then ESP.LastWarning = "Native widget colour setters rejected a colour" end
        return ok
    end
    local function makeBorder(canvas, color)
        local border = newWidget("/Script/UMG.Border", canvas)
        if not isValidObject(border) then return nil end
        safeSetColor(border, color)
        border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = canvas:AddChildToCanvas(border)
        if slot then slot:SetAutoSize(false) end
        return { widget = border, slot = slot }
    end

    local function makeText(canvas, color, size, align)
        local txt = newWidget("/Script/UMG.TextBlock", canvas)
        if not isValidObject(txt) then return nil, nil end

        txt:SetText("")
        size = math.floor(size or 10)

        local font = txt.Font
        if font then
            font.Size = size
            if font.OutlineSettings then
                font.OutlineSettings.OutlineSize = 1
                font.OutlineSettings.OutlineColor = LinearColor(0, 0, 0, 1)
            end
            if txt.SetFont then txt:SetFont(font) else txt.Font = font end
        end
        if txt.SetFontSize then txt:SetFontSize(size) end
        if txt.SetJustification then txt:SetJustification(1) end
        if txt.SetHorizontalAlignment then txt:SetHorizontalAlignment(1) end
        if txt.SetVerticalAlignment then txt:SetVerticalAlignment(1) end
        if txt.SetAutoWrapText then txt:SetAutoWrapText(false) end

        safeSetColor(txt, toSlateColor(color))

        if txt.SetShadowOffset then txt:SetShadowOffset(Vector2D(0, 0)) end
        if txt.SetShadowColorAndOpacity then
            txt:SetShadowColorAndOpacity(LinearColor(0, 0, 0, 0))
        end

        txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        local slot = canvas:AddChildToCanvas(txt)
        if slot then
            slot:SetAutoSize(true)
            slot:SetZOrder(1000)
            slot:SetAlignment(align or Vector2D(0.5, 0.0))
        end
        return txt, slot
    end

    local function makeImage(canvas, size, align)
        local img = newWidget("/Script/UMG.Image", canvas)
        if not isValidObject(img) then return nil, nil end

        img:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = canvas:AddChildToCanvas(img)
        if slot then
            slot:SetAutoSize(false)
            slot:SetSize(size)
            slot:SetZOrder(1000)
            slot:SetAlignment(align or Vector2D(0.5, 0.0))
        end
        return img, slot
    end

    -- =========================================================
    -- CREATE ESP WIDGET (per-player box)
    -- =========================================================
    local function esp_CreateESPWidget(canvas)
        if not LinearColor or not Vector2D then return nil end

        -- Root container (canvas panel)
        local root = newWidget("/Script/UMG.CanvasPanel", canvas)
        if not isValidObject(root) then return nil end

        local rootSlot = canvas:AddChildToCanvas(root)
        if not rootSlot then return nil end
        rootSlot:SetAutoSize(false)
        rootSlot:SetZOrder(995)
        rootSlot:SetAlignment(Vector2D(0.5, 0.5))

        -- Corner color
        local cc = ESP.CornerColor
        local cornerColor = LinearColor(cc.R, cc.G, cc.B, cc.A)

        -- 8 corner borders
        local corners = {
            TopLeft_H     = makeBorder(root, cornerColor),
            TopLeft_V     = makeBorder(root, cornerColor),
            TopRight_H    = makeBorder(root, cornerColor),
            TopRight_V    = makeBorder(root, cornerColor),
            BottomLeft_H  = makeBorder(root, cornerColor),
            BottomLeft_V  = makeBorder(root, cornerColor),
            BottomRight_H = makeBorder(root, cornerColor),
            BottomRight_V = makeBorder(root, cornerColor),
        }

        -- Health background (Border)
        local bg = newWidget("/Script/UMG.Border", canvas)
        local hb = ESP.HealthBgColor
        safeSetColor(bg, LinearColor(hb.R, hb.G, hb.B, hb.A))
        bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local bgSlot = canvas:AddChildToCanvas(bg)
        if bgSlot then
            bgSlot:SetAutoSize(false)
            bgSlot:SetZOrder(998)
            bgSlot:SetAlignment(Vector2D(0.5, 1.0))
        end

        -- Health fill (Image)
        local health = newWidget("/Script/UMG.Image", canvas)
        local hc = ESP.HealthColor
        safeSetColor(health, LinearColor(hc.R, hc.G, hc.B, hc.A))
        health:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local healthSlot = canvas:AddChildToCanvas(health)
        if healthSlot then
            healthSlot:SetAutoSize(false)
            healthSlot:SetZOrder(999)
            healthSlot:SetAlignment(Vector2D(0.5, 1.0))
        end

        -- Text lines
        local weapon,  weaponSlot  = makeText(canvas, yellowColor, 10, Vector2D(0.5, 1.0))
        local name,    nameSlot    = makeText(canvas, blueColor,   10, Vector2D(0.5, 0.0))
        local dist,    distSlot    = makeText(canvas, whiteColor,  10, Vector2D(0.5, 0.0))
        local state,   stateSlot   = makeText(canvas, greenColor,  10, Vector2D(0.5, 0.0))

        -- Flag image
        local flag, flagSlot = makeImage(canvas, Vector2D(14, 16), Vector2D(0.5, 1.0))

        return {
            CornerContainer = root,
            CornerSlot      = rootSlot,
            Corners         = corners,

            BgWidget        = bg,
            BgSlot          = bgSlot,

            HealthWidget    = health,
            HealthSlot      = healthSlot,

            WeaponWidget    = weapon,
            WeaponSlot      = weaponSlot,

            FlagWidget      = flag,
            FlagSlot        = flagSlot,

            NameWidget      = name,
            NameSlot        = nameSlot,

            DistWidget      = dist,
            DistSlot        = distSlot,

            StateWidget     = state,
            StateSlot       = stateSlot,

            _cachedWeapon   = "",
            _cachedNation   = nil,
            _cachedName     = "",
            _cachedDist     = "",
            _cachedState    = "",
            _cachedIsCover  = false,
            _cachedIsKnocked = false,
            _lastScanTime   = 0,
            lastW = 0,
            lastH = 0,
            bVisible = true,
        }
    end
    ESP.CreateESPWidget = esp_CreateESPWidget

    -- =========================================================
    -- CORNER DIMENSION UPDATER
    -- =========================================================
    local function esp_UpdateCornerDimensions(widget, width, height)
        -- Skip if virtually unchanged
        if widget.lastW and widget.lastH then
            if math.abs(width - widget.lastW) < 1.5
               and math.abs(height - widget.lastH) < 1.5 then
                return
            end
        end
        widget.lastW = width
        widget.lastH = height

        local thickness = ESP.CornerThickness
        local length = math.max(7,
            math.min(width, height) * ESP.CornerLengthRatio)

        widget.CornerSlot:SetSize(Vector2D(width, height))

        local function place(corner, x, y, w, h)
            if corner and corner.slot then
                corner.slot:SetPosition(Vector2D(x, y))
                corner.slot:SetSize(Vector2D(w, h))
            end
        end

        local c = widget.Corners
        place(c.TopLeft_H,     0,              0,              length,    thickness)
        place(c.TopLeft_V,     0,              0,              thickness, length)
        place(c.TopRight_H,    width - length, 0,              length,    thickness)
        place(c.TopRight_V,    width - thickness, 0,           thickness, length)
        place(c.BottomLeft_H,  0,              height - thickness, length,    thickness)
        place(c.BottomLeft_V,  0,              height - length, thickness, length)
        place(c.BottomRight_H, width - length, height - thickness, length,    thickness)
        place(c.BottomRight_V, width - thickness, height - length, thickness, length)
    end
    ESP.UpdateCornerDimensions = esp_UpdateCornerDimensions

    -- =========================================================
    -- CANVAS TRANSFORM (scale + offset)
    -- =========================================================
    local function esp_UpdateCanvasTransform(playerController)
        if not ESP.ESPCanvas or not isValidObject(ESP.ESPCanvas) then return end

        local ok = false
        if SlateBlueprintLibrary and SlateBlueprintLibrary.AbsoluteToLocal then
            local geom = ESP.ESPCanvas:GetCachedGeometry()
            if geom then
                local p0 = SlateBlueprintLibrary.AbsoluteToLocal(geom, Vector2D(0, 0))
                local p100 = SlateBlueprintLibrary.AbsoluteToLocal(geom, Vector2D(100, 100))
                if p0 and p100 then
                    ESP._CanvasScaleX = (p100.X - p0.X) / 100
                    ESP._CanvasScaleY = (p100.Y - p0.Y) / 100
                    ESP._CanvasOffsetX = p0.X
                    ESP._CanvasOffsetY = p0.Y
                    ok = true
                end
            end
        end

        if not ok and WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
            local scale = tonumber(WidgetLayoutLibrary.GetViewportScale(playerController)) or 1.0
            if scale <= 0 then scale = 1 end
            ESP._CanvasScaleX = 1.0 / scale
            ESP._CanvasScaleY = 1.0 / scale
            ESP._CanvasOffsetX = 0
            ESP._CanvasOffsetY = 0
        end
    end
    ESP.UpdateCanvasTransform = esp_UpdateCanvasTransform

    -- =========================================================
    -- WORLD -> CANVAS LOCAL PROJECTION
    -- =========================================================
    local function esp_ProjectWorldToCanvasLocal(playerController, worldPos)
        if not isValidObject(playerController) or not worldPos or not zeroVector then
            return false, 0, 0
        end

        zeroVector.X, zeroVector.Y = 0, 0
        local ok = playerController:ProjectWorldLocationToScreen(worldPos, zeroVector, true)
        if ok == true or ok == 1 then
            if zeroVector.X == zeroVector.X and zeroVector.Y == zeroVector.Y
                and math.abs(zeroVector.X) < math.huge and math.abs(zeroVector.Y) < math.huge then
                local x = zeroVector.X * ESP._CanvasScaleX + ESP._CanvasOffsetX
                local y = zeroVector.Y * ESP._CanvasScaleY + ESP._CanvasOffsetY
                return true, x, y
            end
        end
        return false, 0, 0
    end
    ESP.ProjectWorldToCanvasLocal = esp_ProjectWorldToCanvasLocal

    -- =========================================================
    -- SNAP LINE START POINT (from screen bottom-center)
    -- =========================================================
    local function esp_GetSnapLineStartPos(playerController, canvas)
        local vw, vh, scale = 0, 0, 1.0

        pcall(function()
            if playerController and playerController.GetViewportSize then
                local sz = Vector2D(0, 0)
                playerController:GetViewportSize(sz)
                if sz and sz.X and sz.X > 200 then
                    vw, vh = sz.X, sz.Y
                end
            end
        end)

        if vw <= 200 then
            pcall(function()
                if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportSize then
                    local sz = WidgetLayoutLibrary.GetViewportSize(playerController)
                    if sz and sz.X and sz.X > 200 then
                        vw, vh = sz.X, sz.Y
                    end
                end
            end)
        end

        pcall(function()
            if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
                local s = WidgetLayoutLibrary.GetViewportScale(playerController)
                if type(s) == "number" and s > 0 then
                    scale = s
                end
            end
        end)

        if vw <= 200 then
            vw = 1920 * scale
            vh = 1080 * scale
        end

        local cx = vw / 2.0
        local cy = ESP.SnapLineOriginY * scale
        local x = cx * ESP._CanvasScaleX + ESP._CanvasOffsetX
        local y = cy * ESP._CanvasScaleY + ESP._CanvasOffsetY
        return x, y
    end
    ESP.GetSnapLineStartPos = esp_GetSnapLineStartPos

    -- =========================================================
    -- SNAP LINE WIDGET
    -- =========================================================
    local function esp_CreateSnapLine(canvas)
        if not isValidObject(canvas) then return nil end

        local border = newWidget("/Script/UMG.Border", canvas)
        if not isValidObject(border) then return nil end

        safeSetColor(border, whiteColor)
        border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local pivotApplied = pcall(function()
            border:SetRenderTransformPivot(Vector2D(0.0, 0.5))
        end)
        if not pivotApplied then
            pivotApplied = pcall(function() border.RenderTransformPivot = Vector2D(0.0, 0.5) end)
        end
        -- Default center pivot needs midpoint positioning; otherwise lines orbit the start.
        local centerPivot = not pivotApplied

        local slot = canvas:AddChildToCanvas(border)
        if slot then
            slot:SetAutoSize(false)
            slot:SetZOrder(990)
        end

        return { Widget = border, Slot = slot, bVisible = true, CenterPivot = centerPivot }
    end
    ESP.CreateSnapLine = esp_CreateSnapLine

    local function esp_UpdateSnapLine(pawnKey, tx, ty, ox, oy, color, canvas)
        local line = ESP.LineWidgets[pawnKey]
        if not (line and isValidObject(line.Widget)) then
            line = esp_CreateSnapLine(canvas)
            if not (line and line.Widget and line.Slot) then return end
            ESP.LineWidgets[pawnKey] = line
        end

        if not line.bVisible then
            line.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            line.bVisible = true
        end

        if color then
            pcall(function() safeSetColor(line.Widget, color) end)
        end

        local dx, dy = tx - ox, ty - oy
        local length = math.sqrt(dx * dx + dy * dy)
        local angle
        if math.atan2 then
            angle = math.atan2(dy, dx)
        else
            angle = math.atan(dy, dx) -- Lua 5.3 two-argument atan preserves quadrant
        end
        angle = angle * (180.0 / math.pi)

        local thickness = ESP.SnapLineThickness or 1.0
        local drawX, drawY = ox, oy - thickness * 0.5
        if line.CenterPivot then
            drawX = (ox + tx) * 0.5 - length * 0.5
            drawY = (oy + ty) * 0.5 - thickness * 0.5
        end

        if not line._CachedPosVec then
            line._CachedPosVec  = Vector2D(drawX, drawY)
            line._CachedSizeVec = Vector2D(length, thickness)
        else
            line._CachedPosVec.X  = drawX
            line._CachedPosVec.Y  = drawY
            line._CachedSizeVec.X = length
            line._CachedSizeVec.Y = thickness
        end

        pcall(function()
            line.Slot:SetPosition(line._CachedPosVec)
            line.Slot:SetSize(line._CachedSizeVec)
            line.Widget:SetRenderAngle(angle)
        end)
    end
    ESP.UpdateSnapLine = esp_UpdateSnapLine

    local function esp_HideSnapLine(pawnKey)
        local line = ESP.LineWidgets[pawnKey]
        if line and line.Widget and isValidObject(line.Widget) and line.bVisible then
            line.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            line.bVisible = false
        end
    end
    ESP.HideSnapLine = esp_HideSnapLine

    -- =========================================================
    -- ENEMY COUNTER
    -- =========================================================
    local function esp_CreateEnemyCounter(canvas, layoutX, layoutY)
        local cd = ESP.CounterData
        if cd.Canvas ~= nil and cd.Canvas ~= canvas then -- [FIXED]
            for _, w in pairs({cd.ImgPlayer, cd.ImgBot, cd.TxtPlayer, cd.TxtBot, cd.SqPlayer, cd.SqBot}) do -- [FIXED]
                if w then removeWidget(w) end -- [FIXED]
            end -- [FIXED]
            cd.ImgPlayer, cd.SlotPlayer, cd.ImgBot, cd.SlotBot = nil, nil, nil, nil -- [FIXED]
            cd.TxtPlayer, cd.SlotTxtPlayer, cd.TxtBot, cd.SlotTxtBot = nil, nil, nil, nil -- [FIXED]
            cd.SqPlayer, cd.SqBot = nil, nil -- [FIXED]
            cd.PlayerLoaded, cd.BotLoaded = false, false -- [FIXED]
            cd.PlayerRetryCount, cd.BotRetryCount = 0, 0 -- [FIXED]
            cd.PlayerRetryMaxed, cd.BotRetryMaxed = nil, nil -- [FIXED]
        end -- [FIXED]
        cd.Canvas = canvas -- [FIXED]
        cd.Disposed = nil -- [FIXED]
        if cd.ImgPlayer and isValidObject(cd.ImgPlayer)
           and cd.ImgBot and isValidObject(cd.ImgBot) then
            return true
        end

        local imgPlayer, slotPlayer = makeImage(canvas, Vector2D(65, 36), nil)
        if slotPlayer then
            slotPlayer:SetAlignment(Vector2D(0.0, 0.0))
            slotPlayer:SetPosition(Vector2D(layoutX, layoutY))
            slotPlayer:SetZOrder(1005)
        end

        local imgBot, slotBot = makeImage(canvas, Vector2D(65, 36), nil)
        if slotBot then
            slotBot:SetAlignment(Vector2D(0.0, 0.0))
            slotBot:SetPosition(Vector2D(layoutX + 65, layoutY))
            slotBot:SetZOrder(1005)
        end

        local txtPlayer, slotTxtPlayer = makeText(canvas, whiteColor, 16, Vector2D(0.0, 0.5))
        if slotTxtPlayer then
            slotTxtPlayer:SetPosition(Vector2D(layoutX + 40, layoutY + 18))
            slotTxtPlayer:SetZOrder(1010)
        end

        local txtBot, slotTxtBot = makeText(canvas, whiteColor, 16, Vector2D(0.0, 0.5))
        if slotTxtBot then
            slotTxtBot:SetPosition(Vector2D(layoutX + 65 + 40, layoutY + 18))
            slotTxtBot:SetZOrder(1010)
        end

        -- Kick off icon downloads
        loadWidgetImage(imgPlayer, playerIconURLs, "ic_danger_enemy.png", "Player", cd)
        loadWidgetImage(imgBot,    botIconURLs,    "ic_clear_boot.png",   "Bot",    cd)

        cd.ImgPlayer = imgPlayer; cd.SlotPlayer = slotPlayer
        cd.ImgBot    = imgBot;    cd.SlotBot    = slotBot
        cd.TxtPlayer = txtPlayer; cd.SlotTxtPlayer = slotTxtPlayer
        cd.TxtBot    = txtBot;    cd.SlotTxtBot = slotTxtBot
        cd.bCreated  = true
        return true
    end
    ESP.CreateEnemyCounter = esp_CreateEnemyCounter

    local function esp_UpdateEnemyCounterDisplay(pc, bc, canvas, ox, oy)
        local cd = ESP.CounterData
        local show = _G.JINSHIFORYOUConfig and _G.JINSHIFORYOUConfig.EspV3_Count
        local hidden = UEnums.ESlateVisibility.Collapsed

        if not show then
            for _, w in pairs({cd.ImgPlayer, cd.ImgBot, cd.TxtPlayer, cd.TxtBot}) do
                if w and isValidObject(w) then
                    w:SetWidgetVisibility(hidden)
                end
            end
            return
        end

        if not esp_CreateEnemyCounter(canvas, ox, oy) then return end

        -- Retry downloads periodically (max 3 per icon) -- [FIXED]
        local now = os.clock()
        if not (cd.PlayerLoaded and cd.BotLoaded)
           and (now - cd.LastDownloadRetry) > 2.0 then
            cd.LastDownloadRetry = now
            if not cd.PlayerLoaded and cd.ImgPlayer then
                cd.PlayerRetryCount = (cd.PlayerRetryCount or 0) + 1 -- [FIXED]
                if cd.PlayerRetryCount <= 3 then -- [FIXED]
                    _edbg("ICON: retry Player " .. tostring(cd.PlayerRetryCount)) -- [FIXED]
                    loadWidgetImage(cd.ImgPlayer, playerIconURLs,
                        "ic_danger_enemy.png", "Player", cd)
                elseif not cd.PlayerRetryMaxed then -- [FIXED]
                    cd.PlayerRetryMaxed = true -- [FIXED]
                    _edbg("ICON: max retries reached Player") -- [FIXED]
                end -- [FIXED]
            end
            if not cd.BotLoaded and cd.ImgBot then
                cd.BotRetryCount = (cd.BotRetryCount or 0) + 1 -- [FIXED]
                if cd.BotRetryCount <= 3 then -- [FIXED]
                    _edbg("ICON: retry Bot " .. tostring(cd.BotRetryCount)) -- [FIXED]
                    loadWidgetImage(cd.ImgBot, botIconURLs,
                        "ic_clear_boot.png", "Bot", cd)
                elseif not cd.BotRetryMaxed then -- [FIXED]
                    cd.BotRetryMaxed = true -- [FIXED]
                    _edbg("ICON: max retries reached Bot") -- [FIXED]
                end -- [FIXED]
            end
        end

        pcall(function()
            if cd.SlotPlayer then
                cd.SlotPlayer:SetSize(Vector2D(65, 36))
                cd.SlotPlayer:SetPosition(Vector2D(ox, oy))
            end
            if cd.SlotBot then
                cd.SlotBot:SetSize(Vector2D(65, 36))
                cd.SlotBot:SetPosition(Vector2D(ox + 65, oy))
            end
            if cd.SlotTxtPlayer then
                cd.SlotTxtPlayer:SetPosition(Vector2D(ox + 40, oy + 18))
            end
            if cd.SlotTxtBot then
                cd.SlotTxtBot:SetPosition(Vector2D(ox + 65 + 40, oy + 18))
            end

            if cd.LastPlayerCount ~= pc and cd.TxtPlayer and isValidObject(cd.TxtPlayer) then
                cd.TxtPlayer:SetText(tostring(pc))
                cd.LastPlayerCount = pc
            end
            if cd.LastBotCount ~= bc and cd.TxtBot and isValidObject(cd.TxtBot) then
                cd.TxtBot:SetText(tostring(bc))
                cd.LastBotCount = bc
            end

            local vis = UEnums.ESlateVisibility.SelfHitTestInvisible
            local hidden = UEnums.ESlateVisibility.Collapsed
            for _, w in pairs({cd.TxtPlayer, cd.TxtBot}) do
                if w and isValidObject(w) then w:SetWidgetVisibility(vis) end
            end
            if cd.ImgPlayer and isValidObject(cd.ImgPlayer) then
                cd.ImgPlayer:SetWidgetVisibility(cd.PlayerLoaded and vis or hidden)
            end
            if cd.ImgBot and isValidObject(cd.ImgBot) then
                cd.ImgBot:SetWidgetVisibility(cd.BotLoaded and vis or hidden)
            end
        end)
    end
    ESP.UpdateEnemyCounterDisplay = esp_UpdateEnemyCounterDisplay

    -- =========================================================
    -- SHOW / HIDE WIDGET
    -- =========================================================
    local function esp_HideWidget(widget)
        if not widget then return end
        widget.bVisible = false
        local vis = UEnums.ESlateVisibility.Collapsed
        for _, key in ipairs({
            "CornerContainer", "BgWidget", "HealthWidget",
            "WeaponWidget", "FlagWidget", "NameWidget",
            "DistWidget", "StateWidget"
        }) do
            local w = widget[key]
            if w and isValidObject(w) then w:SetWidgetVisibility(vis) end
        end
    end
    ESP.HideWidget = esp_HideWidget

    local function esp_ShowWidget(widget)
        if not widget then return end
        widget.bVisible = true
        local vis   = UEnums.ESlateVisibility.SelfHitTestInvisible
        local hide  = UEnums.ESlateVisibility.Collapsed
        local cfg   = _G.JINSHIFORYOUConfig or {}

        local function setVis(w, enabled)
            if w and isValidObject(w) then w:SetWidgetVisibility(enabled and vis or hide) end
        end

        setVis(widget.CornerContainer, cfg.EspV3_Box)
        setVis(widget.BgWidget,        cfg.EspV3_Health)
        setVis(widget.HealthWidget,    cfg.EspV3_Health)
        setVis(widget.WeaponWidget,    cfg.EspV3_Weapon)
        setVis(widget.FlagWidget,      cfg.EspV3_Flag)
        setVis(widget.NameWidget,      cfg.EspV3_Name)
        setVis(widget.DistWidget,      cfg.EspV3_Dist)
        setVis(widget.StateWidget,     cfg.EspV3_State)
    end
    ESP.ShowWidget = esp_ShowWidget

    local function esp_ClearESP() -- [FIXED]
        do -- [FIXED]
            local cd0 = ESP.CounterData -- [FIXED]
            local keep = {} -- [FIXED]
            if cd0 then -- [FIXED]
                for _, w in pairs({cd0.ImgPlayer, cd0.ImgBot, cd0.TxtPlayer, cd0.TxtBot, cd0.SqPlayer, cd0.SqBot}) do -- [FIXED]
                    if w then keep[w] = true end -- [FIXED]
                end -- [FIXED]
            end -- [FIXED]
            for widget in pairs(ESP.OwnedWidgets) do -- [FIXED]
                if not keep[widget] then removeWidget(widget) end -- [FIXED]
            end -- [FIXED]
        end -- [FIXED]
        ESP.OwnedWidgets = {}
        ESP.LocalPawn = nil
        ESP._CanvasScaleX, ESP._CanvasScaleY = 1, 1
        ESP._CanvasOffsetX, ESP._CanvasOffsetY = 0, 0
        ESP._LastTransformTime, ESP._LastHeavyUpdateTime, ESP._LastVisCheckTime = -math.huge, -math.huge, -math.huge
        ESP.BoxWidgets  = {}
        ESP.LineWidgets = {}
        do -- [FIXED]
            local cd = ESP.CounterData -- [FIXED]
            if cd then -- [FIXED]
                for _, w in pairs({cd.ImgPlayer, cd.ImgBot, cd.TxtPlayer, cd.TxtBot, cd.SqPlayer, cd.SqBot}) do -- [FIXED]
                    if w and isValidObject(w) then -- [FIXED]
                        pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) -- [FIXED]
                    end -- [FIXED]
                end -- [FIXED]
                cd.PlayerLoaded = false -- [FIXED]
                cd.BotLoaded = false -- [FIXED]
                cd.PlayerRetryCount = 0 -- [FIXED]
                cd.BotRetryCount = 0 -- [FIXED]
                cd.PlayerRetryMaxed = nil -- [FIXED]
                cd.BotRetryMaxed = nil -- [FIXED]
                cd.LastPlayerCount = -1 -- [FIXED]
                cd.LastBotCount = -1 -- [FIXED]
                cd.LastDownloadRetry = 0 -- [FIXED]
                cd.bCreated = false -- [FIXED]
            end -- [FIXED]
        end -- [FIXED]
        ESP.ESPCanvas   = nil
        ESP._LastCanvas = nil
        ESP._VisCheckCache = {}
    end
    ESP.ClearESP = esp_ClearESP

    -- =========================================================
    -- MAIN TICK: esp_UpdateESP
    -- =========================================================
    local function esp_UpdateESP()
        if not (_G.JINSHIFORYOUConfig and _G.JINSHIFORYOUConfig.EspV3_Master) then
            esp_ClearESP()
            return
        end

        local canvas = esp_GetMainCanvas()
        if not canvas then esp_ClearESP(); return end

        local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"]
                            or _G.GameplayData
        if not GameplayData then esp_ClearESP(); return end

        local pc = GameplayData.GetPlayerController and GameplayData.GetPlayerController()
        if not isValidObject(pc) then esp_ClearESP(); return end
        local localPawn = pc.GetPlayerCharacterSafety and pc:GetPlayerCharacterSafety()
        if not isValidObject(localPawn) and GameplayData.GetPlayerCharacter then
            localPawn = GameplayData.GetPlayerCharacter()
        end
        if not isValidObject(localPawn) then esp_ClearESP(); return end
        local now = os.clock and os.clock() or 0
        if ESP._LastCanvas ~= canvas or ESP.LocalPawn ~= localPawn then
            esp_ClearESP()
            ESP._LastCanvas = canvas
            ESP.ESPCanvas = canvas
            ESP.LocalPawn = localPawn
        end

        -- Throttled transforms
        if (now - ESP._LastTransformTime) > 0.25 then
            esp_UpdateCanvasTransform(pc)
            ESP._LastTransformTime = now
        end

        local heavyUpdate = (now - ESP._LastHeavyUpdateTime) > 0.15
        local visCheck    = (now - ESP._LastVisCheckTime)   > 0.12
        if heavyUpdate then ESP._LastHeavyUpdateTime = now end
        if visCheck    then ESP._LastVisCheckTime    = now end

        local snapX, snapY = esp_GetSnapLineStartPos(pc, canvas)

        local myTeam = localPawn.TeamID
            or (localPawn.GetTeamID and localPawn:GetTeamID())
            or 0

        local pawns, seenObjects, seenKeys = {}, {}, {}
        local function merge(list)
            if not list then return end
            for _, pawn in pairs(list) do
                if isValidObject(pawn) and not seenObjects[pawn] then
                    local key
                    pcall(function()
                        key = pawn.PlayerKey
                        if not key and pawn.GetPlayerKey then key = pawn:GetPlayerKey() end
                    end)
                    if key == 0 or key == "0" or key == "" then key = nil end
                    if key ~= nil then key = tostring(key) end
                    if not key or not seenKeys[key] then
                        seenObjects[pawn] = true
                        if key then seenKeys[key] = true end
                        pawns[#pawns + 1] = pawn
                    end
                end
            end
        end
        local function collect(object, name)
            if not object then return end
            local ok, result = pcall(function() return object[name](object) end)
            if not ok or result == nil then
                ok, result = pcall(function() return object[name]() end)
            end
            if ok and result then merge(result) end
        end
        collect(Game, "GetAllPlayerPawns")
        collect(GameplayData, "GetAllPlayerCharacters")
        merge(GameplayData.GameCharacters)
        ESP.ActorCount = #pawns

        for _, widget in pairs(ESP.BoxWidgets) do esp_HideWidget(widget) end
        for key in pairs(ESP.LineWidgets) do esp_HideSnapLine(key) end
        local alive = {}
        local playerCount, botCount = 0, 0

        for key, pawn in pairs(pawns) do
            if isValidObject(pawn) and pawn ~= localPawn then
                local team = pawn.TeamID
                    or (pawn.GetTeamID and pawn:GetTeamID())
                    or -1

                local hp = pawn.Health or 0
                local aliveCheck = readBool(pawn, "IsAlive", nil)
                if aliveCheck == nil then
                    aliveCheck = not readBool(pawn, "bDead", false)
                        and (hp > 0 or readBool(pawn, "bIsKnocked", false)
                            or readBool(pawn, "IsKnocked", false))
                end

                if aliveCheck and team ~= myTeam then
                    local pawnKey = pawn -- actor identity; array indexes are unstable
                    alive[pawnKey] = true

                    local isBot = pawn.bIsAI or pawn.bIsAIBot or pawn.bIsABot
                    if not isBot and Game and Game.IsAI then
                        isBot = Game:IsAI(pawn)
                    end
                    if isBot then botCount = botCount + 1
                    else           playerCount = playerCount + 1 end

                    local loc = pawn.K2_GetActorLocation
                                and pawn:K2_GetActorLocation()
                    if not loc and pawn.RootComponent then
                        loc = pawn.RootComponent:K2_GetComponentLocation()
                    end

                    if loc then
                        local mesh = pawn.Mesh
                            or (pawn.GetMesh and pawn:GetMesh())
                            or pawn.CharacterMesh0

                        local headPos, rootPos

                        if mesh and mesh.GetSocketLocation then
                            local h = mesh:GetSocketLocation("Head")
                            if not h or (h.X == 0 and h.Y == 0 and h.Z == 0) then
                                h = mesh:GetSocketLocation("head")
                            end
                            if h and not (h.X == 0 and h.Y == 0 and h.Z == 0) then
                                headPos = Vector(h.X, h.Y, h.Z + 15)
                            end

                            local r = mesh:GetSocketLocation("root")
                            if not r or (r.X == 0 and r.Y == 0 and r.Z == 0) then
                                r = mesh:GetSocketLocation("Root")
                            end
                            if r and not (r.X == 0 and r.Y == 0 and r.Z == 0) then
                                rootPos = r
                            end
                        end

                        -- Pose detection
                        local isProne  = readBool(pawn, "bIsProning", false)
                                         or readBool(pawn, "bIsProne", false)
                                         or readBool(pawn, "IsProne", false)
                                         or pawn.PoseState == 2
                                         or pawn.PoseState == "Prone"
                        local isCrouch = readBool(pawn, "bIsCrouched", false)
                                         or readBool(pawn, "IsCrouched", false)
                                         or pawn.PoseState == 1
                                         or pawn.PoseState == "Crouch"

                        if not headPos or not rootPos then
                            local headOff = isProne and 18 or (isCrouch and 50 or 88)
                            local rootOff = isProne and -22 or (isCrouch and -68 or -90)
                            if not headPos then
                                headPos = Vector(loc.X, loc.Y, loc.Z + headOff)
                            end
                            if not rootPos then
                                rootPos = Vector(loc.X, loc.Y, loc.Z + rootOff)
                            end
                        end

                        local ok1, headX, headY =
                            esp_ProjectWorldToCanvasLocal(pc, headPos)
                        local ok2, rootX, rootY =
                            esp_ProjectWorldToCanvasLocal(pc, rootPos)

                        local widget = ESP.BoxWidgets[pawnKey]
                        if not (widget and isValidObject(widget.CornerContainer)) then
                            widget = esp_CreateESPWidget(canvas)
                            if widget then ESP.BoxWidgets[pawnKey] = widget end
                        end

                        if widget and isValidObject(widget.CornerContainer) then
                            if ok1 and ok2 then
                                -- Geometry
                                local height = math.max(28, math.abs(rootY - headY))
                                local scale = isProne and 1.1 or (isCrouch and 0.7 or 0.55)
                                local width  = math.max(15, height * scale)

                                local cx     = (headX + rootX) * 0.5
                                local cy     = (rootY + headY) * 0.5
                                local top    = cy - height * 0.5
                                local bottom = cy + height * 0.5

                                esp_UpdateCornerDimensions(widget, width, height)
                                widget.CornerSlot:SetPosition(Vector2D(cx, cy))
                                esp_ShowWidget(widget)

                                -- Health bar
                                local barW = ESP.HealthBarWidth or 2.0
                                local barX = (cx - width * 0.5) - 2.5 - barW * 0.5

                                local hpNow = pawn.Health
                                              or (pawn.GetHealth and pawn:GetHealth())
                                              or 100
                                local hpMax = pawn.HealthMax
                                              or (pawn.GetHealthMax and pawn:GetHealthMax())
                                              or 100
                                if hpMax <= 0 then hpMax = 100 end

                                local pct    = math.max(0, math.min(1, hpNow / hpMax))
                                local fillH  = height * pct

                                widget.BgSlot:SetSize(Vector2D(barW, height))
                                widget.BgSlot:SetPosition(Vector2D(barX, bottom))
                                widget.HealthSlot:SetSize(Vector2D(barW, fillH))
                                widget.HealthSlot:SetPosition(Vector2D(barX, bottom))

                                -- Weapon (cached)
                                if _G.JINSHIFORYOUConfig.EspV3_Weapon and (heavyUpdate or widget._cachedWeapon == "") then
                                    local weaponName = "Fist"
                                    local w = (pawn.GetCurrentWeapon and pawn:GetCurrentWeapon())
                                          or (pawn.GetCurrentShootWeapon and pawn:GetCurrentShootWeapon())
                                          or (pawn.WeaponManagerComponent
                                              and pawn.WeaponManagerComponent.CurrentWeaponReplicated)

                                    if w and isValidObject(w) then
                                        local raw
                                        if type(w.GetWeaponName) == "function" then
                                            raw = w:GetWeaponName()
                                        end
                                        if not raw then raw = w.WeaponName end
                                        if raw and raw ~= "" then
                                            weaponName = tostring(raw)
                                                :gsub("^BP_", "")
                                                :gsub("_C$", "")
                                                :gsub("_Wrapper$", "")
                                        end
                                    end

                                    if widget._cachedWeapon ~= weaponName then
                                        widget.WeaponWidget:SetText(weaponName)
                                        widget._cachedWeapon = weaponName
                                    end
                                end
                                widget.WeaponSlot:SetPosition(Vector2D(cx, top - 3.5))

                                -- Nation flag (cached)
                                if _G.JINSHIFORYOUConfig.EspV3_Flag and (heavyUpdate or not widget._cachedNation) then
                                    local nation = (pawn.PlayerState and pawn.PlayerState.Nation)
                                                or pawn.Nation or ""
                                    nation = tostring(nation)
                                    if nation == "" or nation == "nil" or nation == "0" then
                                        nation = "G1"
                                    end

                                    if widget._cachedNation ~= nation then
                                        local resPath
                                        if CDataTable and CDataTable.GetTableData then
                                            local d = CDataTable.GetTableData("RegionConfig", nation)
                                            if d and d.res_path and d.res_path ~= "" then
                                                resPath = d.res_path
                                            end
                                        end
                                        if not resPath then
                                            resPath = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png.T_icon_flag_iland_png"
                                        end

                                        if widget.FlagWidget and isValidObject(widget.FlagWidget) then
                                            local applied = false
                                            if widget.FlagWidget.SetBrushResourceFromPathSync then
                                                widget.FlagWidget:SetBrushResourceFromPathSync(resPath, false)
                                                applied = true
                                            end
                                            if not applied and widget.FlagWidget.SetBrushFromPathAsync then
                                                widget.FlagWidget:SetBrushFromPathAsync(resPath, false)
                                                applied = true
                                            end
                                            if not applied then
                                                local util = package.loaded["client.slua_ui_framework.util"]
                                                if util and util.SetTexture then
                                                    util.SetTexture(widget.FlagWidget, resPath, { sync = true })
                                                    applied = true
                                                end
                                            end
                                            if not applied then
                                                local assetUtil = package.loaded["common.asset_util"]
                                                local tex = assetUtil and assetUtil.GetAssetSync
                                                            and assetUtil.GetAssetSync(resPath)
                                                if not tex and CGame and CGame.LoadObject then
                                                    tex = CGame:LoadObject(resPath)
                                                end
                                                if tex and widget.FlagWidget.SetBrushFromTexture then
                                                    widget.FlagWidget:SetBrushFromTexture(tex, false)
                                                end
                                            end
                                        end
                                        widget._cachedNation = nation
                                    end
                                end
                                if widget.FlagSlot then
                                    widget.FlagSlot:SetPosition(Vector2D(cx, top - 22.0))
                                end

                                -- Name (cached)
                                if heavyUpdate or widget._cachedName == "" then
                                    local name
                                    if isBot then
                                        name = "Bot"
                                    else
                                        name = pawn.PlayerName
                                            or pawn.PlayerNamePublic
                                            or (pawn.GetPlayerName and pawn:GetPlayerName())
                                            or "Player"
                                    end
                                    name = tostring(name)
                                    if widget._cachedName ~= name then
                                        widget.NameWidget:SetText(name)
                                        widget._cachedName = name
                                    end
                                end
                                widget.NameSlot:SetPosition(Vector2D(cx, bottom + 4.0))

                                -- Distance
                                local dist = math.floor(localPawn:GetDistanceTo(pawn) / 100.0)
                                local distStr = tostring(dist) .. "m"
                                if widget._cachedDist ~= distStr then
                                    widget.DistWidget:SetText(distStr)
                                    widget._cachedDist = distStr
                                end
                                widget.DistSlot:SetPosition(Vector2D(cx, bottom + 20.5))

                                -- Visibility (throttled)
                                if visCheck or ESP._VisCheckCache[pawnKey] == nil then
                                    local vis = pc.LineOfSightTo and pc:LineOfSightTo(pawn) or false
                                    ESP._VisCheckCache[pawnKey] = vis
                                end
                                local visible = ESP._VisCheckCache[pawnKey]

                                -- State (cached)
                                if heavyUpdate or widget._cachedState == "" then
                                    local isKnocked = readBool(pawn, "bIsKnocked", false)
                                        or readBool(pawn, "IsKnocked", false)

                                    local stateText, stateColor
                                    if isKnocked then
                                        stateText, stateColor = "Knocked", redSlateColor
                                    elseif not visible then
                                        stateText, stateColor = "Cover", redSlateColor
                                    else
                                        stateText, stateColor = "Open", greenSlateColor
                                    end

                                    if widget._cachedState ~= stateText then
                                        widget.StateWidget:SetText(stateText)
                                        safeSetColor(widget.StateWidget, stateColor)
                                        widget._cachedState = stateText
                                    end
                                end
                                widget.StateSlot:SetPosition(Vector2D(cx, bottom + 37.0))

                                -- Snap line
                                if _G.JINSHIFORYOUConfig.EspV3_Line then
                                    local lineColor = visible and greenColor or redColor
                                    esp_UpdateSnapLine(pawnKey, cx, top,
                                        snapX, snapY, lineColor, canvas)
                                else
                                    esp_HideSnapLine(pawnKey)
                                end
                            else
                                esp_HideWidget(widget)
                                esp_HideSnapLine(pawnKey)
                            end
                        end
                    end
                end
            end
        end

        -- Hide widgets for dead/removed pawns
        for key, w in pairs(ESP.BoxWidgets) do
            if not alive[key] then
                removeBox(w)
                ESP.BoxWidgets[key] = nil
                ESP._VisCheckCache[key] = nil
            end
        end
        for key, _ in pairs(ESP.LineWidgets) do
            if not alive[key] then
                removeWidget(ESP.LineWidgets[key].Widget)
                ESP.LineWidgets[key] = nil
                ESP._VisCheckCache[key] = nil
            end
        end

        -- Enemy counter
        local counterY = snapY - counterTextSize - 2
        if counterY < 10 then counterY = 48 end
        -- Dono icons ka total width = 130, isliye center se 65 left shift
        esp_UpdateEnemyCounterDisplay(playerCount, botCount, canvas, snapX - 65, counterY)
    end
    ESP.UpdateESP = esp_UpdateESP

    return ESP
end

return LoadESPV3System
end)()
local B = {Renderer=nil, Status=0, LastError=nil, Disposed=false, RetryAt=0}
local defaults = {
    EspV3_Master=false, EspV3_Count=true, EspV3_Box=true, EspV3_Line=true,
    EspV3_Health=true, EspV3_Name=true, EspV3_Dist=true, EspV3_Weapon=true,
    EspV3_Flag=true, EspV3_State=true,
}
local function boolean(v)
    if v==true or v==1 or v=='true' or v=='1' then return true end
    if v==false or v==0 or v=='false' or v=='0' then return false end
end
local function config()
    _G.JINSHIFORYOUConfig = _G.JINSHIFORYOUConfig or {}
    local c=_G.JINSHIFORYOUConfig
    for key,default in pairs(defaults) do
        local v=boolean(c[key]); if v==nil then v=default end; c[key]=v
    end
    return c
end
local function save() if _G.SaveModSettings then pcall(_G.SaveModSettings) end end
local notifier
local allowed=function() return true end
function B.SetAllowed(fn) allowed=fn end
function B.SetNotifier(fn) notifier=fn end
local function status(code)
    B.Status=code
    config().EspV3_RuntimeStatus=({[0]='OFF',[1]='WAITING',[2]='READY',[3]='ERROR',[4]='BLOCKED'})[code]
end
local function report(phase,message)
    message=phase..': '..tostring(message)
    config().EspV3_LastError=message
    config().EspV3_DiagnosticBuild='R4'
    local changed=B.LastError~=message
    B.LastError=message
    status(3)
    if changed then
        if print then print('[ESP V3 R4] '..message) end
        if notifier then pcall(notifier,'ESP V3 R4: '..message) end
        save() -- Exact error survives leaving the menu, even if notifications fail.
    end
end
local function clear()
    if B.Renderer and B.Renderer.ClearESP then
        local ok,err=pcall(B.Renderer.ClearESP)
        if not ok then report('cleanup',err) end
    end
end
function B.Stop()
    B.TimerGeneration=(B.TimerGeneration or 0)+1
    B.TimerPending=false
    clear(); status(0)
end
function B.Dispose() B.Disposed=true; B.Stop(); B.Renderer=nil end
function B.Get(key) return config()[key] end
function B.Update()
    if B.Disposed then return false end
    if not config().EspV3_Master then
        if B.Status~=0 then B.Stop() end
        return false
    end
    if not allowed() then
        clear(); status(4)
        return false
    end
    local now=os.clock()
    if now<B.RetryAt then return false end
    if not B.Renderer then
        local ok,renderer=pcall(initializeRenderer)
        if not ok or type(renderer)~='table' then
            B.RetryAt=now+3
            report('initialize',renderer or 'No renderer returned')
            return false
        end
        B.Renderer=renderer
    end
    local ok,err=pcall(B.Renderer.UpdateESP)
    if not ok then
        clear()
        B.RetryAt=now+3
        report('render',err)
        return false
    end
    status(B.Renderer.LocalPawn and 2 or 1)
    return true
end
-- Supervised by the already-working base loop; never starts native rendering in a menu callback.
function B.Pump()
    if B.Disposed then return false end
    if not config().EspV3_Master or not allowed() then
        if B.TimerPending then
            B.TimerGeneration=(B.TimerGeneration or 0)+1
            B.TimerPending=false
        end
        return B.Update()
    end
    local now=os.clock()
    if B.TimerPending and now-(B.LastTimerBeat or now)<1.0 then return true end
    -- A missing/stalled scheduler falls back to the base loop rather than killing V3.
    B.TimerGeneration=(B.TimerGeneration or 0)+1
    local generation=B.TimerGeneration
    B.TimerPending=false
    B.Update()
    local ok,ticker=pcall(require,'common.time_ticker')
    if not ok or not ticker or type(ticker.AddTimerOnce)~='function' then return false end
    local tick
    tick=function()
        if B.Disposed or B.TimerGeneration~=generation then return end
        B.TimerPending=false
        B.LastTimerBeat=os.clock()
        B.Update()
        if B.Disposed or not config().EspV3_Master or not allowed() then return end
        local scheduled=pcall(ticker.AddTimerOnce,0.016,tick)
        B.TimerPending=scheduled
    end
    B.LastTimerBeat=now
    local scheduled=pcall(ticker.AddTimerOnce,0.016,tick)
    B.TimerPending=scheduled
    return scheduled
end
function B.Start()
    if B.Disposed then return false end
    if config().EspV3_Master then status(1) end
    return true
end
function B.Set(key,value)
    if B.Disposed or defaults[key]==nil then return false end
    local normalized=boolean(value)
    if normalized==nil then report('menu','Unsupported value '..tostring(value)); return false end
    config()[key]=normalized
    if key=='EspV3_Master' then
        B.RetryAt=0
        if normalized then B.Start() else B.Stop() end
    elseif B.Renderer then
        local renderer=B.Renderer
        local ok,err=pcall(function()
            for _,widget in pairs(renderer.BoxWidgets) do
                if widget.bVisible then renderer.ShowWidget(widget) end
            end
            if key=='EspV3_Line' and not normalized then
                for actor in pairs(renderer.LineWidgets) do renderer.HideSnapLine(actor) end
            end
            if key=='EspV3_Count' and not normalized then
                -- The disabled branch hides existing counter widgets without creating any.
                renderer.UpdateEnemyCounterDisplay(0,0,nil,0,0)
            end
        end)
        if not ok then report('toggle visibility',err) end
    end
    save()
    return true -- accepted setting, not a claim of successful rendering
end
function B.OnEndPlay(character)
    local pawn=B.Renderer and B.Renderer.LocalPawn
    if pawn and (pawn==character or pawn==character.Object) then
        clear(); status(config().EspV3_Master and 1 or 0)
    end
end
local previous=_G.ESPV3Bridge
if previous and type(previous.Dispose)=='function' then pcall(previous.Dispose) end
_G.ESPV3Bridge=B
config().EspV3_DiagnosticBuild='R4'
status(config().EspV3_Master and 1 or 0)
return B

end)()
ESPV3Bridge.SetNotifier(function(msg)
    pcall(function()
        local _f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
        if _f then _f:write("espR4 " .. tostring(msg) .. string.char(10)) _f:close() end
    end)
end)

    _G._espV3Gen = 0
    _G.StartESPV3 = function()
        _G._espV3Gen = (_G._espV3Gen or 0) + 1
        local gen = _G._espV3Gen
        pcall(function()
            local function EspV3Tick()
                if gen ~= _G._espV3Gen then return end
                pcall(function()
                    local tt = require("common.time_ticker")
                    if tt and tt.AddTimerOnce then tt.AddTimerOnce(0.016, EspV3Tick) end
                end)
                if _G.ESPV3Bridge and _G.ESPV3Bridge.Pump then
                    local _ok, _err = pcall(_G.ESPV3Bridge.Pump)
                    if not _ok then
                        _G._espV3Err = (_G._espV3Err or 0) + 1
                        if _G._espV3Err <= 3 then
                            pcall(function()
                                local _f1 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
                                if _f1 then _f1:write("tickerr " .. tostring(_err) .. string.char(10)) _f1:close() end
                            end)
                        end
                    end
                end
            end
            local how = "none"
            local tt0 = nil
            pcall(function() tt0 = require("common.time_ticker") end)
            if tt0 and tt0.AddTimerOnce then
                tt0.AddTimerOnce(0.05, EspV3Tick)
                how = "tt"
                _G._espV3Timer = true
            elseif _G.Game and _G.Game.AddGameTimer then
                _G._espV3Timer = _G.Game:AddGameTimer(0.02, true, EspV3Tick)
            elseif slua_GameFrontendHUD then
                local pc = slua_GameFrontendHUD:GetPlayerController()
                if Valid(pc) and type(pc.AddGameTimer) == "function" then
                    _G._espV3Timer = pc:AddGameTimer(0.02, true, EspV3Tick)
                end
            end
            pcall(function()
                local _f2 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
                if _f2 then _f2:write("timer " .. tostring(how) .. string.char(10)) _f2:close() end
            end)
        end)
    end
    pcall(function() if _G.StartESPV3 then _G.StartESPV3() end end)

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = {
        "bCanSelfRescue"
      }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
    self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleOnAttachedToVehicle, self)
    self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleOnDetachedFromVehicle, self)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end
end

function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle)
  if not slua.isValid(uVehicle) then
    return
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:HandleOnAttachedToVehicle", Game:GetObjName(uVehicle)))
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
    self.nUpdatePlayerAttachToVehicleTimer = self:AddGameTimer(5, true, 
function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:UpdatePlayerAttachToVehicle(uVehicle)
      end
    end)
    self.nFixMeshContainerTimer = self:AddGameTimer(3, true, 
function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:FixMeshContainerOffsetIfNeeded(uVehicle)
      end
    end)
  end
end

function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle)
  if not slua.isValid(uLastVehicle) then
    return
  end
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnDetachedFromVehicle", uLastVehicle)
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:UpdatePlayerAttachToVehicle(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
    return
  end
  if not slua.isValid(self.CapsuleComponent) or not slua.isValid(self.Mesh) or not slua.isValid(self.MeshContainer) then
    return
  end
  if not slua.isValid(self:GetCurrentVehicle()) then
    return
  end
  if Game:IsDriver(self.Object) then
    return
  end
  if not self.nUpdatePlayerAttachToVehicleCount then
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
  local ESTEPoseState = import("ESTEPoseState")
  local bStand = self.PoseState == ESTEPoseState.Stand
  local uActorRelativeLocation = self.CapsuleComponent:GetRelativeTransform():GetLocation()
  local uMeshRelativeLocation = self.Mesh:GetRelativeTransform():GetLocation()
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  local nCapsuleRadius = self.CapsuleComponent:GetScaledCapsuleRadius()
  local nCapsuleHalfHeight = self.CapsuleComponent:GetScaledCapsuleHalfHeight()
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local nExpectedCapsuleRadius = self.StandRadius
  local nExpectedCapsuleHalfHeight = self.StandHalfHeight
  local uMeshExpectedRL = FVector(0, 0, 0)
  local uActorExpectedRL = FVector(0, 0, self.StandHalfHeight)
  local nTolerance = 1.0
  local bCapsuleRLCorrect = uActorRelativeLocation:Equals(uActorExpectedRL, nTolerance)
  local bMeshRLCorrect = uMeshRelativeLocation:Equals(uMeshExpectedRL, nTolerance)
  local bMeshContainerRLCorrect = nTolerance > math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ)
  local bCapsuleRadiusCorrect = nTolerance > math.abs(nCapsuleRadius - nExpectedCapsuleRadius)
  local bCapsuleHalfHeightCorrect = nTolerance > math.abs(nCapsuleHalfHeight - nExpectedCapsuleHalfHeight)
  local bAllCorrect = bStand and bCapsuleRLCorrect and bMeshRLCorrect and bMeshContainerRLCorrect and bCapsuleRadiusCorrect and bCapsuleHalfHeightCorrect
  if not bAllCorrect then
    self.nUpdatePlayerAttachToVehicleCount = self.nUpdatePlayerAttachToVehicleCount + 1
  else
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:UpdatePlayerAttachToVehicle PlayerKey:%s. bAllCorrect=%s Check Result:%d %d %d %d %d %d, Count:%d", tostring(self.PlayerKey), tostring(bAllCorrect), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, self.nUpdatePlayerAttachToVehicleCount))
  if self.nUpdatePlayerAttachToVehicleCount >= 3 and not bAllCorrect then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if uPlayerController.ReportCrashKitFeature and uPlayerController.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException then
      local sReportInfo = string.format("VehicleShapeType:%s PlayerKey:%s. Check Result:%d %d %d %d %d %d. Capsule.RelativeLoc:%s Capsule.Radius:%s Capsule.HalfHeight:%s Mesh.RelativeLoc:%s MeshContainer.RelativeLocZ:%s", tostring(uVehicle.VehicleShapeType), tostring(self.PlayerKey), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, uActorRelativeLocation:ToString(), tostring(nCapsuleRadius), tostring(nCapsuleHalfHeight), uMeshRelativeLocation:ToString(), tostring(uMeshContainerRelativeLocationZ))
      uPlayerController.ReportCrashKitFeature:ReportCharacterAttachedOnVehicleException(sReportInfo)
    end
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
    return
  end
  if not slua.isValid(self.MeshContainer) then
    return
  end
  if not slua.isValid(self:GetCurrentVehicle()) then
    return
  end
  if Game:IsDriver(self.Object) then
    return
  end
  local nTolerance = 1.0
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  if nTolerance <= math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ) then
    print(bWriteLog and string.format("BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded PlayerKey:%s. SetMeshContainerOffsetZ from:%s to:%s", tostring(uMeshContainerExpectedZ), tostring(uMeshContainerExpectedZ)))
    self:SetMeshContainerOffsetZ(uMeshContainerExpectedZ)
  end
end

function BRPlayerCharacterBase:ClearAttachToVehicleTimer()
  if self.nUpdatePlayerAttachToVehicleTimer then
    self:RemoveGameTimer(self.nUpdatePlayerAttachToVehicleTimer)
    self.nUpdatePlayerAttachToVehicleTimer = nil
  end
  if self.nFixMeshContainerTimer then
    self:RemoveGameTimer(self.nFixMeshContainerTimer)
    self.nFixMeshContainerTimer = nil
  end
end

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then
    return
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  local EPawnState = import("EPawnState")
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfig then
    self.STCharacterMovement:SetDynamicSimpleQueryConfig(false)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local EGameModeType = import("EGameModeType")
    local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  local EParachuteState = import("EParachuteState")
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData:GetGameState()
  local STExtraGameStateBase = import("STExtraGameStateBase")
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    local EGameModeType = import("EGameModeType")
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
    local vRelativeRot = self.Mesh.RelativeRotation
    local vBaseRotationOffset = self.BaseRotationOffset
    local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
    print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
  end
end

-- ================== HANDLE MOVEMENT (NO WALL CLIMB) ==================
function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  local EMovementMode = import("EMovementMode")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}

function BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment(Type, Param)
  print(bWriteLog and string.format("BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment Type = %d, Param = %s", Type, Param))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      local EStateType = import("EStateType")
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        local ESTEPoseState = import("ESTEPoseState")
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return false
  end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
  self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
  local uNearDeathComp = self.NearDeatchComponent
  if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1613, 1, false)
    end
    uNearDeathComp:TriggerGotoDieExplictly(self.Object)
  end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then
    return
  end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then
    return
  end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then
    return
  end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  local loadLater = function()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

-- ==============================================================================
-- ============================ START FULL LOGIC MOD ==========================
-- ==============================================================================

local function Notify(msg) local s = "[JINSHIFORYOU VIP New] " .. tostring(msg)
pcall(function() if _G.JINSHIFORYOUNotify then _G.JINSHIFORYOUNotify(s) end end)
pcall(function() local sh = import("ScriptHelperClient") if sh and
sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
_slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
then return false end end return true end

-- ========================================== 
-- STATIC VARIABLES & GLOBAL CACHE OPTIMIZED (LAG-FREE)
-- ========================================== 
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

-- ===== 7 COLORS TO CHOOSE FROM =====
local COLOR_PALETTE_7 = {
    [1] = {R=255, G=0,   B=0, A=255},   -- Red
    [2] = {R=255, G=255, B=255, A=255}, -- White
    [3] = {R=255, G=255, B=0, A=255},   -- Yellow
    [4] = {R=0,   G=255, B=0, A=255},   -- Green
    [5] = {R=0,   G=255, B=255, A=255}, -- Cyan
    [6] = {R=0,   G=0,   B=255, A=255}, -- Blue
    [7] = {R=255, G=0,   B=255, A=255}, -- Purple
}

local function GetColorBy7(idx)
    if not idx or idx < 1 or idx > 7 then idx = 4 end
    return COLOR_PALETTE_7[idx] or {R=0, G=255, B=0, A=255}
end

-- ESP Cache Variables
_G.CachedGameplayStatics = nil
_G.CachedActorClass_ForVehicle = nil
_G.CachedVehicleArray = nil
_G.CachedVehicles = nil
_G.LastVehicleScanTime = 0

_G.CachedActorClass_ForBomb = nil
_G.CachedProjArray = nil
_G.CachedActiveThrowables = nil
_G.CachedItemThrowables = nil
_G.LastThrowableScanTime = 0
_G.ActiveThrowableTimers = {}

_G.CachedActorClass_ForLoot = nil
_G.CachedLootArray = nil
_G.CachedLootItems = nil
_G.LastLootScanTime = 0

local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

-- ========================================== 
-- JINSHIFORYOU CORE + FULL FEATURES VIP CONFIGURATION 
-- ========================================== 
_G.JINSHIFORYOUConfig = _G.JINSHIFORYOUConfig or { 
    CustomMagicBullet = false,
    AutoHead = false, 
    EspVip = false, 
    EspDistance = false, 
    EspVipPro = false, 
    EspRadar = false, 
    Esp5 = false, 
    Esp6 = false, 
    Esp7 = false,
    Esp8 = false,
    EspAntenna = false, 
    EspName = false,
    EspV3_Master = true, EspV3_Count = true, EspV3_Box = true, EspV3_Line = true, EspV3_Health = true,
    EspV3_Name = true, EspV3_Dist = true, EspV3_Weapon = true, EspV3_Flag = true, EspV3_State = true,
    OutlineThickness = 10, 
    UnlockFPS = false, 
    IpadView = false, 
    -- === NEW FEATURES FROM GOLD ===
    IpadViewVehicle = false,
    IpadViewScope = false,
    CustomAimbot = false, 
    CustomAimbotClose = false, 
    CustomHRecoil = false,  
    CustomVRecoil = false,  
    LessShake = false, 
    RemoveGrass = false, 
    RemoveFog = false, 
    WhiteBody = false, 
    Wallhack = false, 
    Crosshair = false, 
    Accuracy = false,
    GodMode = false, 
    BlackSky = false,
    EspFovCircle = false,
    
    -- New Configuration for Aimbot V2 (Aim Touch)
    AimTouchEnable = false,
    AimTouchHipIgKnock = false,
    AimTouchHipIgBot = false,
    AimTouchSGIgKnock = false,
    AimTouchSGIgBot = false,
    AimTouchHipVisCheck = false,
    AimTouchSGVisCheck = false,
    AimTouchHipfire = false,
    AimTouchSG = false,
    AimTouchSGAutoFire = false,
    AimTouchScopeAll = false,
    AimTouchScopeIgKnock = false,
    AimTouchScopeIgBot = false,
    AimTouchScopeVisCheck = false,
    AimTouchScopeSniper = false,
    AimTouchSniperIgKnock = false,
    AimTouchSniperIgBot = false,
    AimTouchSniperVisCheck = false,
    -- === NEW AIMBOT MORTAR ===
    AimTouchMortar = false,
    
    -- ESP Vehicle
    VehicleEnabled = false,
    VehicleShowDacia = false,
    VehicleShowUAZ = false,
    VehicleShowBuggy = false,
    VehicleShowCoupe = false,
    VehicleShowMirado = false,
    VehicleShowMotor = false,
    VehicleShowOther = false,
    VehicleColor_Dacia = 4,
    VehicleColor_UAZ = 4,
    VehicleColor_Buggy = 4,
    VehicleColor_Coupe = 4,
    VehicleColor_Mirado = 4,
    VehicleColor_Motor = 4,
    VehicleColor_Other = 4,

    -- ESP Throwable
    ThrowableEnabled = false,
    ThrowableGrenade = false,
    ThrowableSmoke = false,
    ThrowableMolotov = false,
    ThrowableColor_Grenade = 4,
    ThrowableColor_Smoke = 4,
    ThrowableColor_Molotov = 4,
    ThrowableScanMode = 0,

    -- ESP Loot
    EspLoot = false,
    LootShowM416 = false,
    LootShowAUG = false,
    LootShowAKM = false,
    LootShowM24 = false,
    LootShowUMP = false,
    LootShowDBS = false,
    LootShowS12K = false,
    LootShowVest3 = false,
    LootShowHelmet3 = false,
    LootShowBag3 = false,
    LootColor_M416 = 4,
    LootColor_AUG = 4,
    LootColor_AKM = 4,
    LootColor_M24 = 4,
    LootColor_UMP = 4,
    LootColor_DBS = 4,
    LootColor_S12K = 4,
    LootColor_Vest3 = 4,
    LootColor_Helmet3 = 4,
    LootColor_Bag3 = 4,
    LootScanMode = 0,

    -- ESP Static
    EspStatic = false,
    EspEnemyCount = true,
    EspWeaponStatus = true,

    -- Skin Mod
    ModSkin = false,
    
    -- ===== TAMBAHAN EXPERT2 =====
    ExpertEnabled = false,
    EnableWeaponMod = false,
    WeaponMod = {
        [101001] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101004] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101008] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
    },
}

-- CONTAINS FULLY OPTIMIZED SYSTEM STATE WITH FREE RAM
_G.JINSHIFORYOUState = _G.JINSHIFORYOUState or { 
    LoopToken = 0, 
    AimbotLoopToken = 0,
    NativeESPReady = false,
    GraphicsUnlocked = false, 
    MenuStep = 0, 
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0, 
    CustomTextData = nil,     
    LastAimbotConfigString = "",
    MagicUpdateVersion = 1,
    LastMagicConfigHash = "",
    PrevGraphicsState = {},
    SkinWasApplied = false,
    ConsoleNewWallReady = false,
}

local limitTime = os.time({ year = 2026, month = 11, day = 30, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache"
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
    }
    
    if os and os.getenv then
        local homeDir = os.getenv("HOME")
        if homeDir and homeDir ~= "" then
            table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
            table.insert(paths, 2, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName)
        end
    end
    
    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then 
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then 
            currentTime = serverTime
        end
    end

    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        currentTime = lastSeenTime
    else
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = (currentTime > limitTime)

-- ========================================== 
-- MAP MARK CLEANUP MANAGEMENT FUNCTION (ANTI-LAG/FAKE DISPLAY WHEN ENEMY DIES)
-- ========================================== 
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.JINSHIFORYOUState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.JINSHIFORYOUState.TrackedMarks[mark] = nil
end

-- ========================================== 
-- CREATE A UNIQUE AND PERMANENT ID FOR EACH ENEMY (FIXED LAG ISSUES WHEN SLUA CREATES NEW WRAPPERS)
-- ==========================================
local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

-- ========================================== 
-- AI (BOT) / REAL PLAYER - OPTIMIZED TEST
-- ==========================================
local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end
        
        if not isAI then
            local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ========================================== 
-- INITIALIZES AUTO HEAD HOOKS FOR DAMAGE
-- ==========================================
function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end

        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.JINSHIFORYOUConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end

                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.JINSHIFORYOUConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

-- ========================================== 
-- COLOR CONFIGURATION FOR ESP HEALTH, ESP NAME, AND WALLHACK
-- ==========================================
if _G.ColorConfig == nil then
    _G.ColorConfig = {
        VisibleColor = 4,
        InvisibleColor = 1,
        Brightness = 25,
        Glow = 3.0,
    }
end

local COLOR_MAP = {
    [1] = {R=255, G=0,   B=0},
    [2] = {R=255, G=255, B=255},
    [3] = {R=255, G=255, B=0},
    [4] = {R=0,   G=255, B=0},
    [5] = {R=0,   G=255, B=255},
    [6] = {R=0,   G=0,   B=255},
    [7] = {R=255, G=0,   B=255}
}

local function GetAppliedColor(colorIdx, brightness)
    local base = COLOR_MAP[colorIdx] or COLOR_MAP[4]
    local b = brightness or _G.ColorConfig.Brightness or 25
    return {
        R = math.min(255, (base.R or 0) * b / 25),
        G = math.min(255, (base.G or 0) * b / 25),
        B = math.min(255, (base.B or 0) * b / 25),
        A = 255
    }
end

-- ========================================== 
-- AUTOMATIC VIP MENU STORAGE AND LOADING SYSTEM
-- ========================================== 
local function GetConfigPaths(fileName)
    local paths = {}
    
    local android_packages = {
        "com.tencent.ig",
        "com.pubg.krmobile",
        "com.vng.pubgmobile",
        "com.rekoo.pubgm",
        "com.pubg.imobile",
        "com.pubg.tw",
        "com.tencent.pubgm",
    }
    
    for _, pkg in ipairs(android_packages) do
        table.insert(paths, "//storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
        table.insert(paths, "//storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName)
    end
    
    if os and os.getenv then
        local home = os.getenv("HOME")
        if home and home ~= "" then
            table.insert(paths, home .. "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
            table.insert(paths, home .. "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName)
        end
    end
    
    table.insert(paths, "Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    table.insert(paths, "ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    table.insert(paths, "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    
    return paths
end

local ConfigFileName = "JINSHIFORYOU_settings.txt"
_G.LastConfigSaveStr = ""

_G.SaveModSettings = function()
    pcall(function()
        local function serializeTable(tbl, indent)
            indent = indent or ""
            local items = {}
            for k, v in pairs(tbl) do
                local keyStr
                if type(k) == "string" then
                    keyStr = string.format("[%q]", k)
                elseif type(k) == "number" then
                    keyStr = "[" .. tostring(k) .. "]"
                else
                    keyStr = "[" .. tostring(k) .. "]"
                end
                
                if type(v) == "table" then
                    table.insert(items, indent .. keyStr .. " = " .. serializeTable(v, indent .. "  "))
                elseif type(v) == "string" then
                    table.insert(items, indent .. keyStr .. " = " .. string.format("%q", v))
                elseif type(v) == "number" or type(v) == "boolean" then
                    table.insert(items, indent .. keyStr .. " = " .. tostring(v))
                else
                    table.insert(items, indent .. keyStr .. " = nil")
                end
            end
            return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent:sub(1, #indent-2) .. "}"
        end
        
        local data = "return {\nJINSHIFORYOUConfig = " .. serializeTable(_G.JINSHIFORYOUConfig or {}, "  ") .. ",\n"
        data = data .. "CustomTextData = " .. serializeTable(_G.JINSHIFORYOUState.CustomTextData or {}, "  ") .. ",\n"
        data = data .. "ColorConfig = " .. serializeTable(_G.ColorConfig or {}, "  ") .. "\n}"
        
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end

        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.JINSHIFORYOUConfig then
                        for k, v in pairs(savedData.JINSHIFORYOUConfig) do
                            _G.JINSHIFORYOUConfig[k] = v
                        end
                    end
                    if savedData.CustomTextData then
                        _G.JINSHIFORYOUState.CustomTextData = _G.JINSHIFORYOUState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do
                            _G.JINSHIFORYOUState.CustomTextData[k] = v
                        end
                    end
                    if savedData.ColorConfig then
                        for k, v in pairs(savedData.ColorConfig) do
                            _G.ColorConfig[k] = v
                        end
                    end
                end
            end
        end
    end)
end

local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerOnce then 
            ticker.AddTimerOnce(3.0, AutoSaveLoop)
        end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ========================================== 
-- SKIN MOD SYSTEM (FULL LUCI VERSION + KILL COUNTER)
-- ==========================================
_G.VIP_Attachments = {
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0}
}

_G.BaseAttachToIndex = {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2, 
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4, 
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6, 
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13, 
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19, 
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22 
}

_G.VipAttachToIndex = {}
for skinId, attachList in pairs(_G.VIP_Attachments) do
    for index, attachId in ipairs(attachList) do
        if attachId > 0 then
            _G.VipAttachToIndex[attachId] = index
        end
    end
end

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.skinIdCache = _G.skinIdCache or {}
_G.skinIdCache2 = _G.skinIdCache2 or {}

_G.OutfitSkins = {
    Suit = {1407994,1408021,1407906,1407453,1406388,1406387,1406386,1407142,1407550,1406638,1406872,1406971,1407103,1407512,1407391,1407285,1407330,1407329,1407286,1407285,1407277,1407276,1407275,1407225,1407224,1407259,1407161,1407160,1407107,1407106,1407079,1407048,1406977,1406976,1406898,1400569,1404000,1404049,1400119,1400117,1406060,1406891,1400687,1405160,1405145,1405436,1405435,1405434,1405064,1405207,1406398,1407812,1405132,1407856,1405121,1406889,1407278,1407279,1407381,1407380,1407916,1406469,1405870,1407140,1407141,1406385,1406140,1400782,1407392,1407318,1407317,1407404,1407402,1407401,1407387,1404434,1404437,1404440,1404448,1400324,1400708,1404043,1404048,1405953,1400101,1404153,1407440,1407441,1407522,1405069,1405355},
    Bag = {
        {501001, 501002, 501003}, {1501001174, 1501002174, 1501003174}, {1501001220, 1501002220, 1501003220},
        {1501001051, 1501002051, 1501003051}, {1501001443, 1501002443, 1501003443}, {1501001265, 1501002265, 1501003265},
        {1501001321, 1501002321, 1501003321}, {1501001277, 1501002277, 1501003277}, {1501001550, 1501002550, 1501003550},
        {1501001592, 1501002592, 1501003592}, {1501001608, 1501002608, 1501003608}, {1501001024, 1501002024, 1501003024},
        {1501001019, 1501002019, 1501003019}, {1501001179, 1501002179, 1501003179}, {1501001194, 1501002194, 1501003194},
        {1501001346, 1501002346, 1501003346}, {1501001057, 1501002057, 1501003057}, {1501001229, 1501002229, 1501003229},
        {1501001022, 1501002022, 1501003022}, {1501001022, 1501002022, 1501003022}
    },
    Helmet = {
        {502001, 502002, 502003}, {1502001014, 1502002014, 1502003014}, {1502001349, 1502002349, 1502003349},
        {1502001012, 1502002012, 1502003012}, {1502001009, 1502002009, 1502003009}, {1502001397, 1502002397, 1502003397},
        {1502001390, 1502002390, 1502003390}, {1502001381, 1502002381, 1502003381}, {1502001358, 1502002358, 1502003358},
        {1502001350, 1502002350, 1502003350}, {1502001342, 1502002342, 1502003342}, {1502001058, 1502002058, 1502003058},
        {1502001031, 1502002031, 1502003031}, {1502001054, 1502002054, 1502003054}
    },
    Pet = {50000,50001,50002,50003,50004,50005,50006,50021,50022,50038,50039,50040},
    
    -- ========== GLIDER + PARACHUTE ==========
    Glider = {41511, 4151145},
    Parachute = {14011, 1401107},
    Gloves = {4520, 452001, 452002, 452003},
}

_G.skinIdMappings = {
    [101004] = {101004, 1101004246,1101004209,1101004226,1101004236,1101004062,1101004078,1101004086,1101004201,1101004218,1101004046},
    [101001] = {101001,1101001276,1101001265,1101001213,1101001172,1101001127,1101001230,1101001241},
    [101003] = {101003,1101003227,1103003208,1101003195,1101003187,1101003098,1101003166,1101003218},
    [101008] = {101008,1101008146,1101008154,1101008079,1101008126,1101008104,1101008146,1101008061,1101008116},
    [101006] = {101006,1101006106,1101006098,1101006085,1101006061,1101006074,1101006043,1101006032,1101006084},
    [101012] = {101012,1101012033},
    [101007] = {101007,1101007062,1101007071},
    [102002] = {102002,1102002136,1102002043,1102002061,1102002424,1102002438},
    [101101] = {101101, 1101101007},
    [101102] = {101102, 1101102041},
    [102001] = {102001, 1102001120},
    [102003] = {102003, 1102003100},
    [101005] = {101005, 1101005098},
    [103001] = {103001, 1103001202,1103001191},
    [103002] = {103002, 1103002106},
    [103003] = {103003, 1103003042,1103003062,1103003099},
    [103012] = {103012, 1103012039,1103012010},
    [104003] = {104003, 1104003037},
    [102005] = {102005, 1102005064},
    [104004] = {104004, 1104004035, 1104004041}
}

_G.VehicleSkins = { 
    [1961001] = { 1961007, 1961149, 1961069, 1961013, 1961014, 1961015, 1961016, 1961017, 1961018, 1961020, 1961021, 1961024, 1961025, 1961029, 1961030, 1961031, 1961032, 1961033, 1961034, 1961035, 1961036, 1961037, 1961038, 1961039, 1961040, 1961041, 1961042, 1961043, 1961044, 1961045, 1961046, 1961047, 1961048, 1961049, 1961050, 1961051, 1961052, 1961053, 1961054, 1961055, 1961056, 1961057, 1961058, 1961059, 1961060, 1961061, 1961062, 1961063, 1961064, 1961065, 1961066, 1961067, 1961068,1961136, 1961137, 1961138, 1961139, 1961140, 1961141, 1961142, 1961143, 1961144, 1961145, 1961147, 1961148, 1961010, 1961150, 1961151, 1961152, 1961153 },
    [1903001] = { 1903005, 1903006, 1903007, 1903008, 1903011, 1903012, 1903013, 1903014, 1903015, 1903016, 1903017, 1903018, 1903019, 1903020, 1903021, 1903022, 1903023, 1903024, 1903029, 1903030, 1903031, 1903032, 1903033, 1903034, 1903035, 1903036, 1903037, 1903039, 1903040, 1903041, 1903042, 1903043, 1903044, 1903045, 1903046, 1903051, 1903052, 1903053, 1903054, 1903055, 1903056, 1903057, 1903058, 1903059, 1903060, 1903061, 1903062, 1903063, 1903066, 1903067, 1903068, 1903069, 1903070, 1903071, 1903072, 1903073, 1903074, 1903075, 1903076, 1903079, 1903080, 1903081, 1903082, 1903084, 1903085, 1903086, 1903087, 1903088, 1903089, 1903090, 1903189, 1903190, 1903191, 1903192, 1903193, 1903194, 1903195, 1903196, 1903197, 1903198, 1903199, 1903200, 1903201, 1903202, 1903203, 1903204, 1903205, 1903206, 1903207, 1903208, 1903209, 1903210, 1903211, 1903212, 1903213, 1903214, 1903215, 1903216, 1903217, 1903218, 1903219, 1903220, 1903221, 1903222, 1903223, 1903225, 1903226, 1903227, 1903228 }, 
    [1915001] = { 1915002, 1915003, 1915007, 1915005, 1915006, 1915008, 1915009, 1915010, 1915011, 1915012, 1915013, 1915014, 1915015, 1915016, 1915017, 1915018, 1915019, 1915020, 1915021, 1915022, 1915023, 1915024, 1915025, 1915026, 1915027, 1915099 },          
    [1908001] = { 1908002, 1908003, 1908094, 1908006, 1908007, 1908008, 1908009, 1908010, 1908011, 1908012, 1908013, 1908015, 1908016, 1908017, 1908018, 1908019, 1908021, 1908023, 1908030, 1908031, 1908032, 1908033, 1908034, 1908035, 1908036, 1908037, 1908039, 1908040, 1908041, 1908043, 1908047, 1908049, 1908050, 1908051, 1908052, 1908053, 1908054, 1908055, 1908056, 1908057, 1908059, 1908060, 1908061, 1908062, 1908063, 1908064, 1908066, 1908067, 1908068, 1908069, 1908070, 1908075, 1908076, 1908077, 1908078, 1908080, 1908081, 1908082, 1908083, 1908084, 1908085, 1908086, 1908087, 1908088, 1908089, 1908091, 1908095, 1908096, 1908097, 1908098, 1908099, 1908100, 1908101, 1908102, 1908104, 1908105, 1908106, 1908107, 1908108, 1908109, 1908110, 1908111, 1908112, 1908188, 1908189 },   
    [1907001] = { 1907007, 1907008, 1907010, 1907011, 1907012, 1907013, 1907014, 1907016, 1907018, 1907019, 1907021, 1907022, 1907023, 1907025, 1907026, 1907027, 1907028, 1907029, 1907030, 1907032, 1907033, 1907034, 1907035, 1907036, 1907037, 1907038, 1907040, 1907041, 1907043, 1907044, 1907045, 1907046, 1907047, 1907048, 1907049, 1907050, 1907051, 1907052, 1907053, 1907054, 1907055, 1907056, 1907058, 1907059, 1907060, 1907061, 1907062, 1907063, 1907064, 1907065, 1907066, 1907067, 1907068, 1907069, 1907070, 1907071, 1907072, 1907073, 1907074 }
}
_G.CustSlotType = { ClothesEquipemtSlot=5, BackpackEquipemtSlot=8, HelmetEquipemtSlot=9, ParachuteEquipemtSlot=11, GlideEquipemtSlot=15 }

local function DownloadGameItem(id)
    local puffer_manager = require('client.slua.logic.download.puffer.puffer_manager')
    local puffer_const = require('client.slua.logic.download.puffer_const')
    if puffer_manager and puffer_const and puffer_manager.GetState(puffer_const.ENUM_DownloadType.ODPTD, {id}) ~= puffer_const.ENUM_DownloadState.Done then
        puffer_manager.Download(puffer_const.ENUM_DownloadType.ODPTD, {id})
    end
end
_G.download_item = DownloadGameItem

_G.get_skin_id = function(weaponID)
    if not weaponID then return nil end
    local targetSkinId = _G.WeaponSkinMap and _G.WeaponSkinMap[weaponID]
    if targetSkinId and targetSkinId > 0 then
        if not _G.skinIdCache2[targetSkinId] then
            if _G.download_item then pcall(_G.download_item, targetSkinId) end
            _G.skinIdCache2[targetSkinId] = true
        end
        return targetSkinId
    end
    return weaponID
end

_G.equip_character_avatar = function(Character)
    if not Character or not slua.isValid(Character) or not Character.AvatarComponent2 then return end
    local BackpackUtils = import("BackpackUtils")
    local SlotSyncData = Character.AvatarComponent2.NetAvatarData and Character.AvatarComponent2.NetAvatarData.SlotSyncData
    if not SlotSyncData or not slua.isValid(SlotSyncData) or not BackpackUtils then return end
    
    local function EquipAvatar(ApplyDataIdx, mappedSkin, ApplyEquipSlot, isLevelDependent, levelFunc)
        if not mappedSkin or mappedSkin == 0 then return end
        local slotData = SlotSyncData:Get(ApplyDataIdx)
        if slotData and slotData.SlotID == ApplyEquipSlot then
            local applyItemId = mappedSkin
            if isLevelDependent and type(mappedSkin) == "table" then
                local level = levelFunc(slotData.AdditionalItemID) or 1
                if level < 1 then level = 1 end
                if level > 3 then level = 3 end
                applyItemId = mappedSkin[level] or mappedSkin[1]
            end
            if not applyItemId or applyItemId == 0 or slotData.ItemId == applyItemId then return end
            if not _G.skinIdCache[applyItemId] then
                if _G.download_item then pcall(_G.download_item, applyItemId) end
                _G.skinIdCache[applyItemId] = true
            end
            slotData.ItemId = applyItemId
            SlotSyncData:Set(ApplyDataIdx, slotData)
            Character.AvatarComponent2:OnRep_BodySlotStateChanged()
        end
    end

    -- Check existing slots
    local hasGliderSlot = false
    local hasParachuteSlot = false
    for i = 0, SlotSyncData:Num() - 1 do
        local slotData = SlotSyncData:Get(i)
        if slotData then
            if slotData.SlotID == _G.CustSlotType.GlideEquipemtSlot then hasGliderSlot = true end
            if slotData.SlotID == _G.CustSlotType.ParachuteEquipemtSlot then hasParachuteSlot = true end
        end
    end
    if not hasGliderSlot then 
        SlotSyncData:Add({ SlotID = _G.CustSlotType.GlideEquipemtSlot, ItemId = 0 }) 
    end
    if not hasParachuteSlot then 
        SlotSyncData:Add({ SlotID = _G.CustSlotType.ParachuteEquipemtSlot, ItemId = 0 }) 
    end

    for i = 0, SlotSyncData:Num() - 1 do
        EquipAvatar(i, _G.OutfitMap.Suit or 0, _G.CustSlotType.ClothesEquipemtSlot, false)
        EquipAvatar(i, _G.OutfitMap.Bag, _G.CustSlotType.BackpackEquipemtSlot, true, BackpackUtils.GetEquipmentBagLevel)
        EquipAvatar(i, _G.OutfitMap.Helmet, _G.CustSlotType.HelmetEquipemtSlot, true, BackpackUtils.GetEquipmentHelmetLevel)
        EquipAvatar(i, _G.OutfitMap.Parachute or 0, _G.CustSlotType.ParachuteEquipemtSlot, false)
        EquipAvatar(i, _G.OutfitMap.Glider or 0, _G.CustSlotType.GlideEquipemtSlot, false)
        
        -- ========== ADD THIS FOR GLOVES ==========
        EquipAvatar(i, _G.OutfitMap.Gloves or 0, 6, false)  -- Slot 6 for Gloves
    end
end

_G.ApplyWeaponSkins = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end
        
        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) and slua.isValid(Weapon.synData) then
                local WeaponID = Weapon:GetWeaponID()
                local SkinID = _G.get_skin_id(WeaponID) or WeaponID
                local isModified = false
                
                local SkinData = Weapon.synData:Get(7) 
                if SkinData and SkinData.defineID and SkinData.defineID.TypeSpecificID ~= SkinID then
                    SkinData.defineID.TypeSpecificID = SkinID
                    Weapon.synData:Set(7, SkinData)
                    if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(SkinID) end) end
                    if not _G.skinIdCache[SkinID] then 
                        _G.download_item(SkinID)
                        _G.skinIdCache[SkinID] = true 
                    end
                    isModified = true
                end
                
                if SkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[SkinID] then
                    for AttachIdx = 0, 5 do 
                        local attachData = Weapon.synData:Get(AttachIdx)
                        if attachData then
                            local defineIDRef = slua.IndexReference(attachData, "defineID")
                            if defineIDRef then
                                local attachmentId = defineIDRef.TypeSpecificID
                                if attachmentId and attachmentId > 0 then
                                    local mapIndex = _G.BaseAttachToIndex[attachmentId] or _G.VipAttachToIndex[attachmentId]
                                    if mapIndex and _G.VIP_Attachments[SkinID][mapIndex] and _G.VIP_Attachments[SkinID][mapIndex] > 0 then
                                        local targetAttachId = _G.VIP_Attachments[SkinID][mapIndex]
                                        if targetAttachId ~= attachmentId then
                                            attachData.defineID.TypeSpecificID = targetAttachId
                                            Weapon.synData:Set(AttachIdx, attachData)
                                            if not _G.skinIdCache2[targetAttachId] then 
                                                if _G.download_item then pcall(_G.download_item, targetAttachId) end
                                                _G.skinIdCache2[targetAttachId] = true 
                                            end
                                            isModified = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if isModified then
                    if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                    if Weapon.OnRep_synData then pcall(function() Weapon:OnRep_synData() end) end
                end
            end
        end
    end)
end

_G.ApplyVehicleSkins = function(PlayerCharacter)
    pcall(function()
        local Vehicle = PlayerCharacter:GetCurrentVehicle()
        if not slua.isValid(Vehicle) then 
            _G.LastVehicleEntity = nil
            return 
        end
        
        if _G.LastVehicleEntity == Vehicle and _G.CurrentEquipVehicleID ~= nil then
            return
        end

        local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
        if not slua.isValid(VehicleAvatar) then return end

        local defId = tostring(VehicleAvatar:GetDefaultAvatarID() or Vehicle.VehicleID or "")
        local currentId = tostring(Vehicle:GetAvatarId() or "")
        local applySkinId = 0
        
        for baseMapId, targetSkin in pairs(_G.VehicleSkinMap) do
            if defId:find(tostring(baseMapId)) or currentId:find(tostring(baseMapId)) then 
                applySkinId = targetSkin
                break 
            end
        end

        if applySkinId and applySkinId > 0 then
            _G.skinIdCache = _G.skinIdCache or {}
            if not _G.skinIdCache[applySkinId] then 
                if _G.download_item then pcall(_G.download_item, applySkinId) end
                _G.skinIdCache[applySkinId] = true 
            end

            VehicleAvatar.curSwitchEffectId = 7303001
            if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(applySkinId, true) end
            
            _G.CurrentEquipVehicleID = applySkinId
            _G.LastVehicleEntity = Vehicle
        end
    end)
end

_G.ApplyWeaponMod = function(weapon)
    if not _G.JINSHIFORYOUConfig.EnableWeaponMod then return end
    if not Valid(weapon) then return end
    
    pcall(function()
        local wid = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
        local cfg = _G.JINSHIFORYOUConfig.WeaponMod[wid]
        if not cfg then return end
        
        local shootComp = weapon.ShootWeaponEntityComp or weapon.ShootWeaponEntity or weapon
        if not Valid(shootComp) then return end
        
        if cfg.FireSpeed then
            if shootComp.ShootInterval then shootComp.ShootInterval = 0.07 end
            if shootComp.FireRate then shootComp.FireRate = 0.07 end
        end
        if cfg.InstanHit then
            if shootComp.BulletFireSpeed then shootComp.BulletFireSpeed = 150000 end
        end
        if cfg.FastSwitch then
            if shootComp.SwitchFromIdleToBackpackTime then shootComp.SwitchFromIdleToBackpackTime = 0 end
            if shootComp.SwitchFromBackpackToIdleTime then shootComp.SwitchFromBackpackToIdleTime = 0 end
        end
        if cfg.FastScope then
            if shootComp.WeaponAimInTime then shootComp.WeaponAimInTime = 7 end
        end
    end)
end

_G.HandlePetLogic = function()
    pcall(function()
        local petSkin = _G.OutfitMap.Pet
        if not petSkin or petSkin == 0 or petSkin == 50000 or petSkin == _G.LastAppliedPet then return end
        
        _G.skinIdCache = _G.skinIdCache or {}
        if not _G.skinIdCache[petSkin] then 
            if _G.download_item then pcall(_G.download_item, petSkin) end
            _G.skinIdCache[petSkin] = true 
        end
        
        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager then
            local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
            if logic_pet then
                if logic_pet.SetCurPetID then logic_pet:SetCurPetID(petSkin) end
                if logic_pet.EquipPet then logic_pet:EquipPet(petSkin) end
            end
        end
        _G.LastAppliedPet = petSkin
    end)
end

_G.ForceRefreshSkinMaps = function()
    pcall(function()
        if not _G.JINSHIFORYOUState or not _G.JINSHIFORYOUState.CustomTextData then return end
        local cData = _G.JINSHIFORYOUState.CustomTextData

        if _G.OutfitSkins then
            if cData.SkinSuit and _G.OutfitSkins.Suit[cData.SkinSuit] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[cData.SkinSuit] end
            if cData.SkinBag and _G.OutfitSkins.Bag[cData.SkinBag] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[cData.SkinBag] end
            if cData.SkinHelmet and _G.OutfitSkins.Helmet[cData.SkinHelmet] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[cData.SkinHelmet] end
            if cData.SkinGloves and _G.OutfitSkins.Gloves and _G.OutfitSkins.Gloves[cData.SkinGloves] then 
                _G.OutfitMap.Gloves = _G.OutfitSkins.Gloves[cData.SkinGloves] end
        end

        if _G.skinIdMappings then
            if cData.SkinM416 and _G.skinIdMappings[101004] and _G.skinIdMappings[101004][cData.SkinM416] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][cData.SkinM416] end
            if cData.SkinAKM and _G.skinIdMappings[101001] and _G.skinIdMappings[101001][cData.SkinAKM] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][cData.SkinAKM] end
            if cData.SkinSCAR and _G.skinIdMappings[101003] and _G.skinIdMappings[101003][cData.SkinSCAR] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][cData.SkinSCAR] end
            if cData.SkinM762 and _G.skinIdMappings[101008] and _G.skinIdMappings[101008][cData.SkinM762] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][cData.SkinM762] end
            if cData.SkinAUG and _G.skinIdMappings[101006] and _G.skinIdMappings[101006][cData.SkinAUG] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][cData.SkinAUG] end
            if cData.SkinHoney and _G.skinIdMappings[101012] and _G.skinIdMappings[101012][cData.SkinHoney] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][cData.SkinHoney] end
            if cData.SkinQBZ and _G.skinIdMappings[101007] and _G.skinIdMappings[101007][cData.SkinQBZ] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][cData.SkinQBZ] end
            if cData.SkinASM and _G.skinIdMappings[101101] and _G.skinIdMappings[101101][cData.SkinASM] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][cData.SkinASM] end
            if cData.SkinACE32 and _G.skinIdMappings[101102] and _G.skinIdMappings[101102][cData.SkinACE32] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][cData.SkinACE32] end
            if cData.SkinUMP and _G.skinIdMappings[102002] and _G.skinIdMappings[102002][cData.SkinUMP] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][cData.SkinUMP] end
            if cData.SkinUZI and _G.skinIdMappings[102001] and _G.skinIdMappings[102001][cData.SkinUZI] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][cData.SkinUZI] end
            if cData.SkinVector and _G.skinIdMappings[102003] and _G.skinIdMappings[102003][cData.SkinVector] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][cData.SkinVector] end
            if cData.SkinBIZON and _G.skinIdMappings[102005] and _G.skinIdMappings[102005][cData.SkinBIZON] then 
                _G.WeaponSkinMap[102005] = _G.skinIdMappings[102005][cData.SkinBIZON] end
            if cData.SkinGroza and _G.skinIdMappings[101005] and _G.skinIdMappings[101005][cData.SkinGroza] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][cData.SkinGroza] end
            if cData.SkinKar98K and _G.skinIdMappings[103001] and _G.skinIdMappings[103001][cData.SkinKar98K] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][cData.SkinKar98K] end
            if cData.SkinM24 and _G.skinIdMappings[103002] and _G.skinIdMappings[103002][cData.SkinM24] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][cData.SkinM24] end
            if cData.SkinAWM and _G.skinIdMappings[103003] and _G.skinIdMappings[103003][cData.SkinAWM] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][cData.SkinAWM] end
            if cData.SkinAMR and _G.skinIdMappings[103012] and _G.skinIdMappings[103012][cData.SkinAMR] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][cData.SkinAMR] end
            if cData.SkinS12K and _G.skinIdMappings[104003] and _G.skinIdMappings[104003][cData.SkinS12K] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][cData.SkinS12K] end
            if cData.SkinDBS and _G.skinIdMappings[104004] and _G.skinIdMappings[104004][cData.SkinDBS] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][cData.SkinDBS] end
        end

        if _G.VehicleSkins then
            if cData.SkinDacia and _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][cData.SkinDacia] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][cData.SkinDacia] end
            if cData.SkinUAZ and _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][cData.SkinUAZ] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][cData.SkinUAZ] end
            if cData.SkinCoupe and _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][cData.SkinCoupe] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][cData.SkinCoupe] end
            if cData.SkinBuggy and _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][cData.SkinBuggy] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][cData.SkinBuggy] end
            if cData.SkinMirado and _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][cData.SkinMirado] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][cData.SkinMirado] end
            if cData.SkinParachute and _G.ParachuteSkins and _G.ParachuteSkins[14011] and _G.ParachuteSkins[14011][cData.SkinParachute] then 
                _G.OutfitMap.Parachute = _G.ParachuteSkins[14011][cData.SkinParachute] end
            if cData.SkinGlider and _G.GliderSkins and _G.GliderSkins[41511] and _G.GliderSkins[41511][cData.SkinGlider] then 
                _G.OutfitMap.Glider = _G.GliderSkins[41511][cData.SkinGlider] end
        end
    end)
end

_G.InitializeSkinModSystem = function()
    pcall(function()
        local LobbyAvatar = package.loaded["client.logic.avatar.LobbyAvatar"] or require("client.logic.avatar.LobbyAvatar")
        if LobbyAvatar and not _G.LobbyBypassHacked then
            local originalPutonEquipment = LobbyAvatar.PutonEquipment
            LobbyAvatar.PutonEquipment = function(self, itemID, tAvatarCustom, tExtraData)
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[itemID]
                if attachIndex then
                    local holdingWeaponSkinID = self.GetCurHoldingWeaponSkinID and self:GetCurHoldingWeaponSkinID()
                    if holdingWeaponSkinID and holdingWeaponSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[holdingWeaponSkinID] then
                        local vipAttachID = _G.VIP_Attachments[holdingWeaponSkinID][attachIndex]
                        if vipAttachID and vipAttachID > 0 then
                            if self.HandleDownload then self:HandleDownload(vipAttachID, nil, nil, false) end
                            itemID = vipAttachID
                        end
                    end
                end
                if originalPutonEquipment then return originalPutonEquipment(self, itemID, tAvatarCustom, tExtraData) end
            end

            local originalCharEquipWeaponByResId = LobbyAvatar.CharEquipWeaponByResId
            LobbyAvatar.CharEquipWeaponByResId = function(self, resID, isUse, isAsync, SocketName)
                local retValue = originalCharEquipWeaponByResId and originalCharEquipWeaponByResId(self, resID, isUse, isAsync, SocketName) or nil
                if isUse and self.GetEquipments then
                    local equipments = self:GetEquipments()
                    for _, equip in ipairs(equipments) do
                        if _G.BaseAttachToIndex and _G.BaseAttachToIndex[equip.itemID] then
                            self:PutonEquipment(equip.itemID, equip.CustomInfo, {bIsUse = false})
                        end
                    end
                end
                return retValue
            end
            _G.LobbyBypassHacked = true
        end
    end)
    
    pcall(function()
        local Common_Items_UIBP = package.loaded["client.slua.component.item.ItemChildren.Common_Items_UIBP"] or require("client.slua.component.item.ItemChildren.Common_Items_UIBP")
        if Common_Items_UIBP and not _G.IconBaloHacked then
            local originalInitView = Common_Items_UIBP.InitView
            Common_Items_UIBP.InitView = function(self, nItemId, nCount, nValidTime, tExtraData)
                tExtraData = tExtraData or {}
                local displayResId = nil
                
                if _G.get_skin_id then
                    local skinID = _G.get_skin_id(nItemId)
                    if skinID and skinID ~= nItemId then displayResId = skinID end
                end
                
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[nItemId]
                if not displayResId and attachIndex then
                    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
                    local LocalPlayer = GameplayData and GameplayData.GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) then
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local finalSkinID = _G.get_skin_id(weaponID) or weaponID
                            if finalSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[finalSkinID] then
                                local vipAttachID = _G.VIP_Attachments[finalSkinID][attachIndex]
                                if vipAttachID and vipAttachID > 0 then displayResId = vipAttachID end
                            end
                        end
                    end
                end
                
                if displayResId then
                    tExtraData.displayResId = displayResId
                    if not _G.skinIdCache2[displayResId] then
                        if _G.download_item then pcall(_G.download_item, displayResId) end
                        _G.skinIdCache2[displayResId] = true
                    end
                end
                if originalInitView then return originalInitView(self, nItemId, nCount, nValidTime, tExtraData) end
            end
            _G.IconBaloHacked = true
        end
    end)
end

-- ========================================== 
-- KILL COUNTER & KILL MESSAGE EFFECT + DEADBOX SKIN
-- ==========================================
_G.TDFTDeKillCounts = _G.TDFTDeKillCounts or {}
local CACHED_LinearColor = import("LinearColor")
local CACHED_GoldColor = CACHED_LinearColor and CACHED_LinearColor(1.0, 0.8, 0.0, 1.0) or nil
local CACHED_UI_Manager = nil
_G.NeedCheckDeadBoxTimer = 0
_G.LastCheckDeadBoxTime = 0

_G.ForceEnableKillCounterUI = function()
    pcall(function()
        local KillCounterUISubsystem = package.loaded["GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem"] or require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
        if KillCounterUISubsystem and KillCounterUISubsystem.__inner_impl and not _G.KCUISystemHacked2 then
            local kcImpl = KillCounterUISubsystem.__inner_impl
            kcImpl.CheckSupportKCUI = function() return true end
            kcImpl.CheckNeedMainKillCounterUI = function(self, PlayerWeapon, PlayerID)
                if slua.isValid(PlayerWeapon) then
                    local WeaponID = PlayerWeapon:GetWeaponID()
                    self:UpdateMainKillCounterUI(true, WeaponID, _G.get_skin_id(WeaponID) or WeaponID)
                else self:UpdateMainKillCounterUI(false) end
            end
            local originalUpdateMainKillCounterUI = kcImpl.UpdateMainKillCounterUI
            kcImpl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
                if bShow then AvatarID = _G.get_skin_id(WeaponID) or AvatarID end
                if originalUpdateMainKillCounterUI then originalUpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID) end
            end
            _G.KCUISystemHacked2 = true
        end

        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager and not _G.KCLogicHacked2 then
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            if LogicKillCounter then
                LogicKillCounter.CheckSupportKC = function() return true end
                LogicKillCounter.CheckSupportKillCounterAvatar = function() return true end
                LogicKillCounter.CheckHasWeaponKillCounter = function() return true end
                LogicKillCounter.GetBaseKillCounterIdByWeaponId = function() return 2100004 end
                LogicKillCounter.GetEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetMyEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetOneWeaponKillCountInBattle = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                LogicKillCounter.GetWeaponKillCountByUid = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                _G.KCLogicHacked2 = true
            end
        end

        local killInfoPath = "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo"
        local KillInfo = package.loaded[killInfoPath] or require(killInfoPath)
        
        if KillInfo and KillInfo.__inner_impl and not _G.KillInfoCounterHacked then
            local originalFileItem = KillInfo.__inner_impl.FileItem
            KillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
                pcall(function()
                    local LocalPlayer = require("GameLua.GameCore.Data.GameplayData").GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) and DamageRecordData.Causer == LocalPlayer:GetPlayerNameSafety() then 
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local skinID = _G.get_skin_id(weaponID)
                            if skinID then DamageRecordData.CauserWeaponAvatarID = skinID end
                            if _G.OutfitMap.Suit and _G.OutfitMap.Suit ~= 0 then DamageRecordData.CauserClothAvatarID = _G.OutfitMap.Suit end
                            
                            if CACHED_GoldColor then
                                DamageRecordData.IsUseColor, DamageRecordData.UseColor = true, CACHED_GoldColor
                            end
                            
                            if DamageRecordData.ResultHealthStatus == 2 then
                                _G.TDFTDeKillCounts[weaponID] = (_G.TDFTDeKillCounts[weaponID] or 0) + 1
                                _G.NeedCheckDeadBoxTimer = 50 
                                
                                if not CACHED_UI_Manager then CACHED_UI_Manager = require("client.slua_ui_framework.manager") end
                                local uiMainKillCounter = CACHED_UI_Manager.GetUI(CACHED_UI_Manager.UI_Config_InGame.MainKillCounter)
                                
                                if uiMainKillCounter and uiMainKillCounter.UpdateWeaponID then
                                    local mainAvatarID = skinID or currentWeapon:GetWeaponMainAvatarID()
                                    uiMainKillCounter:UpdateWeaponID(weaponID, mainAvatarID)
                                    local kcModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
                                    local kcItemID = kcModule:GetEquipedKillCounterId(0, mainAvatarID)
                                    uiMainKillCounter:SetKillCounterItemShowWithNum(kcItemID, _G.TDFTDeKillCounts[weaponID], mainAvatarID)
                                end
                            end
                        end
                    end
                end)
                if originalFileItem then return originalFileItem(self, DamageRecordData) end
            end
            _G.KillInfoCounterHacked = true
        end

        local SwitchWeaponSlotMode2 = package.loaded["GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2"] or require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
        if SwitchWeaponSlotMode2 and SwitchWeaponSlotMode2.__inner_impl and not _G.SlotBaseHacked then
            SwitchWeaponSlotMode2.__inner_impl.CheckShowKCIcon = function(self)
                if slua.isValid(self.KillCounterImg) then 
                    self.KillCounterImg:SetVisibility(import("ESlateVisibility").SelfHitTestInvisible) 
                end
            end
            _G.SlotBaseHacked = true
        end
    end)
end

-- ========================================== 
-- DEADBOX SKIN (temper request)
-- ==========================================
local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil
_G.DeadBox_TemperRequest = function(PlayerController)
    if _G.NeedCheckDeadBoxTimer <= 0 then return end
    
    local curTime = os.clock()
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < 2.0 then return end
    _G.LastCheckDeadBoxTime = curTime
    
    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end
    
    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end
    
    if not _G.CachedActorArray then
        _G.CachedActorArray = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end
    
    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray)
    
    for _, deadBoxActor in pairs(deadBoxes) do
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            if damageCauser and damageCauser.PlayerKey == PlayerController.PlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    local currentBoxSkinId = 0
                    if PlayerCharacter.CurrentVehicle and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
                        currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
                    else
                        local currentWeapon = PlayerCharacter:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) and currentWeapon.synData then
                            local weaponSkinData = currentWeapon.synData:Get(7)
                            if weaponSkinData and weaponSkinData.defineID then
                                currentBoxSkinId = weaponSkinData.defineID.TypeSpecificID
                            end
                        end
                    end
                    
                    if currentBoxSkinId ~= 0 then
                        pcall(function()
                            DeadBoxAvatarComponent:ResetItemAvatar()
                            DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                            DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                        end)
                    end
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end

-- ========================================== 
-- RISK WARNING WIDGET (EXPERT2)
-- ==========================================
_G.RiskWarningWidget = nil
local RISK_WARNING_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"

function _G.ShowRiskWarning()
    if _G.RiskWarningWidget and slua.isValid(_G.RiskWarningWidget) then return end
    _G.RiskWarningWidget = nil
    pcall(function()
        local widget = slua.loadUI(RISK_WARNING_BP)
        if not widget or not slua.isValid(widget) then return end
        local hud = require("game_frontend_hud")
        if not (hud and hud.AddToContainer) then return end
        hud.AddToContainer(UIContainers.Top, widget, 10700)

        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 80))
            slot:SetSize(FVector2D(220, 36))
        end

        if widget.RichText_Content then
            widget.RichText_Content:SetText("RISK FEATURE ENABLED")
            widget.RichText_Content:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
            local fontInfo = widget.RichText_Content.Font
            if fontInfo then
                fontInfo.Size = 16
                fontInfo.TypefaceFontName = "Bold"
                widget.RichText_Content:SetFont(fontInfo)
            end
        end

        -- Atur latar belakang tombol menjadi merah transparan
        if widget.Button_BG then
            widget.Button_BG:SetColorAndOpacity(FLinearColor(1, 0, 0, 0.8))
        end
        if widget.Image_Background then
            widget.Image_Background:SetColorAndOpacity(FLinearColor(1, 0, 0, 0.8))
        end

        widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        _G.RiskWarningWidget = widget
    end)
end

function _G.HideRiskWarning()
    pcall(function()
        if _G.RiskWarningWidget and slua.isValid(_G.RiskWarningWidget) then
            _G.RiskWarningWidget:RemoveFromParent()
        end
    end)
    _G.RiskWarningWidget = nil
end

-- ========================================== 
-- VIP NATIVE MENU SYSTEM (RUNS DIRECTLY FROM GAME SETTINGS)
-- ========================================== 

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    _G.JINSHIFORYOUState.CustomTextData = _G.JINSHIFORYOUState.CustomTextData or {
    OuterSpeed = 10, InnerSpeed = 10, OuterRecoil = 0, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120,
    -- === NEW FEATURES FROM GOLD ===
    IpadViewVehicleFOV = 120,
    IpadViewScopeFOV = 60,
    AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250,
    AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
    AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchScopePred = 0, AimTouchScopeRecoil = 0,
    AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400, AimTouchSniperPred = 0,
    -- === NEW MORTAR ===
    AimTouchMortarPred = 0,
    AimTouchMortarFOV = 360,
    -- === FOV COLORS ===
    AimTouchHipFOVColor = 7,
    AimTouchSGFOVColor = 1,
    AimTouchScopeFOVColor = 6,
    AimTouchSniperFOVColor = 4,
    AimTouchMortarFOVColor = 5,
    SkinSuit = 1, SkinBag = 1, SkinHelmet = 1,
    SkinM416 = 1, SkinAKM = 1, SkinSCAR = 1, SkinM762 = 1, SkinAUG = 1,
    SkinHoney = 1, SkinQBZ = 1, SkinASM = 1, SkinACE32 = 1,
    SkinUMP = 1, SkinUZI = 1, SkinVector = 1,
    SkinGroza = 1,
    SkinKar98K = 1, SkinM24 = 1, SkinAWM = 1, SkinAMR = 1,
    SkinS12K = 1, SkinDacia = 1, SkinUAZ = 1, SkinCoupe = 1, SkinBuggy = 1, SkinMirado = 1,
    SkinBIZON = 1,
    SkinGlider = 1,
    SkinParachute = 1,
    SkinGloves = 1,
}

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then
                return id
            end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        -- Color builder function with 7 options (Switcher)
        local function MakeColorSwitcher(key, text, configKey, expandHandle, defaultVal)
            return {
                Key = key,
                UI = AliasMap.Switcher,
                Text = "      " .. text,
                ExpandHandle = expandHandle,
                SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
                SwitcherValue = {1,2,3,4,5,6,7},
                GetFunc = function() return _G.JINSHIFORYOUConfig[configKey] or (defaultVal or 4) end,
                SetFunc = function(c, v)
                    local val = math.floor(v + 0.5)
                    if val < 1 then val = 1 end
                    if val > 7 then val = 7 end
                    _G.JINSHIFORYOUConfig[configKey] = val
                    return true
                end
            }
        end
        
        -- ==================== ESP VISUAL ====================
        local StackESPVisual = {
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#SETTING ESP", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = "ESP AUTO (SIMPLE MODE)", GetFunc = function() return _G.JINSHIFORYOUConfig.EspVip end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspVip = v return true end },
            { Key = "ModMenu_ESP2", UI = AliasMap.Switcher, Text = "ESP RANGE", GetFunc = function() 
    if _G.JINSHIFORYOUConfig.EspDistance == nil then
        _G.JINSHIFORYOUConfig.EspDistance = false
    end
    return _G.JINSHIFORYOUConfig.EspDistance 
end, SetFunc = function(c,v) 
    if v == true then 
        _G.JINSHIFORYOUConfig.EspDistance = true 
    else 
        _G.JINSHIFORYOUConfig.EspDistance = false 
    end 
    return true 
end },
            { Key = "ModMenu_ESP3", UI = AliasMap.Switcher, Text = "HEALTH V1 (VISCEK)", GetFunc = function() return _G.JINSHIFORYOUConfig.EspVipPro end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspVipPro = v return true end },
            { Key = "ModMenu_ESP4", UI = AliasMap.Switcher, Text = "ESP MARK - 360 Radar", GetFunc = function() return _G.JINSHIFORYOUConfig.EspRadar end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspRadar = v return true end },
            { Key = "ModMenu_ESP5", UI = AliasMap.Switcher, Text = "ESP BOX FRAME", GetFunc = function() return _G.JINSHIFORYOUConfig.Esp5 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.Esp5 = v return true end },
            { Key = "ModMenu_ESP6", UI = AliasMap.Switcher, Text = "ESP HEAD (VISCEK)", GetFunc = function() return _G.JINSHIFORYOUConfig.Esp6 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.Esp6 = v return true end },
            { Key = "ModMenu_ESP8", UI = AliasMap.Switcher, Text = "ESP HEALTH V2", GetFunc = function() return _G.JINSHIFORYOUConfig.Esp8 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.Esp8 = v return true end },
            { Key = "ModMenu_ESPAntenna", UI = AliasMap.Switcher, Text = "ESP LINE ANTENA", GetFunc = function() return _G.JINSHIFORYOUConfig.EspAntenna end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspAntenna = v return true end },
            { Key = "ModMenu_ESPName", UI = AliasMap.Switcher, Text = "ESP NAME (VISCEK)", GetFunc = function() return _G.JINSHIFORYOUConfig.EspName end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspName = v return true end },
            -- ESP THROWABLE
            { Key = "ModMenu_ESPThrowable_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP THROWABLE (Grenade, Smoke, Molotov)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.ThrowableEnabled end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ThrowableEnabled = v return true end },
            { Key = "ModMenu_Throwable_Grenade", UI = AliasMap.TitleSwitcher, Text = "   Grenade", ExpandHandle = "ModMenu_ESPThrowable_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.ThrowableGrenade end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ThrowableGrenade = v return true end },
            MakeColorSwitcher("ModMenu_Throwable_ColorGrenade", "Grenade Color", "ThrowableColor_Grenade", "ModMenu_Throwable_Grenade", 4),
            { Key = "ModMenu_Throwable_Smoke", UI = AliasMap.TitleSwitcher, Text = "   Smoke", ExpandHandle = "ModMenu_ESPThrowable_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.ThrowableSmoke end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ThrowableSmoke = v return true end },
            MakeColorSwitcher("ModMenu_Throwable_ColorSmoke", "Smoke Color", "ThrowableColor_Smoke", "ModMenu_Throwable_Smoke", 4),
            { Key = "ModMenu_Throwable_Molotov", UI = AliasMap.TitleSwitcher, Text = "   Molotov", ExpandHandle = "ModMenu_ESPThrowable_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.ThrowableMolotov end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ThrowableMolotov = v return true end },
            MakeColorSwitcher("ModMenu_Throwable_ColorMolotov", "Molotov Color", "ThrowableColor_Molotov", "ModMenu_Throwable_Molotov", 4),
            { Key = "ModMenu_Throwable_Timer", UI = AliasMap.Switcher, Text = "   Timer Scan Throwable", ExpandHandle = "ModMenu_ESPThrowable_Ex", SwitcherText = {"Always On","Every 10 Seconds","Every 20 Seconds"}, SwitcherValue = {0,10,20}, GetFunc = function() return _G.JINSHIFORYOUConfig.ThrowableScanMode or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ThrowableScanMode = v return true end },

            -- ESP VEHICLE
            { Key = "ModMenu_ESPVehicle_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP VEHICLE", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleEnabled end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleEnabled = v return true end },
            { Key = "ModMenu_Vehicle_Dacia", UI = AliasMap.TitleSwitcher, Text = "   Show Dacia", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowDacia end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowDacia = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorDacia", "Dacia Color", "VehicleColor_Dacia", "ModMenu_Vehicle_Dacia", 4),
            { Key = "ModMenu_Vehicle_UAZ", UI = AliasMap.TitleSwitcher, Text = "   Show UAZ", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowUAZ end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowUAZ = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorUAZ", "UAZ Color", "VehicleColor_UAZ", "ModMenu_Vehicle_UAZ", 4),
            { Key = "ModMenu_Vehicle_Buggy", UI = AliasMap.TitleSwitcher, Text = "   Show Buggy", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowBuggy end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowBuggy = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorBuggy", "Buggy Color", "VehicleColor_Buggy", "ModMenu_Vehicle_Buggy", 4),
            { Key = "ModMenu_Vehicle_Coupe", UI = AliasMap.TitleSwitcher, Text = "   Show Coupe RB", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowCoupe end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowCoupe = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorCoupe", "Coupe Color", "VehicleColor_Coupe", "ModMenu_Vehicle_Coupe", 4),
            { Key = "ModMenu_Vehicle_Mirado", UI = AliasMap.TitleSwitcher, Text = "   Show Mirado", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowMirado end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowMirado = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorMirado", "Mirado Color", "VehicleColor_Mirado", "ModMenu_Vehicle_Mirado", 4),
            { Key = "ModMenu_Vehicle_Motor", UI = AliasMap.TitleSwitcher, Text = "   Show Motor/Scooter", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowMotor end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowMotor = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorMotor", "Motor Color", "VehicleColor_Motor", "ModMenu_Vehicle_Motor", 4),
            { Key = "ModMenu_Vehicle_Other", UI = AliasMap.TitleSwitcher, Text = "   Show Others", ExpandHandle = "ModMenu_ESPVehicle_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.VehicleShowOther end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.VehicleShowOther = v return true end },
            MakeColorSwitcher("ModMenu_Vehicle_ColorOther", "Other Colors", "VehicleColor_Other", "ModMenu_Vehicle_Other", 4),

            -- ESP LOOT
            { Key = "ModMenu_ESPLoot_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP LOOT (Weapons & Equipment)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspLoot end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspLoot = v return true end },
            { Key = "ModMenu_Loot_M416", UI = AliasMap.TitleSwitcher, Text = "   M416", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowM416 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowM416 = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorM416", "M416 Color", "LootColor_M416", "ModMenu_Loot_M416", 4),
            { Key = "ModMenu_Loot_AUG", UI = AliasMap.TitleSwitcher, Text = "   AUG", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowAUG end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowAUG = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorAUG", "AUG Color", "LootColor_AUG", "ModMenu_Loot_AUG", 4),
            { Key = "ModMenu_Loot_AKM", UI = AliasMap.TitleSwitcher, Text = "   AKM", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowAKM end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowAKM = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorAKM", "AKM Color", "LootColor_AKM", "ModMenu_Loot_AKM", 4),
            { Key = "ModMenu_Loot_M24", UI = AliasMap.TitleSwitcher, Text = "   M249", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowM24 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowM24 = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorM24", "M24 Color", "LootColor_M24", "ModMenu_Loot_M24", 4),
            { Key = "ModMenu_Loot_UMP", UI = AliasMap.TitleSwitcher, Text = "   UMP45", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowUMP end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowUMP = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorUMP", "UMP Color", "LootColor_UMP", "ModMenu_Loot_UMP", 4),
            { Key = "ModMenu_Loot_DBS", UI = AliasMap.TitleSwitcher, Text = "   DBS", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowDBS end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowDBS = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorDBS", "DBS Color", "LootColor_DBS", "ModMenu_Loot_DBS", 4),
            { Key = "ModMenu_Loot_S12K", UI = AliasMap.TitleSwitcher, Text = "   S12K", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowS12K end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowS12K = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorS12K", "S12K Color", "LootColor_S12K", "ModMenu_Loot_S12K", 4),
            { Key = "ModMenu_Loot_Vest3", UI = AliasMap.TitleSwitcher, Text = "   Vest Lv3", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowVest3 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowVest3 = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorVest3", "Vest Lv 3 Color", "LootColor_Vest3", "ModMenu_Loot_Vest3", 4),
            { Key = "ModMenu_Loot_Helmet3", UI = AliasMap.TitleSwitcher, Text = "   Helm Lv 3", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowHelmet3 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowHelmet3 = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorHelmet3", "Helm Lv3 Color", "LootColor_Helmet3", "ModMenu_Loot_Helmet3", 4),
            { Key = "ModMenu_Loot_Bag3", UI = AliasMap.TitleSwitcher, Text = "   Bag Lv 3", ExpandHandle = "ModMenu_ESPLoot_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.LootShowBag3 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootShowBag3 = v return true end },
            MakeColorSwitcher("ModMenu_Loot_ColorBag3", "Bag Lv3 Color", "LootColor_Bag3", "ModMenu_Loot_Bag3", 4),
            { Key = "ModMenu_Loot_Timer", UI = AliasMap.Switcher, Text = "   Timer Scan Loot", ExpandHandle = "ModMenu_ESPLoot_Ex", SwitcherText = {"Always On","Every 10 Seconds","Every 20 Seconds"}, SwitcherValue = {0,10,20}, GetFunc = function() return _G.JINSHIFORYOUConfig.LootScanMode or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LootScanMode = v return true end },

            -- ESP STATIC
            { Key = "ModMenu_EspStatic_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP STATIC (Enemy Info)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspStatic end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspStatic = v return true end },
            { Key = "ModMenu_EspEnemyCount", UI = AliasMap.Switcher, Text = "   ESP ENEMY COUNT", ExpandHandle = "ModMenu_EspStatic_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.EspEnemyCount end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspEnemyCount = v return true end },
            { Key = "ModMenu_EspWeaponStatus", UI = AliasMap.Switcher, Text = "   ESP WEAPON & STATUS ENEMY", ExpandHandle = "ModMenu_EspStatic_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.EspWeaponStatus end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspWeaponStatus = v return true end },
        }

        -- ==================== AIMBOT FORCE ====================
        local StackAimbotForce = {
        { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#SETTING CROSHAIR", ExpandHandle = "ModMenu_Skin3_Ex" },
        { Key = "ModMenu_Crosshair", UI = AliasMap.Switcher, Text = "Small Crosshair (Crosshair Kecil - Drop weapon and pick up if turning off)", GetFunc = function() return _G.JINSHIFORYOUConfig.Crosshair end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.Crosshair = v return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#SETTING AIMBOT (NO AIM ASIST)", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Enable Royal & Custom Aimbot", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchEnable end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchEnable = v return true end },
            -- HIPFIRE
            { Key = "ModMenu_AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Hipfire Aimbot (Aimbot No Scope)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchHipfire = v return true end },
            { Key = "ModMenu_AT_Hip_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchHipIgKnock end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchHipIgKnock = v return true end },
            { Key = "ModMenu_AT_Hip_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchHipIgBot end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchHipIgBot = v return true end },
            { Key = "ModMenu_AT_Hip_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchHipVisCheck end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchHipVisCheck = v return true end },
            { Key = "ModMenu_AT_Hip_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas - 1:Center 2:Distance 3:HP 4:HP%)", ExpandHandle = "ModMenu_AT_Hip_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipPrio = v return true end },
            { Key = "ModMenu_AT_Hip_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang - 1:Head 2:Chest 3:Stomach 4:Pelvis)", ExpandHandle = "ModMenu_AT_Hip_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipBone or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipBone = v return true end },
            { Key = "ModMenu_AT_Hip_Cond", UI = AliasMap.Switcher, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_Hip_Ex", SwitcherText = {"Aim when firing","Always aim"}, SwitcherValue = {1,2}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipCond = v return true end },
            { Key = "ModMenu_AT_Hip_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Smoothness / Speed - 1-100)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipSpeed or 50 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipSpeed = v return true end },
            { Key = "ModMenu_AT_Hip_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipFOV or 30 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipFOV = v return true end },
            -- === NEW FOV COLOR ===
            { Key = "ModMenu_AT_Hip_FOVColor", UI = AliasMap.Slider, Text = "      FOV Circle Color", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 7, min = 1, max = 7, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchHipFOVColor or 7 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipFOVColor = v return true end },
            { Key = "ModMenu_AT_Hip_Dist", UI = AliasMap.Slider, Text = "      Distance (Distance - 1-500m)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.JINSHIFORYOUState.CustomTextData.AimTouchHipDist or 250) / 5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchHipDist = v * 5 return true end },
            -- SHOTGUN
            { Key = "ModMenu_AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Shotgun Aimbot (Shotgun Only)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSG end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSG = v return true end },
            { Key = "ModMenu_AT_SG_AutoFire", UI = AliasMap.Switcher, Text = "      Auto Fire (may cause damage bug if not firing manually)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSGAutoFire = v return true end },
            { Key = "ModMenu_AT_SG_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSGIgKnock end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSGIgKnock = v return true end },
            { Key = "ModMenu_AT_SG_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSGIgBot end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSGIgBot = v return true end },
            { Key = "ModMenu_AT_SG_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSGVisCheck end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSGVisCheck = v return true end },
            { Key = "ModMenu_AT_SG_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas - 1:Center 2:Distance 3:HP 4:HP%)", ExpandHandle = "ModMenu_AT_SG_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGPrio or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGPrio = v return true end },
            { Key = "ModMenu_AT_SG_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang - 1:Head 2:Chest 3:Stomach 4:Pelvis)", ExpandHandle = "ModMenu_AT_SG_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGBone or 2 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGBone = v return true end },
            { Key = "ModMenu_AT_SG_Cond", UI = AliasMap.Switcher, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_SG_Ex", SwitcherText = {"Aim when firing","Always aim"}, SwitcherValue = {1,2}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGCond or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGCond = v return true end },
            { Key = "ModMenu_AT_SG_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Smoothness / Speed - 1-100)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGSpeed or 80 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGSpeed = v return true end },
            { Key = "ModMenu_AT_SG_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGFOV or 40 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGFOV = v return true end },
            -- === NEW FOV COLOR ===
            { Key = "ModMenu_AT_SG_FOVColor", UI = AliasMap.Slider, Text = "      FOV Circle Color", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 7, min = 1, max = 7, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGFOVColor or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGFOVColor = v return true end },
            { Key = "ModMenu_AT_SG_Dist", UI = AliasMap.Slider, Text = "      Distance (Distance - 1-100m)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSGDist or 30 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSGDist = v return true end },
            -- SCOPE ALL
            { Key = "ModMenu_AT_ScopeAll_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Scoped Aimbot (All Weapons - If misaligned, toggle scope off/on)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchScopeAll end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchScopeAll = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchScopeIgKnock end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchScopeIgKnock = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchScopeIgBot end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchScopeIgBot = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchScopeVisCheck end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchScopeVisCheck = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas - 1:Center 2:Distance 3:HP 4:HP%)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePrio or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePrio = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang - 1:Head 2:Chest 3:Stomach 4:Pelvis)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeBone or 2 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeBone = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Cond", UI = AliasMap.Switcher, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", SwitcherText = {"Aim when firing","Always aim"}, SwitcherValue = {1,2}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeCond or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeCond = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Smoothness / Speed - 1-100)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeSpeed or 40 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeSpeed = v return true end },
            { Key = "ModMenu_AT_ScopeAll_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeFOV or 20 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeFOV = v return true end },
            -- === NEW FOV COLOR ===
            { Key = "ModMenu_AT_ScopeAll_FOVColor", UI = AliasMap.Slider, Text = "      FOV Circle Color", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 7, min = 1, max = 7, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeFOVColor or 6 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeFOVColor = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Dist", UI = AliasMap.Slider, Text = "      Distance (Distance - 1-500m)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.JINSHIFORYOUState.CustomTextData.AimTouchScopeDist or 300) / 5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeDist = v * 5 return true end },
            { Key = "ModMenu_AT_ScopeAll_Pred", UI = AliasMap.Slider, Text = "      Movement Prediction (Prediksi Gerakan)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePred or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePred = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Recoil", UI = AliasMap.Slider, Text = "      Auto Recoil Compensation (set 3-4% for smooth)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 50, min = 0, max = 50, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeRecoil or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeRecoil = v return true end },
            { Key = "ModMenu_LessShake", UI = AliasMap.Switcher, Text = "      Anti OverHead", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.LessShake end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.LessShake = v return true end },
            -- SCOPE SNIPER
            { Key = "ModMenu_AT_Sniper_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Scoped Aimbot (Sniper Rifles Only)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchScopeSniper = v return true end },
            { Key = "ModMenu_AT_Sniper_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSniperIgKnock end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSniperIgKnock = v return true end },
            { Key = "ModMenu_AT_Sniper_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSniperIgBot end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSniperIgBot = v return true end },
            { Key = "ModMenu_AT_Sniper_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchSniperVisCheck end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchSniperVisCheck = v return true end },
            { Key = "ModMenu_AT_Sniper_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas - 1:Center 2:Distance 3:HP 4:HP%)", ExpandHandle = "ModMenu_AT_Sniper_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPrio or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPrio = v return true end },
            { Key = "ModMenu_AT_Sniper_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang - 1:Head 2:Chest 3:Stomach 4:Pelvis)", ExpandHandle = "ModMenu_AT_Sniper_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperBone or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperBone = v return true end },
            { Key = "ModMenu_AT_Sniper_Cond", UI = AliasMap.Switcher, Text = "      Condition (Kondisi - 1:Aim when firing 2:Open Scope Aim)", ExpandHandle = "ModMenu_AT_Sniper_Ex", SwitcherText = {"Aim when firing","Open Scope Aim"}, SwitcherValue = {1,2}, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperCond or 2 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperCond = v return true end },
            { Key = "ModMenu_AT_Sniper_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Smoothness / Speed - 1-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperSpeed or 30 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperSpeed = v return true end },
            { Key = "ModMenu_AT_Sniper_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperFOV or 20 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperFOV = v return true end },
            -- === NEW FOV COLOR ===
            { Key = "ModMenu_AT_Sniper_FOVColor", UI = AliasMap.Slider, Text = "      FOV Circle Color", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 7, min = 1, max = 7, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperFOVColor or 4 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperFOVColor = v return true end },
            { Key = "ModMenu_AT_Sniper_Dist", UI = AliasMap.Slider, Text = "      Distance (Distance - 1-500m)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.JINSHIFORYOUState.CustomTextData.AimTouchSniperDist or 400) / 5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperDist = v * 5 return true end },
            { Key = "ModMenu_AT_Sniper_Pred", UI = AliasMap.Slider, Text = "      Movement Prediction (Prediksi Gerakan - 0-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPred or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPred = v return true end },
            -- === NEW AIMBOT MORTAR ===
            { Key = "ModMenu_AT_Mortar_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Mortar Aimbot", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.AimTouchMortar end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.AimTouchMortar = v return true end },
            { Key = "ModMenu_AT_Mortar_Pred", UI = AliasMap.Slider, Text = "      Prediction Value (Nilai Prediksi)", ExpandHandle = "ModMenu_AT_Mortar_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarPred or 0 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarPred = v return true end },
            { Key = "ModMenu_AT_Mortar_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-360)", ExpandHandle = "ModMenu_AT_Mortar_Ex", MinValue = 1, MaxValue = 360, min = 1, max = 360, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarFOV or 360 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarFOV = v return true end },
            -- === NEW FOV COLOR ===
            { Key = "ModMenu_AT_Mortar_FOVColor", UI = AliasMap.Slider, Text = "      FOV Circle Color", ExpandHandle = "ModMenu_AT_Mortar_Ex", MinValue = 1, MaxValue = 7, min = 1, max = 7, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarFOVColor or 5 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarFOVColor = v return true end },
            -- === FOV CIRCLE TOGGLE ===
            { Key = "ModMenu_FovCircle", UI = AliasMap.Switcher, Text = "▶ Show Aimbot FOV Circle", GetFunc = function() return _G.JINSHIFORYOUConfig.EspFovCircle end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspFovCircle = v return true end },
            { Key = "ModMenu_HRecoil_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Horizontal Recoil Reduction (Drop attachments and re-equip if still recoil)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.CustomHRecoil end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.CustomHRecoil = v return true end },
            { Key = "ModMenu_HRecoil_Val", UI = AliasMap.Slider, Text = "   Horizontal Recoil Value (0% : Less Recoil)", ExpandHandle = "ModMenu_HRecoil_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor((((_G.JINSHIFORYOUState.CustomTextData.HRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.HRecoil = 0.3 + (v / 100.0) * 4.7 return true end },

            { Key = "ModMenu_VRecoil_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Vertical Recoil Reduction (Drop attachments and re-equip if still recoil)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.CustomVRecoil end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.CustomVRecoil = v return true end },
            { Key = "ModMenu_VRecoil_Val", UI = AliasMap.Slider, Text = "   Vertical Recoil Value (0% : Less Recoil)", ExpandHandle = "ModMenu_VRecoil_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor((((_G.JINSHIFORYOUState.CustomTextData.VRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.VRecoil = 0.3 + (v / 100.0) * 4.7 return true end }
        }

        -- ==================== MAGIC BULLET ====================
        local StackMagicBullet = {
            { Key = "ModMenu_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Custom Magic Bullet (Use At Risk! Don't ask if you get banned - any risk is your own!)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.CustomMagicBullet end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.CustomMagicBullet = v return true end },
            { Key = "ModMenu_Magic_Head", UI = AliasMap.Slider, Text = "   Head Damage (0.0 - 5.0) (Area Kepala)", ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicHead = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Magic_Body", UI = AliasMap.Slider, Text = "   Body Damage (0.0 - 5.0) (Body Area)", ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicBody = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Magic_Legs", UI = AliasMap.Slider, Text = "   Legs Damage (0.0 - 5.0) (Area Kaki)", ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicLegs = (v / 100.0) * 5.0 return true end }
        }

        -- ==================== EXPERT (CAT_EXPERT) ====================
        local StackExpert = {
    -- ======== PARENT TOGGLE (TitleSwitcher + Pop-up) ========
    { 
        Key = "ModMenu_Expert_Active", 
        UI = AliasMap.TitleSwitcher,          -- <-- CHANGED from Switcher to TitleSwitcher
        Text = "ACTIVE EXPERT FEATURES ?", 
        ExpandIndex = 0,                       -- <-- ADD THIS so the submenu can appear
        GetFunc = function() 
            return _G.JINSHIFORYOUConfig.ExpertEnabled or false 
        end,
        SetFunc = function(c, v)
            if v then
                -- Show confirmation popup
                local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
                CommonMsgBoxMgr.Show(
                    2, 
                    "WARNING", 
                    "EXPERT FEATURES ARE BRUTAL, SO USE THEM WISELY. CONTINUE?",
                    function() 
                        -- YES: enable, show risk warning
                        _G.JINSHIFORYOUConfig.ExpertEnabled = true
                        _G.SaveModSettings()
                        _G.ShowRiskWarning()
                        -- Refresh UI so the toggle stays in sync
                        local UIManager = _G.UIManager
                        if UIManager then
                            UIManager.CloseUI(UIManager.UI_Config_InGame.Setting_Main)
                            UIManager.ShowUI(UIManager.UI_Config_InGame.Setting_Main)
                        end
                    end,
                    function() 
                        -- NO: disable, hide risk warning, refresh UI
                        _G.JINSHIFORYOUConfig.ExpertEnabled = false
                        _G.SaveModSettings()
                        _G.HideRiskWarning()
                        local UIManager = _G.UIManager
                        if UIManager then
                            UIManager.CloseUI(UIManager.UI_Config_InGame.Setting_Main)
                            UIManager.ShowUI(UIManager.UI_Config_InGame.Setting_Main)
                        end
                    end,
                    "YES", 
                    "NO"
                )
                -- Set temporarily so the toggle switches to ON (will be reverted if NO)
                _G.JINSHIFORYOUConfig.ExpertEnabled = true
                return true
            else
                _G.JINSHIFORYOUConfig.ExpertEnabled = false
                _G.HideRiskWarning()
                return true
            end
        end
    },

    -- ========== MAGIC BULLET ==========
    { 
        Key = "ModMenu_Magic_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ MAGIC BULLET", 
        ExpandHandle = "ModMenu_Expert_Active",   -- parent key
        ExpandIndex = 0, 
        GetFunc = function() return _G.JINSHIFORYOUConfig.CustomMagicBullet end, 
        SetFunc = function(c,v) _G.JINSHIFORYOUConfig.CustomMagicBullet = v return true end 
    },
    { 
        Key = "ModMenu_Magic_Head", 
        UI = AliasMap.Slider, 
        Text = "   Head Damage (0.0 - 5.0) (Area Kepala)", 
        ExpandHandle = "ModMenu_Expert_Active", 
        MinValue = 0, MaxValue = 100, min = 0, max = 100, 
        GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end, 
        SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicHead = (v / 100.0) * 5.0 return true end 
    },
    { 
        Key = "ModMenu_Magic_Body", 
        UI = AliasMap.Slider, 
        Text = "   Body Damage (0.0 - 5.0) (Body Area)", 
        ExpandHandle = "ModMenu_Expert_Active", 
        MinValue = 0, MaxValue = 100, min = 0, max = 100, 
        GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end, 
        SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicBody = (v / 100.0) * 5.0 return true end 
    },
    { 
        Key = "ModMenu_Magic_Legs", 
        UI = AliasMap.Slider, 
        Text = "   Legs Damage (0.0 - 5.0) (Area Kaki)", 
        ExpandHandle = "ModMenu_Expert_Active", 
        MinValue = 0, MaxValue = 100, min = 0, max = 100, 
        GetFunc = function() return math.floor(((_G.JINSHIFORYOUState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end, 
        SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.MagicLegs = (v / 100.0) * 5.0 return true end 
    },

    -- ========== WEAPON MOD ==========
    { 
        Key = "ModMenu_Weapon_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ WEAPON MOD", 
        ExpandHandle = "ModMenu_Expert_Active", 
        ExpandIndex = 0, 
        GetFunc = function() return _G.JINSHIFORYOUConfig.EnableWeaponMod end, 
        SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EnableWeaponMod = v return true end 
    },
    -- AKM
    { Key = "ModMenu_W101001_Title", UI = AliasMap.Title, Text = "   AKM", ExpandHandle = "ModMenu_Expert_Active" },
    { Key = "ModMenu_W101001_F", UI = AliasMap.Switcher, Text = "      Fire Speed", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101001].FireSpeed end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101001].FireSpeed = v return true end },
    { Key = "ModMenu_W101001_I", UI = AliasMap.Switcher, Text = "      Instan Hit", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101001].InstanHit end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101001].InstanHit = v return true end },
    { Key = "ModMenu_W101001_S", UI = AliasMap.Switcher, Text = "      Fast Switch", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101001].FastSwitch end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101001].FastSwitch = v return true end },
    { Key = "ModMenu_W101001_O", UI = AliasMap.Switcher, Text = "      Fast Open Scope", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101001].FastScope end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101001].FastScope = v return true end },
    -- M416
    { Key = "ModMenu_W101004_Title", UI = AliasMap.Title, Text = "   M416", ExpandHandle = "ModMenu_Expert_Active" },
    { Key = "ModMenu_W101004_F", UI = AliasMap.Switcher, Text = "      Fire Speed", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101004].FireSpeed end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101004].FireSpeed = v return true end },
    { Key = "ModMenu_W101004_I", UI = AliasMap.Switcher, Text = "      Instan Hit", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101004].InstanHit end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101004].InstanHit = v return true end },
    { Key = "ModMenu_W101004_S", UI = AliasMap.Switcher, Text = "      Fast Switch", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101004].FastSwitch end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101004].FastSwitch = v return true end },
    { Key = "ModMenu_W101004_O", UI = AliasMap.Switcher, Text = "      Fast Open Scope", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101004].FastScope end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101004].FastScope = v return true end },
    -- Beryl M762
    { Key = "ModMenu_W101008_Title", UI = AliasMap.Title, Text = "   Beryl M762", ExpandHandle = "ModMenu_Expert_Active" },
    { Key = "ModMenu_W101008_F", UI = AliasMap.Switcher, Text = "      Fire Speed", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101008].FireSpeed end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101008].FireSpeed = v return true end },
    { Key = "ModMenu_W101008_I", UI = AliasMap.Switcher, Text = "      Instan Hit", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101008].InstanHit end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101008].InstanHit = v return true end },
    { Key = "ModMenu_W101008_S", UI = AliasMap.Switcher, Text = "      Fast Switch", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101008].FastSwitch end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101008].FastSwitch = v return true end },
    { Key = "ModMenu_W101008_O", UI = AliasMap.Switcher, Text = "      Fast Open Scope", ExpandHandle = "ModMenu_Expert_Active", GetFunc = function() return _G.JINSHIFORYOUConfig.WeaponMod[101008].FastScope end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WeaponMod[101008].FastScope = v return true end },
}

        -- ==================== COMBAT GRAPHIC ====================
        local StackCombatGraphic = {
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#SETTING ETC", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.IpadView end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   FOV Angle (Sudut Pandang)", ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.JINSHIFORYOUState.CustomTextData.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.IpadViewFOV = 90 + v return true end },
            -- === NEW IPAD VEHICLE ===
            { Key = "ModMenu_IpadVeh_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View Vehicle", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.IpadViewVehicle end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.IpadViewVehicle = v return true end },
            { Key = "ModMenu_IpadVeh_FOV", UI = AliasMap.Slider, Text = "   Vehicle FOV Angle", ExpandHandle = "ModMenu_IpadVeh_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.JINSHIFORYOUState.CustomTextData.IpadViewVehicleFOV or 120) - 90 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.IpadViewVehicleFOV = 90 + v return true end },
            -- === NEW IPAD SCOPE ===
            { Key = "ModMenu_IpadScope_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View Scope", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.IpadViewScope end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.IpadViewScope = v return true end },
            { Key = "ModMenu_IpadScope_FOV", UI = AliasMap.Slider, Text = "   Scope FOV (30-120)", ExpandHandle = "ModMenu_IpadScope_Ex", MinValue = 30, MaxValue = 120, min = 30, max = 120, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.IpadViewScopeFOV or 60 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.IpadViewScopeFOV = v return true end },
            { Key = "ModMenu_165FPS", UI = AliasMap.Switcher, Text = "Unlock 165 FPS (If turning off, will take effect next match)", GetFunc = function() return _G.JINSHIFORYOUConfig.UnlockFPS end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.UnlockFPS = v; if v then _G.JINSHIFORYOUState.GraphicsUnlocked = false end return true end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = "Remove Fog (Hilangkan Kabut - If turning off, will take effect next match)", GetFunc = function() return _G.JINSHIFORYOUConfig.RemoveFog end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.RemoveFog = v return true end },
            { Key = "ModMenu_RemoveGrass", UI = AliasMap.Switcher, Text = "Remove Grass (Hilangkan Rumput - If turning off, will take effect next match)", GetFunc = function() return _G.JINSHIFORYOUConfig.RemoveGrass end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.RemoveGrass = v return true end }
        }

        -- ==================== SKIN MOD ====================
        local StackSkinMod = {
            { Key = "ModMenu_Skin_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN MOD (SKIN HACK)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.ModSkin end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.ModSkin = v return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#OUTFIT 90 SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_Skin_Suit", UI = AliasMap.Slider, Text = "   » SUIT SKIN [1-90]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinSuit or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinSuit = v; if _G.OutfitSkins and _G.OutfitSkins.Suit[v] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[v] end return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#BAG & HELM 33 SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_Skin_Bag", UI = AliasMap.Slider, Text = "   » BAG SKIN [1-19]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 19, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinBag or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinBag = v; if _G.OutfitSkins and _G.OutfitSkins.Bag[v] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[v] end return true end },
            { Key = "ModMenu_Skin_Helmet", UI = AliasMap.Slider, Text = "   » HELMET SKIN [1-14]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 14, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinHelmet or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinHelmet = v; if _G.OutfitSkins and _G.OutfitSkins.Helmet[v] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[v] end return true end },
            { Key = "ModMenu_Skin_Gloves", UI = AliasMap.Title, Text = "#GLOVES SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
    { Key = "ModMenu_Skin_Gloves", UI = AliasMap.Slider, Text = "   » GLOVES SKIN [1-3]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinGloves or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinGloves = v; if _G.OutfitSkins.Gloves and _G.OutfitSkins.Gloves[v] then _G.OutfitMap.Gloves = _G.OutfitSkins.Gloves[v] end return true end },
            { Key = "ModMenu_Skin_Glider2", UI = AliasMap.Title, Text = "#GLIDER & PARACHUTE SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
    { Key = "ModMenu_Skin_Glider", UI = AliasMap.Slider, Text = "   » GLIDER SKIN [1-1]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 1, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinGlider or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinGlider = v; if _G.OutfitSkins.Glider and _G.OutfitSkins.Glider[v] then _G.OutfitMap.Glider = _G.OutfitSkins.Glider[v] end return true end },
    { Key = "ModMenu_Skin_Parachute", UI = AliasMap.Slider, Text = "   » PARACHUTE SKIN [1-1]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 1, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinParachute or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinParachute = v; if _G.OutfitSkins.Parachute and _G.OutfitSkins.Parachute[v] then _G.OutfitMap.Parachute = _G.OutfitSkins.Parachute[v] end return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#WEAPON 83 SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_Skin_M416", UI = AliasMap.Slider, Text = "   » M416 SKIN [1-11]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 11, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinM416 or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinM416 = v; if _G.skinIdMappings[101004] and _G.skinIdMappings[101004][v] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][v] end return true end },
            { Key = "ModMenu_Skin_AKM", UI = AliasMap.Slider, Text = "   » AKM SKIN [1-8]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinAKM or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinAKM = v; if _G.skinIdMappings[101001] and _G.skinIdMappings[101001][v] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][v] end return true end },
            { Key = "ModMenu_Skin_SCAR", UI = AliasMap.Slider, Text = "   » SCAR-L SKIN [1-8]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinSCAR or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinSCAR = v; if _G.skinIdMappings[101003] and _G.skinIdMappings[101003][v] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][v] end return true end },
            { Key = "ModMenu_Skin_M762", UI = AliasMap.Slider, Text = "   » BERYL M762 SKIN [1-9]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinM762 or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinM762 = v; if _G.skinIdMappings[101008] and _G.skinIdMappings[101008][v] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][v] end return true end },
            { Key = "ModMenu_Skin_AUG", UI = AliasMap.Slider, Text = "   » AUG SKIN [1-9]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinAUG or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinAUG = v; if _G.skinIdMappings[101006] and _G.skinIdMappings[101006][v] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][v] end return true end },
            { Key = "ModMenu_Skin_Honey", UI = AliasMap.Slider, Text = "   » HONEY BADGER SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinHoney or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinHoney = v; if _G.skinIdMappings[101012] and _G.skinIdMappings[101012][v] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][v] end return true end },
            { Key = "ModMenu_Skin_QBZ", UI = AliasMap.Slider, Text = "   » QBZ SKIN [1-3]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinQBZ or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinQBZ = v; if _G.skinIdMappings[101007] and _G.skinIdMappings[101007][v] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][v] end return true end },
            { Key = "ModMenu_Skin_ASM", UI = AliasMap.Slider, Text = "   » ASM ABAKAN SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinASM or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinASM = v; if _G.skinIdMappings[101101] and _G.skinIdMappings[101101][v] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][v] end return true end },
            { Key = "ModMenu_Skin_ACE32", UI = AliasMap.Slider, Text = "   » ACE32 SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinACE32 or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinACE32 = v; if _G.skinIdMappings[101102] and _G.skinIdMappings[101102][v] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][v] end return true end },
            { Key = "ModMenu_Skin_UMP", UI = AliasMap.Slider, Text = "   » UMP45 SKIN [1-6]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinUMP or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinUMP = v; if _G.skinIdMappings[102002] and _G.skinIdMappings[102002][v] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][v] end return true end },
            { Key = "ModMenu_Skin_UZI", UI = AliasMap.Slider, Text = "   » UZI SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinUZI or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinUZI = v; if _G.skinIdMappings[102001] and _G.skinIdMappings[102001][v] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][v] end return true end },
            { Key = "ModMenu_Skin_Vector", UI = AliasMap.Slider, Text = "   » VECTOR SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinVector or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinVector = v; if _G.skinIdMappings[102003] and _G.skinIdMappings[102003][v] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][v] end return true end },
            { Key = "ModMenu_Skin_BIZON", UI = AliasMap.Slider, Text = "   » BIZON-19 SKIN [1-1]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 1, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinBIZON or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinBIZON = v; if _G.skinIdMappings[102005] and _G.skinIdMappings[102005][v] then _G.WeaponSkinMap[102005] = _G.skinIdMappings[102005][v] end return true end },
            { Key = "ModMenu_Skin_Groza", UI = AliasMap.Slider, Text = "   » GROZA SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinGroza or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinGroza = v; if _G.skinIdMappings[101005] and _G.skinIdMappings[101005][v] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][v] end return true end },
            { Key = "ModMenu_Skin_Kar98K", UI = AliasMap.Slider, Text = "   » KAR98K SKIN [1-3]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinKar98K or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinKar98K = v; if _G.skinIdMappings[103001] and _G.skinIdMappings[103001][v] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][v] end return true end },
            { Key = "ModMenu_Skin_M24", UI = AliasMap.Slider, Text = "   » M24 SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinM24 or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinM24 = v; if _G.skinIdMappings[103002] and _G.skinIdMappings[103002][v] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][v] end return true end },
            { Key = "ModMenu_Skin_AWM", UI = AliasMap.Slider, Text = "   » AWM SKIN [1-4]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 4, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinAWM or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinAWM = v; if _G.skinIdMappings[103003] and _G.skinIdMappings[103003][v] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][v] end return true end },
            { Key = "ModMenu_Skin_AMR", UI = AliasMap.Slider, Text = "   » AMR SKIN [1-3]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinAMR or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinAMR = v; if _G.skinIdMappings[103012] and _G.skinIdMappings[103012][v] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][v] end return true end },
            { Key = "ModMenu_Skin_S12K", UI = AliasMap.Slider, Text = "   » S12K SKIN [1-2]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinS12K or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinS12K = v; if _G.skinIdMappings[104003] and _G.skinIdMappings[104003][v] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][v] end return true end },
            { Key = "ModMenu_Skin_DBS", UI = AliasMap.Slider, Text = "   » DBS SKIN [1-3]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinDBS or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinDBS = v; if _G.skinIdMappings[104004] and _G.skinIdMappings[104004][v] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][v] end return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#VEHICLE 326 SKIN", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_Skin_Dacia", UI = AliasMap.Slider, Text = "   » DACIA SKIN [1-90]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinDacia or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinDacia = v; if _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][v] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][v] end return true end },
            { Key = "ModMenu_Skin_UAZ", UI = AliasMap.Slider, Text = "   » UAZ SKIN [1-90]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinUAZ or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinUAZ = v; if _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][v] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][v] end return true end },
            { Key = "ModMenu_Skin_Coupe", UI = AliasMap.Slider, Text = "   » COUPE RB SKIN [1-70]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 70, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinCoupe or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinCoupe = v; if _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][v] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][v] end return true end },
            { Key = "ModMenu_Skin_Buggy", UI = AliasMap.Slider, Text = "   » BUGGY SKIN [1-50]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinBuggy or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinBuggy = v; if _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][v] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][v] end return true end },
            { Key = "ModMenu_Skin_Mirado", UI = AliasMap.Slider, Text = "   » MIRADO SKIN [1-27]", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 27, GetFunc = function() return _G.JINSHIFORYOUState.CustomTextData.SkinMirado or 1 end, SetFunc = function(c,v) _G.JINSHIFORYOUState.CustomTextData.SkinMirado = v; if _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][v] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][v] end return true end },
            { Key = "ModMenu_Deadbox_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ DEADBOX SKIN", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.DeadboxEnabled end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.DeadboxEnabled = v return true end },
            { Key = "ModMenu_Deadbox_Delay", UI = AliasMap.Slider, Text = "   DEADBOX DELAY (Seconds - 0.1-5.0)", ExpandHandle = "ModMenu_Deadbox_Ex", MinValue = 1, MaxValue = 50, min = 1, max = 50, GetFunc = function() return math.floor((_G.JINSHIFORYOUState.DeadboxDelay or 2.0) * 10) end, SetFunc = function(c,v) _G.JINSHIFORYOUState.DeadboxDelay = v / 10.0; return true end },
            { Key = "ModMenu_KillCounter", UI = AliasMap.Switcher, Text = "KILL MESSEGE", GetFunc = function() return _G.JINSHIFORYOUConfig.KillCounterEnabled end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.KillCounterEnabled = v; if v then _G.ForceEnableKillCounterUI() end return true end },
        }

        -- ==================== COLOR MOD (BAWAAN PO2.LUA) ====================
        local StackColorMod = {
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#SETTING WALLHACK", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_WallColor", UI = AliasMap.Switcher, Text = "Wallhack & Color (No Visibile & Visible)", GetFunc = function() return _G.JINSHIFORYOUConfig.Wallhack end, SetFunc = function(c,v) 
                _G.JINSHIFORYOUConfig.Wallhack = v 
                _G.JINSHIFORYOUConfig.ColorBodyNew = v  -- Always use V3 engine
                return true 
            end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#COLOR SETTING", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "COLOR_Visible", UI = AliasMap.Switcher, Text = "Visible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.VisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.VisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Invisible", UI = AliasMap.Switcher, Text = "Invisible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.InvisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.InvisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Brightness", UI = AliasMap.Slider, Text = "Brightness (1-50)", Min = 1, Max = 50, Step = 1,
              GetFunc = function() return _G.ColorConfig.Brightness end,
              SetFunc = function(_, v) _G.ColorConfig.Brightness = v; _G.SaveModSettings(); return true end },
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "#OTHER COLOR", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "COLOR_Glow", UI = AliasMap.Slider, Text = "Glow Intensity (0-10) (WH)", Min = 0, Max = 10, Step = 0.5,
              GetFunc = function() return _G.ColorConfig.Glow end,
              SetFunc = function(_, v) _G.ColorConfig.Glow = v; _G.SaveModSettings(); return true end },
            { Key = "ModMenu_WhiteBody", UI = AliasMap.Switcher, Text = "White Body", GetFunc = function() return _G.JINSHIFORYOUConfig.WhiteBody end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.WhiteBody = v return true end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = "Black Sky", GetFunc = function() return _G.JINSHIFORYOUConfig.BlackSky end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.BlackSky = v return true end }
        }

        -- ==================== VIP ESP (ESP V3) ====================
        local StackVIPESP = {
            { Key = "ModMenu_VIPESP_H1", UI = AliasMap.Title, Text = "#SETTING VIP ESP", ExpandHandle = "ModMenu_Skin3_Ex" },
            { Key = "ModMenu_ESPV3_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP V3 (ADVANCED SYSTEM)", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Master end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Master = v if v == true then pcall(function() if _G.StartESPV3 then _G.StartESPV3() end end) else pcall(function() if _G.ESPV3Bridge and _G.ESPV3Bridge.Stop then _G.ESPV3Bridge.Stop() end end) end return true end },
            { Key = "ModMenu_ESPV3_Count", UI = AliasMap.TitleSwitcher, Text = "   Player/Bot Counter", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Count end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Count = v return true end },
            { Key = "ModMenu_ESPV3_Box", UI = AliasMap.TitleSwitcher, Text = "   Box", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Box end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Box = v return true end },
            { Key = "ModMenu_ESPV3_Line", UI = AliasMap.TitleSwitcher, Text = "   Snapline", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Line end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Line = v return true end },
            { Key = "ModMenu_ESPV3_Health", UI = AliasMap.TitleSwitcher, Text = "   Health Bar", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Health end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Health = v return true end },
            { Key = "ModMenu_ESPV3_Name", UI = AliasMap.TitleSwitcher, Text = "   Player Name", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Name end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Name = v return true end },
            { Key = "ModMenu_ESPV3_Dist", UI = AliasMap.TitleSwitcher, Text = "   Distance", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Dist end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Dist = v return true end },
            { Key = "ModMenu_ESPV3_Weapon", UI = AliasMap.TitleSwitcher, Text = "   Weapon", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Weapon end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Weapon = v return true end },
            { Key = "ModMenu_ESPV3_Flag", UI = AliasMap.TitleSwitcher, Text = "   Flag Icon", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_Flag end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_Flag = v return true end },
            { Key = "ModMenu_ESPV3_State", UI = AliasMap.TitleSwitcher, Text = "   State (Knock/Dead)", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.JINSHIFORYOUConfig.EspV3_State end, SetFunc = function(c,v) _G.JINSHIFORYOUConfig.EspV3_State = v return true end },
        }

        -- ==================== DEFINE MENU PAGE ====================
        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text = "❮❮TELE @GODXOPGODS❯❯",
            UIKey = "Setting_Page_Privacy",
            Category = {
                { Key = "Cat_VIP_ESP", Text = "❏ VIP ESP", Stack = StackVIPESP },
                { Key = "Cat_ESP_Visual", Text = "❏ ESP VISUAL", Stack = StackESPVisual },
                { Key = "Cat_Aimbot_Force", Text = "❏ AIMBOT FORCE", Stack = StackAimbotForce },
                --{ Key = "Cat_Expert", Text = "❏ EXPERT", Stack = StackExpert },
                { Key = "Cat_Combat_Graphic", Text = "❏ OPTIMEZE VISUAL", Stack = StackCombatGraphic },
                { Key = "Cat_SkinMod", Text = "❏ SKIN HACK", Stack = StackSkinMod },
                { Key = "Cat_ColorMod", Text = "❏ COLOR MOD", Stack = StackColorMod }
            }
        }
        
        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then
                            hasModMenu = true
                            break
                        end
                    end
                    if not hasModMenu then
                        table.insert(catalog, SettingPageDefine.ModMenu)
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowJINSHIFORYOUVIPMenu()
    -- Popups removed: build the mod menu directly, no WELCOME / WARNING dialogs.
    if _G.JINSHIFORYOUMenuAlreadyShown then return end
    _G.JINSHIFORYOUMenuAlreadyShown = true
    _G.JINSHIFORYOUState.MenuStep = 99
    pcall(function() _G.InitModMenuTab() end)
end

-- ========================================== 
-- LOGIC 165 FPS IPAD VIEW 
-- ========================================== 

local function ShowBypassPopup()
    if _G.BypassPopupShown then return end
    _G.BypassPopupShown = true
    
    pcall(function()
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        local Web = require("client.slua.logic.url.logic_webview_sdk")
        local function onClickTele()
            Web:OpenURL("https://t.me/GODXOPGODS")
        end
        local msg = "Warning !!\n\nPAKS MOD BY @LOVELYxHORAA\nTELEGRAM CHANNEL @GODXOPGODS\nEVERY VIP PURCHASE WILL BE ADDED TO THE VIP GROUP - IF YOU ARE NOT ADDED TO THE VIP GROUP, YOU HAVE BEEN SCAMMED/CHEATED\n\nTELEGRAM CREATOR @GODXOPGODS"
        CommonMsgBoxMgr.Show(2, "#NOTES FROM ADMIN", msg, onClickTele, nil, "TELEGRAM")
    end)
end

-- =====

local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.JINSHIFORYOUState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end
            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)
                
                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end
            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.JINSHIFORYOUState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ========================================== 
-- INITIALIZE THE ESP SYSTEM (BASED)
-- ========================================== 
local function InitializeNativeESP() 
    if _G.JINSHIFORYOUState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true; 
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"; 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
            cfg[8888] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,
                Priority = 2 
            } 
            cfg[9999] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true, 
                Priority = 2 
            } 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    _G.JINSHIFORYOUState.NativeESPReady = true 
    Notify("Native ESP System Initialized") 
end

-- ========================================== 
-- FOV CIRCLE OVERLAY (MANDIRI, TANPA PLAYERMAPMARKER - FIXED SYNC)
-- ==========================================
local SlateBlueprintLibrary = import("SlateBlueprintLibrary")

_G.FovCircleOverlay = {
    Container = nil,
    WidgetSlot = nil,
    ParentCanvas = nil,
    Lines = {},
    NumSegments = 45,
    Thickness = 1.5,
    LastRadius = -1,
    LastColor = -1,
    LastCX = -1,
    LastCY = -1,
    PrecalcMath = nil
}

local function GetFOVColor(idx)
    if idx == 1 then return 1.0, 0.0, 0.0 end
    if idx == 2 then return 0.0, 1.0, 0.0 end
    if idx == 3 then return 0.0, 0.0, 1.0 end
    if idx == 4 then return 1.0, 1.0, 0.0 end
    if idx == 5 then return 0.65, 0.15, 1.0 end
    if idx == 6 then return 0.0, 1.0, 1.0 end
    if idx == 7 then return 1.0, 1.0, 1.0 end
    return 1.0, 1.0, 1.0
end

function _G.FovCircleOverlay.Create()
    if _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then
        return true
    end

    local ParentCanvas = nil
    pcall(function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainUI = InGameUITools.GetMainControlBaseUI()
        if slua.isValid(MainUI) then
            if slua.isValid(MainUI.CanvasPanel_0) then
                ParentCanvas = MainUI.CanvasPanel_0
            elseif slua.isValid(MainUI.CanvasPanel_42) then
                ParentCanvas = MainUI.CanvasPanel_42
            end
        end
    end)

    if not ParentCanvas or not slua.isValid(ParentCanvas) then
        return false
    end

    local Container = nil
    pcall(function()
        Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas)
    end)
    if not Container or not slua.isValid(Container) then
        return false
    end

    local FVector2D = import("Vector2D") or _G.FVector2D

    for i = 1, _G.FovCircleOverlay.NumSegments do
        local border = nil
        pcall(function()
            border = CGame:NewObjectFromPath("/Script/UMG.Border", Container)
        end)
        if border and slua.isValid(border) then
            pcall(function()
                border.RenderTransformPivot = FVector2D(0, 0.5)
                border:SetRenderTransformPivot(FVector2D(0, 0.5))
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                pcall(function()
                    slot:SetAlignment(FVector2D(0, 0.5))
                end)
            end
            _G.FovCircleOverlay.Lines[i] = { widget = border, slot = slot }
        end
    end

    local MainSlot = nil
    pcall(function()
        MainSlot = ParentCanvas:AddChildToCanvas(Container)
    end)
    if MainSlot then
        pcall(function()
            MainSlot:SetAutoSize(false)
            MainSlot:SetSize(FVector2D(0, 0))
            MainSlot:SetZOrder(995)
            MainSlot:SetAlignment(FVector2D(0, 0))
            MainSlot:SetPosition(FVector2D(0, 0))
        end)
    end

    _G.FovCircleOverlay.Container = Container
    _G.FovCircleOverlay.WidgetSlot = MainSlot
    _G.FovCircleOverlay.ParentCanvas = ParentCanvas
    return true
end

function _G.FovCircleOverlay.Update(pc, player)
    if not _G.JINSHIFORYOUConfig.EspFovCircle then
        if _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then
            pcall(function()
                _G.FovCircleOverlay.Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end)
            _G.FovCircleOverlay.LastRadius = -1
        end
        return
    end

    local fovVal = 30
    local colIdx = 7
    local cData = _G.JINSHIFORYOUState.CustomTextData
    local WEAPON_TYPE = _G.__AimTouch_WeaponType or "NORMAL"
    local isADS = player.bIsGunADS or false

    if WEAPON_TYPE == "MORTAR" then
        fovVal = cData.AimTouchMortarFOV or 360
        colIdx = tonumber(cData.AimTouchMortarFOVColor) or 5
    elseif WEAPON_TYPE == "SHOTGUN" then
        fovVal = cData.AimTouchSGFOV or 40
        colIdx = tonumber(cData.AimTouchSGFOVColor) or 1
    elseif isADS then
        if WEAPON_TYPE == "SNIPER" then
            fovVal = cData.AimTouchSniperFOV or 20
            colIdx = tonumber(cData.AimTouchSniperFOVColor) or 4
        else
            fovVal = cData.AimTouchScopeFOV or 30
            colIdx = tonumber(cData.AimTouchScopeFOVColor) or 6
        end
    else
        fovVal = cData.AimTouchHipFOV or 30
        colIdx = tonumber(cData.AimTouchHipFOVColor) or 7
    end

    local rawCX = _G.__AimTouch_CenterX or 960
    local rawCY = _G.__AimTouch_CenterY or 540
    local vpX = _G.__AimTouch_ViewportX or 1920

    if not _G.FovCircleOverlay.Create() then
        return
    end

    local ParentCanvas = _G.FovCircleOverlay.ParentCanvas
    if not ParentCanvas or not slua.isValid(ParentCanvas) then
        return
    end

    -- Hitung transformasi Canvas dengan SlateBlueprintLibrary
    local scaleX, scaleY, offsetX, offsetY = 1.0, 1.0, 0.0, 0.0
    pcall(function()
        local cg = ParentCanvas:GetCachedGeometry()
        if cg and SlateBlueprintLibrary then
            local FVector2D = import("Vector2D") or _G.FVector2D
            local pt0 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D(0, 0))
            local pt1 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D(100, 100))
            if pt0 and pt1 then
                scaleX = (pt1.X - pt0.X) / 100
                scaleY = (pt1.Y - pt0.Y) / 100
                offsetX = pt0.X
                offsetY = pt0.Y
            end
        end
    end)

    -- Convert the screen center point to Canvas coordinates (so it sits on the crosshair)
    local centerX = rawCX * scaleX + offsetX
    local centerY = rawCY * scaleY + offsetY

    -- Radius dalam pixel layar, lalu diskalakan ke Canvas
    local avgScale = (scaleX + scaleY) / 2
    local rawRadius = (fovVal / 100.0) * (vpX / 2.0)
    local targetRadius = rawRadius * avgScale

    if math.abs(_G.FovCircleOverlay.LastRadius - targetRadius) < 0.5
       and _G.FovCircleOverlay.LastColor == colIdx
       and math.abs(_G.FovCircleOverlay.LastCX - centerX) < 0.5
       and math.abs(_G.FovCircleOverlay.LastCY - centerY) < 0.5 then
        return
    end

    _G.FovCircleOverlay.LastRadius = targetRadius
    _G.FovCircleOverlay.LastColor = colIdx
    _G.FovCircleOverlay.LastCX = centerX
    _G.FovCircleOverlay.LastCY = centerY

    pcall(function()
        _G.FovCircleOverlay.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)

    local FLinearColor = import("LinearColor") or _G.FLinearColor
    local r, g, b = GetFOVColor(colIdx)
    local dim = 0.55
    local color = FLinearColor and FLinearColor(r * dim, g * dim, b * dim, 1.0)
        or {R = r * dim * 255, G = g * dim * 255, B = b * dim * 255, A = 255}

    local numSegments = _G.FovCircleOverlay.NumSegments

    if not _G.FovCircleOverlay.PrecalcMath then
        _G.FovCircleOverlay.PrecalcMath = {}
        local angleStep = 360.0 / numSegments
        local math_cos = math.cos
        local math_sin = math.sin
        local math_rad = math.rad
        local math_atan2 = math.atan2 or math.atan

        for i = 1, numSegments do
            local angle1 = math_rad((i - 1) * angleStep)
            local angle2 = math_rad(i * angleStep)
            local c1, s1 = math_cos(angle1), math_sin(angle1)
            local c2, s2 = math_cos(angle2), math_sin(angle2)
            local dx_unit = c2 - c1
            local dy_unit = s2 - s1
            local dist_unit = math.sqrt(dx_unit * dx_unit + dy_unit * dy_unit)
            local angleDeg = math.deg(math_atan2(dy_unit, dx_unit))
            _G.FovCircleOverlay.PrecalcMath[i] = {
                c1 = c1, s1 = s1,
                dist_unit = dist_unit,
                angleDeg = angleDeg
            }
        end
    end

    pcall(function()
        local FVector2D = import("Vector2D") or _G.FVector2D
        for i = 1, numSegments do
            local mathData = _G.FovCircleOverlay.PrecalcMath[i]
            local x1 = targetRadius * mathData.c1
            local y1 = targetRadius * mathData.s1
            local dist = targetRadius * mathData.dist_unit

            local line = _G.FovCircleOverlay.Lines[i]
            if line and line.slot and slua.isValid(line.slot) then
                line.slot:SetPosition(FVector2D(centerX + x1, centerY + y1))
                line.slot:SetSize(FVector2D(dist + 0.8, _G.FovCircleOverlay.Thickness))
                line.widget:SetRenderAngle(mathData.angleDeg)
                line.widget:SetBrushColor(color)
            end
        end
    end)
end

function _G.CleanUpFovCircleOverlay()
    if _G.FovCircleOverlay and _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then
        pcall(function()
            _G.FovCircleOverlay.Container:RemoveFromParent()
        end)
        pcall(function()
            _G.FovCircleOverlay.Container:ConditionalBeginDestroy()
        end)
    end
    _G.FovCircleOverlay.Container = nil
    _G.FovCircleOverlay.WidgetSlot = nil
    _G.FovCircleOverlay.ParentCanvas = nil
    _G.FovCircleOverlay.LastRadius = -1
end

-- ========================================== 
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP - OPTIMIZED
-- ========================================== 
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime) < 3.0 then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

-- ========================================== 
-- ENGINE CHAMS V3 - NEW ENGINE CHAMS (From 1.lua)
-- ==========================================
local function ApplyColorBodyNew(enemy, markData)
    pcall(function()
        -- KICK CONSOLE COMMAND (Only once)
        if not _G.JINSHIFORYOUState.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and world then
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
                _G.JINSHIFORYOUState.ConsoleNewWallReady = true
            end
        end

        -- Get all enemy meshes
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        
        -- Add weapon mesh
        local weapon = nil
        pcall(function() weapon = enemy:GetCurrentWeapon() end)
        if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
            table.insert(meshes, weapon.Mesh)
        end

        local isBot = markData.AK_IS_BOT or false
        local currentMeshCount = #meshes
        
        -- Cache optimization: Only process if changed
        local stateHash = (isBot and "BOT" or "PLAYER") .. "_" .. tostring(currentMeshCount)
        
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied then
            return -- No change, skip processing
        end
        
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true

        -- Get colors from ColorConfig (mengikuti pengaturan ESP)
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        
        -- Use colors from ColorConfig for Visible and Invisible
        local visibleColorRGB = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness or 25)
        local invisibleColorRGB = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness or 25)
        
        -- Convert to LinearColor for the Engine
        local glowIntensity = _G.ColorConfig.Glow or 3.0
        local visColor = LinearColorClass and LinearColorClass(
            (visibleColorRGB.R/255) * glowIntensity, 
            (visibleColorRGB.G/255) * glowIntensity, 
            (visibleColorRGB.B/255) * glowIntensity, 
            1.0
        ) or {R=visibleColorRGB.R, G=visibleColorRGB.G, B=visibleColorRGB.B, A=255}
        
        local occColor = LinearColorClass and LinearColorClass(
            invisibleColorRGB.R/255, 
            invisibleColorRGB.G/255, 
            invisibleColorRGB.B/255, 
            1.0
        ) or {R=invisibleColorRGB.R, G=invisibleColorRGB.G, B=invisibleColorRGB.B, A=1}
        
        -- Apply to all meshes
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true)
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor)
                        mesh:SetOccludedDyeingColor(occColor)
                        mesh:SetDyeingColorFadeDistance(99999.0)
                        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
                        mesh:SetDrawHighlight(true)
                        mesh:OverrideHighlightColor(visColor)
                        mesh:SetHighlightCanBeOccluded(false)
                        mesh:SetDrawIdeaOutline(true)
                        mesh:SetIdeaOutlineNew(true)
                        mesh:SetIdeaOutlineOcclusionHighlight(true)
                        mesh:OverrideIdeaOutlineColor(visColor)
                        mesh:SetIdeaOutlineOcclusionColor(occColor)
                        mesh:OverrideIdeaOutlineThickness(20)
                        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true)
                        mesh:SetCustomDepthStencilValue(255)
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyNew(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            local weapon = nil
            pcall(function() weapon = enemy:GetCurrentWeapon() end)
            if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
                table.insert(meshes, weapon.Mesh)
            end

            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false)
                            mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false)
                            mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
            markData.LastColorNewHash = ""
        end
    end)
end

-- ========================================== 
-- AIMBOT V2 SYSTEM (UPDATED WITH MORTAR FROM GOLD)
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return result
    end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

_G.AimTouch = function()
    pcall(function()
        if not _G.JINSHIFORYOUConfig.AimTouchEnable then return end
        
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local isMortar = false
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end

            if wName:lower():find("mortar") or wName:lower():find("cối") then
                isMortar = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        if _G.JINSHIFORYOUState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.JINSHIFORYOUState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then
            return
        end

        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        
        local predVal = 0 
        local recoilCompVal = 0 

        -- MORTAR HANDLING
        if isMortar and _G.JINSHIFORYOUConfig.AimTouchMortar then
            local isPlaced = false
            pcall(function()
                if weapon and weapon.MortarState == 2 then isPlaced = true end
            end)
            if not isPlaced then return end

            cond = 2
            prioMode = 1
            boneIdx = 4
            speedVal = 100
            fovVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarFOV or 360
            maxDistMeters = 2000
            useVisCheck = false
            igKnock = false
            igBot = false
            predVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchMortarPred or 0
            
        elseif isShotgun and _G.JINSHIFORYOUConfig.AimTouchSG then
            cond = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGCond or 1
            if _G.JINSHIFORYOUConfig.AimTouchSGAutoFire then cond = 2 end
            if cond == 1 and not isFiring then return end
            prioMode = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGPrio or 1
            boneIdx = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGBone or 2
            speedVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGSpeed or 80
            fovVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGFOV or 40
            maxDistMeters = _G.JINSHIFORYOUState.CustomTextData.AimTouchSGDist or 30
            useVisCheck = _G.JINSHIFORYOUConfig.AimTouchSGVisCheck
            igKnock = _G.JINSHIFORYOUConfig.AimTouchSGIgKnock
            igBot = _G.JINSHIFORYOUConfig.AimTouchSGIgBot
            
        elseif isADS then
            if isSniper and _G.JINSHIFORYOUConfig.AimTouchScopeSniper then
                cond = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperCond or 2
                if cond == 1 and not isFiring then return end
                prioMode = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPrio or 1
                boneIdx = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperBone or 1
                speedVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperSpeed or 30
                fovVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperFOV or 20
                maxDistMeters = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperDist or 400
                useVisCheck = _G.JINSHIFORYOUConfig.AimTouchSniperVisCheck
                igKnock = _G.JINSHIFORYOUConfig.AimTouchSniperIgKnock
                igBot = _G.JINSHIFORYOUConfig.AimTouchSniperIgBot
                predVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchSniperPred or 0
            elseif _G.JINSHIFORYOUConfig.AimTouchScopeAll then
                cond = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeCond or 1
                if cond == 1 and not isFiring then return end
                prioMode = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePrio or 1
                boneIdx = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeBone or 2
                speedVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeSpeed or 40
                fovVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeFOV or 20
                maxDistMeters = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeDist or 300
                useVisCheck = _G.JINSHIFORYOUConfig.AimTouchScopeVisCheck
                igKnock = _G.JINSHIFORYOUConfig.AimTouchScopeIgKnock
                igBot = _G.JINSHIFORYOUConfig.AimTouchScopeIgBot
                predVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopePred or 0
                recoilCompVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchScopeRecoil or 0
            else
                return
            end
        else
            if not _G.JINSHIFORYOUConfig.AimTouchHipfire then return end
            cond = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipCond or 1
            if cond == 1 and not isFiring then return end 
            prioMode = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipSpeed or 50
            fovVal = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipFOV or 30
            maxDistMeters = _G.JINSHIFORYOUState.CustomTextData.AimTouchHipDist or 250
            useVisCheck = _G.JINSHIFORYOUConfig.AimTouchHipVisCheck
            igKnock = _G.JINSHIFORYOUConfig.AimTouchHipIgKnock
            igBot = _G.JINSHIFORYOUConfig.AimTouchHipIgBot
        end

        local currentMaxDist = maxDistMeters * 100 

        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                local tIsBot = false
                if target.bIsAI == true or target.IsAI == true then tIsBot = true end
                local pState = target.PlayerState
                if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
                if tIsBot then goto continue end
            end
            
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then
                finalBonePos = bestTarget:GetSocketLocation(selBoneName)
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        if predVal > 0 then
            pcall(function()
                local tVelocity = nil
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        -- MORTAR TRAJECTORY
        if isMortar and _G.JINSHIFORYOUConfig.AimTouchMortar then
            local targetPos = { X = finalBonePos.X, Y = finalBonePos.Y, Z = finalBonePos.Z }
            local launchPos = camLoc
            pcall(function()
                if player.K2_GetActorLocation then
                    local pLoc = player:K2_GetActorLocation()
                    if pLoc then 
                        launchPos = { X = pLoc.X, Y = pLoc.Y, Z = pLoc.Z + 50 } 
                    end
                end
            end)

            local function CalcMortarTrajectory(V, G, tX, tY, tZ)
                local mDx = math.sqrt((tX - launchPos.X)^2 + (tY - launchPos.Y)^2) - 80 
                if mDx < 500 then mDx = 500 end 
                local mDy = tZ - launchPos.Z
                
                local minVSq = G * (mDy + math.sqrt(mDx*mDx + mDy*mDy))
                if (V * V) < minVSq then
                    V = math.sqrt(minVSq) + 100 
                end

                local v2 = V * V
                local root = v2*v2 - G*(G*mDx*mDx + 2*mDy*v2)
                
                if root >= 0 then
                    local angleRad = math.atan((v2 + math.sqrt(root)) / (G * mDx))
                    local deg = math.deg(angleRad)
                    if deg >= 35 and deg <= 89.5 then 
                        return true, deg, mDx / (V * math.cos(angleRad)), mDx
                    end
                end
                return false, 45, 0, mDx
            end

            local vNear, gNear = 9070, 980 * 2.8   
            local vFar, gFar = 12520, 980 * 4.0    
            local vUltra, gUltra = 16800, 980 * 4.5 
            
            local isValid, physAngle, ToF, finalDx = false, 45, 0, 0
            
            local okNear, angNear, tofNear, dxN = CalcMortarTrajectory(vNear, gNear, targetPos.X, targetPos.Y, targetPos.Z)
            local okFar, angFar, tofFar, dxF = CalcMortarTrajectory(vFar, gFar, targetPos.X, targetPos.Y, targetPos.Z)
            local okUltra, angUltra, tofUltra, dxU = CalcMortarTrajectory(vUltra, gUltra, targetPos.X, targetPos.Y, targetPos.Z)

            if okNear and dxN <= 25000 then
                isValid, physAngle, ToF, finalDx = okNear, angNear, tofNear, dxN
            elseif okFar and dxF <= 40000 then
                isValid, physAngle, ToF, finalDx = okFar, angFar, tofFar, dxF
            elseif okUltra then
                isValid, physAngle, ToF, finalDx = okUltra, angUltra, tofUltra, dxU
            elseif okNear then
                isValid, physAngle, ToF, finalDx = okNear, angNear, tofNear, dxN
            end

            local targetCameraPitch = ((physAngle - 45) / 43.0) * 90.0 - 60.0
            local targetCameraYaw = rot.Yaw

            local deltaPitchMortar = targetCameraPitch - currentRot.Pitch
            local deltaYawMortar = targetCameraYaw - currentRot.Yaw

            if deltaPitchMortar > 180 then deltaPitchMortar = deltaPitchMortar - 360 end
            if deltaPitchMortar < -180 then deltaPitchMortar = deltaPitchMortar + 360 end
            if deltaYawMortar > 180 then deltaYawMortar = deltaYawMortar - 360 end
            if deltaYawMortar < -180 then deltaYawMortar = deltaYawMortar + 360 end
            
            finalPitch = currentRot.Pitch + (deltaPitchMortar * smoothFactor)
            finalYaw = currentRot.Yaw + (deltaYawMortar * smoothFactor)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        
        if recoilCompVal > 0 and isFiring then
            local pullDownForce = (recoilCompVal / 50.0) * 1.5
            finalPitch = finalPitch - pullDownForce
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        if isShotgun and _G.JINSHIFORYOUConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.JINSHIFORYOUState.IsAutoFiring = true
                end
            end)
        end

    end)
end

-- ========================================== 
-- MAIN LOOP: EXTREMELY POWERFUL OPTIMIZED
-- ========================================== 
local function MainLoop() 
    if isExpired then return end

    if _G.JINSHIFORYOUState.CustomTextData == nil then 
        _G.JINSHIFORYOUState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120, AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250, AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30, AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    if not Valid(localPlayer) then 
        if _G.JINSHIFORYOUState.TrackedMarks then
            for markId, _ in pairs(_G.JINSHIFORYOUState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.JINSHIFORYOUState.TrackedMarks = {} 
        
        for key, data in pairs(_G.JINSHIFORYOUState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
        end
        
        _G.JINSHIFORYOUState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.JINSHIFORYOUState.PrevGraphicsState = {}
        return 
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.JINSHIFORYOUConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowJINSHIFORYOUVIPMenu()

    -- SKIN SYSTEM DRIVER (apply outfit + weapon skins while ON)
    if _G.JINSHIFORYOUConfig.ModSkin then
        _G._skinTick = (_G._skinTick or 0) + 1
        if _G._skinTick % 5 == 1 then
            pcall(function() if _G.equip_character_avatar then _G.equip_character_avatar(localPlayer) end end)
            pcall(function() if _G.ApplyWeaponSkins then _G.ApplyWeaponSkins(localPlayer) end end)
        end
    end
    
    -- IPAD VIEW (UPDATED WITH VEHICLE & SCOPE FROM GOLD)
    pcall(function()
        local isAiming = false
        if localPlayer.bIsWeaponAiming or localPlayer.bIsGunADS then isAiming = true end

        local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
        local isInVehicle = Valid(currentVehicle) or localPlayer.bIsInVehicle
        local uTPPCam = localPlayer.ThirdPersonCameraComponent
        local uVehCam = localPlayer.VehicleCameraComponent
        local camMgr = pc.PlayerCameraManager

        -- Scope handling
        if isAiming then
            if _G.JINSHIFORYOUConfig.IpadViewScope and _G.JINSHIFORYOUState.CustomTextData then
                local targetScope = _G.JINSHIFORYOUState.CustomTextData.IpadViewScopeFOV or 60
                if type(pc.FOV) == "function" then pc:FOV(targetScope) end
                if Valid(camMgr) then
                    camMgr.DefaultFOV = targetScope
                    if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetScope) end
                end
            else
                if type(pc.FOV) == "function" then pc:FOV(0) end
                if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
            end
            return
        end

        -- Restore FOV if scope was turned off
        if not isInVehicle or not _G.JINSHIFORYOUConfig.IpadViewVehicle then
            if type(pc.FOV) == "function" then pc:FOV(0) end
            if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
        end

        -- Walking
        if not isInVehicle then
            if _G.JINSHIFORYOUConfig.IpadView and _G.JINSHIFORYOUState.CustomTextData then
                local targetTPP = _G.JINSHIFORYOUState.CustomTextData.IpadViewFOV or 120
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then 
                    uTPPCam.FieldOfView = targetTPP 
                end
            else
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then 
                    uTPPCam.FieldOfView = 90 
                end
            end
        end

        -- Vehicle
        if isInVehicle then
            if _G.JINSHIFORYOUConfig.IpadViewVehicle and _G.JINSHIFORYOUState.CustomTextData then
                local targetVeh = _G.JINSHIFORYOUState.CustomTextData.IpadViewVehicleFOV or 120
                
                if Valid(uVehCam) and uVehCam.FieldOfView ~= targetVeh then 
                    uVehCam.FieldOfView = targetVeh 
                end
                
                if targetVeh > 90 then
                    if type(pc.FOV) == "function" then pc:FOV(targetVeh) end
                    if Valid(camMgr) then
                        camMgr.DefaultFOV = targetVeh
                        if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetVeh) end
                    end
                end
            else
                if Valid(uVehCam) and uVehCam.FieldOfView ~= 90 then 
                    uVehCam.FieldOfView = 90 
                end
            end
        end
    end)

    -- Aimbot V2 and FOV Circle
    pcall(function()
        local ui_util = require("client.common.ui_util")
        if ui_util then
            local vp = ui_util.GetViewportSize()
            if vp then
                _G.__AimTouch_ViewportX = vp.X
                _G.__AimTouch_CenterX = vp.X * 0.5
                _G.__AimTouch_CenterY = vp.Y * 0.5
            end
        end
        
        local wName = ""
        local weapon = localPlayer.WeaponManagerComponent and localPlayer.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(localPlayer.GetCurrentShootWeapon) == "function" then
            weapon = localPlayer:GetCurrentShootWeapon()
        end
        if slua.isValid(weapon) then
            wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                _G.__AimTouch_WeaponType = "SHOTGUN"
            elseif wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                _G.__AimTouch_WeaponType = "SNIPER"
            elseif wName:lower():find("mortar") or wName:lower():find("cối") then
                _G.__AimTouch_WeaponType = "MORTAR"
            else
                _G.__AimTouch_WeaponType = "NORMAL"
            end
        end
    end)

    if _G.JINSHIFORYOUConfig.AimTouchEnable then
        _G.AimTouch()
    end

    if _G.FovCircleOverlay then
        pcall(function() _G.FovCircleOverlay.Update(pc, localPlayer) end)
    end
    
    -- ========================================== 
    -- SKIN MOD LOOP + KILL COUNTER + DEADBOX
    -- ========================================== 
    if _G.JINSHIFORYOUConfig.ModSkin then
        if not _G.TDSkinLoopStarted then
            if _G.InitializeSkinModSystem then _G.InitializeSkinModSystem() end
            if _G.ForceRefreshSkinMaps then _G.ForceRefreshSkinMaps() end
            _G.TDSkinLoopStarted = true
            if not _G.KillInfoCounterHacked and _G.ForceEnableKillCounterUI then _G.ForceEnableKillCounterUI() end
        end
        
        _G.JINSHIFORYOUState.SkinWasApplied = true
        local curTime = os.clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 1.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.ReadLiveConfig then _G.ReadLiveConfig() end
                    if _G.equip_character_avatar then _G.equip_character_avatar(localPlayer) end
                    if _G.ApplyWeaponSkins then _G.ApplyWeaponSkins(localPlayer) end
                    if _G.ApplyVehicleSkins then _G.ApplyVehicleSkins(localPlayer) end
                    if _G.HandlePetLogic then _G.HandlePetLogic() end
                    if _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then _G.DeadBox_TemperRequest(pc) end
                end
            end)
        end
    else
        if _G.JINSHIFORYOUState.SkinWasApplied then
            _G.OutfitMap = {}
            _G.WeaponSkinMap = {}
            _G.VehicleSkinMap = {}
            pcall(function()
                local WeaponManager = localPlayer:GetWeaponManager()
                if Valid(WeaponManager) then
                    for slot = 1, 3 do
                        local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
                        if Valid(Weapon) and Valid(Weapon.synData) then
                            local WeaponID = Weapon:GetWeaponID()
                            local SkinData = Weapon.synData:Get(7)
                            if SkinData and SkinData.defineID then
                                SkinData.defineID.TypeSpecificID = WeaponID
                                Weapon.synData:Set(7, SkinData)
                                if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(WeaponID) end) end
                                if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                            end
                        end
                    end
                end
                local Vehicle = localPlayer:GetCurrentVehicle()
                if Valid(Vehicle) then
                    local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
                    if Valid(VehicleAvatar) and type(VehicleAvatar.GetDefaultAvatarID) == "function" then
                        local defId = VehicleAvatar:GetDefaultAvatarID()
                        if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(defId, true) end
                    end
                end
                if localPlayer.AvatarComponent2 and type(localPlayer.AvatarComponent2.OnRep_BodySlotStateChanged) == "function" then
                    localPlayer.AvatarComponent2:OnRep_BodySlotStateChanged()
                end
            end)
            _G.JINSHIFORYOUState.SkinWasApplied = false
        end
        _G.TDSkinLoopStarted = false
    end

    -- ========================================== 
    -- Aimbot Force dipindahkan ke loop terpisah
    -- ========================================== 

    pcall(function()
        if _G.JINSHIFORYOUConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.JINSHIFORYOUState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = os.clock()
                
                if not _G.RecoilTargetCacheTime or (curTime - _G.RecoilTargetCacheTime) > 0.2 then
                    _G.RecoilTargetCacheTime = curTime
                    _G.HasRecoilTargetCached = false
                    
                    local ui_util = require("client.common.ui_util")
                    if ui_util then
                        local viewportSize = ui_util.GetViewportSize()
                        if viewportSize then
                            local centerX = viewportSize.X * 0.5
                            local centerY = viewportSize.Y * 0.5
                            local FOV_RADIUS = (6 / 100.0) * (viewportSize.X / 2.0) 
                            
                            local enemies = _G.GetEnemyTargetsFromActors(40000) 
                            if enemies and #enemies > 0 then
                                local FVector2D = import("Vector2D")
                                for _, target in ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if math.sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
                                                    _G.HasRecoilTargetCached = true
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if _G.HasRecoilTargetCached then
                    local currentRot = pc:GetControlRotation()
                    if currentRot then
                        local pullDownForce = (outerRecoilVal / 50.0) * 1.5
                        currentRot.Pitch = currentRot.Pitch - pullDownForce
                        pc:SetControlRotation(currentRot, "CustomAimbotRecoil")
                    end
                end
            end
        else
            _G.HasRecoilTargetCached = false
        end
    end)

    pcall(function()
        if Valid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false end
        end
    end)

    pcall(function()
        local autoComp = localPlayer.AutoAimComp
        if Valid(autoComp) then
            if not _G.JINSHIFORYOUState.OrigAutoAimCompCached then
                _G.JINSHIFORYOUState.OrigAutoAimCompCached = {
                    bOnlyHitHead = autoComp.bOnlyHitHead,
                    HeadBoneName = autoComp.HeadBoneName,
                    Bones = autoComp.Bones,
                    ChestBoneName = autoComp.ChestBoneName,
                    PelvisBoneName = autoComp.PelvisBoneName,
                    HeadPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.HeadPriority,
                    ChestPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.ChestPriority,
                    PelvisPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.PelvisPriority
                }
            end
            
            if _G.JINSHIFORYOUConfig.AutoHead then
                autoComp.bOnlyHitHead = true
                autoComp.HeadBoneName = "Head"
                pcall(function() autoComp.Bones = {"Head"} end)
                autoComp.ChestBoneName = "Head"
                autoComp.PelvisBoneName = "Head"
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = 100
                    autoComp.AimAssistConfig.ChestPriority = 100
                    autoComp.AimAssistConfig.PelvisPriority = 100
                end
            else
                local orig = _G.JINSHIFORYOUState.OrigAutoAimCompCached
                autoComp.bOnlyHitHead = orig.bOnlyHitHead
                autoComp.HeadBoneName = orig.HeadBoneName
                pcall(function() autoComp.Bones = orig.Bones or {"Spine_01", "Pelvis", "Head"} end)
                autoComp.ChestBoneName = orig.ChestBoneName
                autoComp.PelvisBoneName = orig.PelvisBoneName
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = orig.HeadPriority or 1
                    autoComp.AimAssistConfig.ChestPriority = orig.ChestPriority or 1
                    autoComp.AimAssistConfig.PelvisPriority = orig.PelvisPriority or 1
                end
            end
        end
    end)

    local now = os.clock()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.JINSHIFORYOUConfig.RemoveGrass and not _G.JINSHIFORYOUState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.JINSHIFORYOUState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.JINSHIFORYOUConfig.RemoveGrass and _G.JINSHIFORYOUState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.JINSHIFORYOUState.PrevGraphicsState.RemoveGrass = false
            end
            
            if _G.JINSHIFORYOUConfig.RemoveFog and not _G.JINSHIFORYOUState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "0")           
                gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.JINSHIFORYOUState.PrevGraphicsState.RemoveFog = true
            elseif not _G.JINSHIFORYOUConfig.RemoveFog and _G.JINSHIFORYOUState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "1")           
                gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.JINSHIFORYOUState.PrevGraphicsState.RemoveFog = false
            end
            
            if _G.JINSHIFORYOUConfig.WhiteBody and not _G.JINSHIFORYOUState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.JINSHIFORYOUState.PrevGraphicsState.WhiteBody = true
            elseif not _G.JINSHIFORYOUConfig.WhiteBody and _G.JINSHIFORYOUState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.JINSHIFORYOUState.PrevGraphicsState.WhiteBody = false
            end
            
            if _G.JINSHIFORYOUConfig.BlackSky and not _G.JINSHIFORYOUState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.JINSHIFORYOUState.PrevGraphicsState.BlackSky = true
            elseif not _G.JINSHIFORYOUConfig.BlackSky and _G.JINSHIFORYOUState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.JINSHIFORYOUState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
    -- Apply Weapon Mod (EXPERT FEATURE)
    _G.ApplyWeaponMod(weapon)
    
    local entities = {}
    if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
    if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
    if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then 
        table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
    end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.JINSHIFORYOUConfig.CustomHRecoil or _G.JINSHIFORYOUConfig.CustomVRecoil or _G.JINSHIFORYOUConfig.LessShake or _G.JINSHIFORYOUConfig.Accuracy or _G.JINSHIFORYOUConfig.Crosshair or _G.JINSHIFORYOUConfig.GodMode or _G.JINSHIFORYOUConfig.AutoHead or _G.JINSHIFORYOUConfig.CustomAimbot or _G.JINSHIFORYOUConfig.CustomAimbotClose or _G.JINSHIFORYOUConfig.CustomMagicBullet

                if anyWeaponModOn then
                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end
                    
                    if _G.JINSHIFORYOUConfig.CustomHRecoil then entity.AccessoriesHRecoilFactor = _G.JINSHIFORYOUState.CustomTextData.HRecoil or 0.3 
                    elseif _G.JINSHIFORYOUConfig.LessRecoil then entity.AccessoriesHRecoilFactor = 0.3 end
                    
                    if _G.JINSHIFORYOUConfig.CustomVRecoil then entity.AccessoriesVRecoilFactor = _G.JINSHIFORYOUState.CustomTextData.VRecoil or 0.3
                    elseif _G.JINSHIFORYOUConfig.VerticalRecoil then entity.AccessoriesVRecoilFactor = 0.3 end
                    
                    if _G.JINSHIFORYOUConfig.LessShake then entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0 end
                    if _G.JINSHIFORYOUConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.JINSHIFORYOUConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.JINSHIFORYOUConfig.GodMode then entity.BulletFireSpeed = 500000.0; entity.ShootInterval = 0.001; entity.BaseDamage = 60000.0 end
                    if _G.JINSHIFORYOUConfig.CustomMagicBullet then
                        entity.BaseDamage = entity.BaseDamage * (_G.JINSHIFORYOUState.CustomTextData.MagicHead or 1.0)
                    end
                    
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        if _G.JINSHIFORYOUConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end
                        
                        if _G.JINSHIFORYOUConfig.CustomAimbot then
                            local speed = _G.JINSHIFORYOUState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed                                entity.AutoAimingConfig.OuterRange.RangeRate = 4.5
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 4.5
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.JINSHIFORYOUConfig.CustomAimbotClose then
                            local speed = _G.JINSHIFORYOUState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        end
                    end
                    
                    entity.JINSHIFORYOUWeaponModsActive = true

                elseif entity.JINSHIFORYOUWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.JINSHIFORYOUWeaponModsActive = false
                end
            end
        end
    end)

    local mHead_Global, mBody_Global, mLegs_Global = 1.0, 1.0, 1.0
    local runInject_Global = false
    
    pcall(function()
        if _G.JINSHIFORYOUConfig.CustomMagicBullet then
            runInject_Global = true
            mHead_Global = 1.0; mBody_Global = 1.0; mLegs_Global = 1.0
            if _G.JINSHIFORYOUState.CustomTextData then
                local cData = _G.JINSHIFORYOUState.CustomTextData
                if cData.MagicHead ~= nil then mHead_Global = tonumber(cData.MagicHead) or mHead_Global end
                if cData.MagicBody ~= nil then mBody_Global = tonumber(cData.MagicBody) or mBody_Global end
                if cData.MagicLegs ~= nil then mLegs_Global = tonumber(cData.MagicLegs) or mLegs_Global end
            end
        elseif _G.JINSHIFORYOUConfig.MagicBullet then
            runInject_Global = true
            mHead_Global = 1.05; mBody_Global = 1.0; mLegs_Global = 1.0
        end

        if runInject_Global then
            local currentMagicHash = "M_"..tostring(mHead_Global).."_"..tostring(mBody_Global).."_"..tostring(mLegs_Global)
            if _G.JINSHIFORYOUState.LastMagicConfigHash ~= currentMagicHash then
                _G.JINSHIFORYOUState.MagicUpdateVersion = (_G.JINSHIFORYOUState.MagicUpdateVersion or 0) + 1
                _G.JINSHIFORYOUState.LastMagicConfigHash = currentMagicHash
            end
        else
            if _G.JINSHIFORYOUState.LastMagicConfigHash ~= "OFF" then
                _G.JINSHIFORYOUState.MagicUpdateVersion = (_G.JINSHIFORYOUState.MagicUpdateVersion or 0) + 1
                _G.JINSHIFORYOUState.LastMagicConfigHash = "OFF"
            end
        end
    end)

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end
        
        for key, data in pairs(_G.JINSHIFORYOUState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end
                
                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs = nil
                end
                
                data.enemy = nil
                data.CachedMeshes = nil
                _G.JINSHIFORYOUState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global, 
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,   
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global    
        }
        
        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.JINSHIFORYOUState.EnemyMarks[eKey] = _G.JINSHIFORYOUState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.JINSHIFORYOUState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                        
                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                    
                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                    -- ============ WALLHACK V3 ENGINE (NEW ENGINE CHAMS) ============
                    if _G.JINSHIFORYOUConfig.ColorBodyNew or _G.JINSHIFORYOUConfig.Wallhack then
                        if isMeshChanged or not markData.WallhackApplied then
                            ApplyColorBodyNew(enemy, markData)
                            markData.WallhackApplied = true
                            markData.LastMeshCountWall = currentMeshCount
                        end
                    else
                        UndoColorBodyNew(enemy, markData)
                        markData.WallhackApplied = false
                    end

                    pcall(function()
                        local EnemyMesh = eMesh
                        if slua.isValid(EnemyMesh) then
                            local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                            
                            if markData.MagicBulletHash == _G.JINSHIFORYOUState.LastMagicConfigHash and markData.MagicTargetID == uniqueID then
                                return 
                            end

                            local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                            if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset end

                            if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                                if not _G.AK_ModdedPhysAssets then _G.AK_ModdedPhysAssets = {} end
                                local PhysAssetName = "DefaultPhys"
                                pcall(function() PhysAssetName = PhysicsAsset:GetName() end)
                                
                                if _G.AK_ModdedPhysAssets[PhysAssetName] ~= _G.JINSHIFORYOUState.LastMagicConfigHash then
                                    
                                    if not _G.AK_OrigHitboxes then _G.AK_OrigHitboxes = {} end
                                    if not _G.AK_OrigHitboxes[PhysAssetName] then _G.AK_OrigHitboxes[PhysAssetName] = {} end
                                    local OrigHitboxData = _G.AK_OrigHitboxes[PhysAssetName]

                                    local SkeletalBodySetups = PhysicsAsset.SkeletalBodySetups
                                    local numSetups = type(SkeletalBodySetups.Num) == "function" and SkeletalBodySetups:Num() or #SkeletalBodySetups
                                    local limit = numSetups > 50 and 50 or numSetups

                                    for i = 1, limit do 
                                        local BodySetup = type(SkeletalBodySetups.Get) == "function" and SkeletalBodySetups:Get(i-1) or SkeletalBodySetups[i]
                                        if slua.isValid(BodySetup) then
                                            local LowerBoneName = string.lower(tostring(BodySetup.BoneName))
                                            local MatchedBoneKey = nil
                                            for k, _ in pairs(BoneScaleMap) do
                                                if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end
                                            end

                                            if MatchedBoneKey then
                                                local TargetScale = 1.0 
                                                if runInject_Global then TargetScale = BoneScaleMap[MatchedBoneKey] end
                                                
                                                local AggGeom = BodySetup.AggGeom
                                                
                                                local BoxElems = AggGeom and AggGeom.BoxElems or BodySetup.BoxElems
                                                local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                                local SphylElems = AggGeom and AggGeom.SphylElems or BodySetup.SphylElems

                                                local BoxElem = GetFirstElemSafe(BoxElems)
                                                local SphereElem = GetFirstElemSafe(SphereElems)
                                                local SphylElem = GetFirstElemSafe(SphylElems)

                                                if not OrigHitboxData[MatchedBoneKey] then
                                                    OrigHitboxData[MatchedBoneKey] = { Box = nil, Sphere = nil, Sphyl = nil }
                                                    if BoxElem then OrigHitboxData[MatchedBoneKey].Box = { X = BoxElem.X, Y = BoxElem.Y, Z = BoxElem.Z } end
                                                    if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                                    if SphylElem then OrigHitboxData[MatchedBoneKey].Sphyl = { Radius = SphylElem.Radius, Length = SphylElem.Length } end
                                                end

                                                local OrigElemData = OrigHitboxData[MatchedBoneKey]

                                                if OrigElemData.Box and BoxElem then
                                                    BoxElem.X = OrigElemData.Box.X * TargetScale
                                                    BoxElem.Y = OrigElemData.Box.Y * TargetScale
                                                    BoxElem.Z = OrigElemData.Box.Z * TargetScale
                                                    if type(BoxElems.Set) == "function" then BoxElems:Set(0, BoxElem) else BoxElems[1] = BoxElem end
                                                    if AggGeom then AggGeom.BoxElems = BoxElems; BodySetup.AggGeom = AggGeom else BodySetup.BoxElems = BoxElems end
                                                end

                                                if OrigElemData.Sphere and SphereElem then
                                                    SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                    if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                    if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                end

                                                if OrigElemData.Sphyl and SphylElem then
                                                    SphylElem.Radius = OrigElemData.Sphyl.Radius * TargetScale
                                                    SphylElem.Length = OrigElemData.Sphyl.Length * TargetScale
                                                    if type(SphylElems.Set) == "function" then SphylElems:Set(0, SphylElem) else SphylElems[1] = SphylElem end
                                                    if AggGeom then AggGeom.SphylElems = SphylElems; BodySetup.AggGeom = AggGeom else BodySetup.SphylElems = SphylElems end
                                                end
                                            end
                                        end
                                    end
                                    _G.AK_ModdedPhysAssets[PhysAssetName] = _G.JINSHIFORYOUState.LastMagicConfigHash
                                end
                                
                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset
                                
                                markData.MagicBulletHash = _G.JINSHIFORYOUState.LastMagicConfigHash
                                markData.MagicTargetID = uniqueID
                            end
                        end
                    end)

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.JINSHIFORYOUConfig.Esp5 or _G.JINSHIFORYOUConfig.EspVipPro or _G.JINSHIFORYOUConfig.EspVip
                    
                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp

                    if _G.JINSHIFORYOUConfig.EspAntenna then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) and distM <= 400 then
                                local loopCount = 8  
                                local zStep = 1000     
                                local baseZ = 105     
                                local topZ = baseZ + (loopCount * zStep)
                                for i = 1, loopCount do
                                    local zOffset = baseZ + (i * zStep)
                                    MyHUD:AddDebugText("|", enemy, 0.06,
                                        {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset},
                                        C_GREEN, true, false, true, nil, 1.2, true)
                                end
                                MyHUD:AddDebugText("I", enemy, 0.06,
                                        {X=0, Y=0, Z=topZ + 60}, {X=0, Y=0, Z=topZ + 60},
                                        C_GREEN, true, false, true, nil, 1.5, true)
                            end
                        end)
                    end

                    if _G.JINSHIFORYOUConfig.Esp6 then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if not (Valid(MyHUD) and MyHUD.AddDebugText) then return end
                            if not Valid(enemy) or not Valid(eMesh) then return end
                            if distM > 250 then return end

                            local headPos = eMesh:GetSocketLocation("head")
                            if not headPos then return end

                            local bIsVisible = true
                            if pc and type(pc.LineOfSightTo) == "function" then
                                bIsVisible = pc:LineOfSightTo(enemy)
                            end

                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness or 25)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness or 25)
                            local headColor = bIsVisible and visibleCol or invisibleCol

                            MyHUD:AddDebugText(
                                "●",
                                enemy,
                                0.2,
                                {X=0, Y=0, Z=90},
                                {X=0, Y=0, Z=90},
                                headColor,
                                true,
                                false,
                                true,
                                nil,
                                0.9,
                                true
                            )
                        end)
                    end

                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    if _G.JINSHIFORYOUConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local hp = enemy.Health or 100
                            local maxHp = enemy.HealthMax or 100
                            local isKnock = (hp <= 0 or enemy.HealthStatus == 1)
                            local hpPercent = isKnock and 0 or (hp / maxHp)
                            local pctValue = math.floor(hpPercent * 100 + 0.5)

                            local pName = ""
                            if _G.JINSHIFORYOUConfig.EspName then
                                pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
                            end

                            local bIsVisible = false
                            if pc and type(pc.LineOfSightTo) == "function" then
                                bIsVisible = pc:LineOfSightTo(enemy)
                            end

                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
                            
                            local textColor = {R=255, G=255, B=255, A=255}
                            if isKnock then
                                textColor = {R=0, G=0, B=255, A=255}
                            else
                                textColor = bIsVisible and visibleCol or invisibleCol
                            end

                            local prefix = bIsVisible and "▶" or "▶"
                            local label = ""
                            if isKnock then
                                label = (pName ~= "" and string.format("%s [♿]", pName) or "♿")
                            else
                                if pName ~= "" then
                                    label = string.format("%s %s %.0f%%", pName, prefix, pctValue)
                                else
                                    label = string.format("%s %.0f%%", prefix, pctValue)
                                end
                            end

                            hud:AddDebugText(label, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                                             textColor, true, false, true, nil, 1.0, true)
                        end)
                    end

                    -- =================== ESP RANGE V1 (distance in meters) ===================
                    if _G.JINSHIFORYOUConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local distMeters = math.floor(distM + 0.5)
                            local rangeColor = {R=255, G=255, B=255, A=255} -- white

                            hud:AddDebugText(string.format("%.0fm", distMeters), enemy, 0.3,
                                             {X=15, Y=15, Z=-15}, {X=15, Y=15, Z=-15},
                                             rangeColor, true, false, true, nil, 0.9, true)
                        end)
                    end

                    if _G.JINSHIFORYOUConfig.EspName and not _G.JINSHIFORYOUConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
                            if pName == "" then return end

                            local isKnock = (enemy.Health or 100) <= 0 or enemy.HealthStatus == 1
                            local bIsVisible = true
                            pcall(function()
                                if pc and type(pc.LineOfSightTo) == "function" then
                                    bIsVisible = pc:LineOfSightTo(enemy)
                                end
                            end)

                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
                            
                            local nameColor = {R=255, G=255, B=255, A=255}
                            if isKnock then
                                nameColor = {R=0, G=0, B=255, A=255}
                            else
                                nameColor = bIsVisible and visibleCol or invisibleCol
                            end

                            hud:AddDebugText(pName, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                                             nameColor, true, false, true, nil, 1.0, true)
                        end)
                    end

                    if _G.JINSHIFORYOUConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    if _G.JINSHIFORYOUConfig.Esp8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end
                    
                    if _G.JINSHIFORYOUConfig.EspRadar then
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end
                    
                    if _G.JINSHIFORYOUConfig.EspOutline then
                        pcall(function()
                            local outlineHash = tostring(_G.JINSHIFORYOUConfig.OutlineThickness)
                            if markData.OutlineState ~= outlineHash then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then
                                    PPM.OutlineThickness = _G.JINSHIFORYOUConfig.OutlineThickness
                                    if PPM.OutlineColor then PPM.OutlineColor = {r = 1, g = 0, b = 0, a = 1} end
                                    PPM:EnableAvatarOutline(avatarComp, true)
                                    markData.OutlineState = outlineHash
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                                markData.OutlineState = "OFF"
                            end
                        end)
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8)
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil
                        
                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end
                        
                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then 
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end 
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end
                            
                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end
        
        -- ========================================== 
        -- ESP VEHICLE, THROWABLE, LOOT, STATIC
        -- ========================================== 

        -- ===== ESP THROWABLE =====
        if _G.JINSHIFORYOUConfig.ThrowableEnabled then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end 
                    if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        local scanInterval = 0.5
                        local mode = _G.JINSHIFORYOUConfig.ThrowableScanMode or 0
                        if mode == 0 then scanInterval = 0.5
                        elseif mode == 10 then scanInterval = 10.0
                        elseif mode == 20 then scanInterval = 20.0
                        end
                        
                        if not _G.LastThrowableScanTime or (curTime - _G.LastThrowableScanTime) >= scanInterval then
                            _G.LastThrowableScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                            local activeThrowables = {}
                            local itemThrowables = {}
                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                        if not isPendingKill then
                                            local nameLower = string.lower(tostring(actor))
                                            local bType = 0
                                            if string.find(nameLower, "smoke") then bType = 2
                                            elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                            elseif string.find(nameLower, "grenade") then bType = 1 end
                                            if bType > 0 then
                                                if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                    table.insert(activeThrowables, {act = actor, type = bType})
                                                else
                                                    table.insert(itemThrowables, {act = actor, type = bType})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedActiveThrowables = activeThrowables
                            _G.CachedItemThrowables = itemThrowables
                        end

                        local function DrawThrowables(throwableList, isItem, maxDist)
                            if not throwableList then return end
                            for _, item in ipairs(throwableList) do
                                local throwable = item.act
                                local bType = item.type
                                if slua.isValid(throwable) and not throwable.bHidden then
                                    local isPendingKill = false
                                    pcall(function() if type(throwable.IsPendingKill) == "function" then isPendingKill = throwable:IsPendingKill() end end)
                                    if not isPendingKill then
                                        local skipDraw = false
                                        if isItem and _G.CachedActiveThrowables then
                                            pcall(function()
                                                local loc1 = type(throwable.K2_GetActorLocation) == "function" and throwable:K2_GetActorLocation()
                                                if loc1 then
                                                    for _, actItem in ipairs(_G.CachedActiveThrowables) do
                                                        local activeT = actItem.act
                                                        if slua.isValid(activeT) then
                                                            local loc2 = type(activeT.K2_GetActorLocation) == "function" and activeT:K2_GetActorLocation()
                                                            if loc2 then
                                                                local dx = loc1.X - loc2.X
                                                                local dy = loc1.Y - loc2.Y
                                                                local dz = loc1.Z - loc2.Z
                                                                if math.sqrt(dx*dx + dy*dy + dz*dz) < 150 then skipDraw = true; break end
                                                            end
                                                        end
                                                    end
                                                end
                                            end)
                                        end
                                        if not skipDraw then
                                            local distM = 0
                                            pcall(function() distM = localPlayer:GetDistanceTo(throwable) / 100 end)
                                            if distM > 0 and distM <= maxDist then
                                                local displayName = ""
                                                local color = nil
                                                local zOffset = isItem and 15 or 25
                                                local colorIdx = 4
                                                if bType == 1 then
                                                    if not _G.JINSHIFORYOUConfig.ThrowableGrenade then goto continue end
                                                    displayName = isItem and "Grenade" or "GRENADE"
                                                    colorIdx = _G.JINSHIFORYOUConfig.ThrowableColor_Grenade or 4
                                                    color = GetColorBy7(colorIdx)
                                                elseif bType == 2 then
                                                    if not _G.JINSHIFORYOUConfig.ThrowableSmoke then goto continue end
                                                    displayName = isItem and "Smoke" or "SMOKE"
                                                    colorIdx = _G.JINSHIFORYOUConfig.ThrowableColor_Smoke or 4
                                                    color = GetColorBy7(colorIdx)
                                                elseif bType == 3 then
                                                    if not _G.JINSHIFORYOUConfig.ThrowableMolotov then goto continue end
                                                    displayName = isItem and "Molotov" or "MOLOTOV"
                                                    colorIdx = _G.JINSHIFORYOUConfig.ThrowableColor_Molotov or 4
                                                    color = GetColorBy7(colorIdx)
                                                else
                                                    goto continue
                                                end
                                                if color then
                                                    local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                                    local curGameTime = 0
                                                    pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)
                                                    local shouldTimerRun = not isItem
                                                    if isItem then
                                                        pcall(function()
                                                            if throwable.bIsPinPulled or throwable.bPinPulled or (type(throwable.IsPinPulled) == "function" and throwable:IsPinPulled()) then
                                                                shouldTimerRun = true
                                                            end
                                                        end)
                                                    end
                                                    if shouldTimerRun and curGameTime > 0 then
                                                        local timeLeft = -1
                                                        pcall(function()
                                                            if type(throwable.GetExplosionTime) == "function" then timeLeft = throwable:GetExplosionTime() - curGameTime
                                                            elseif throwable.ExplosionTime then timeLeft = throwable.ExplosionTime - curGameTime
                                                            elseif throwable.ExplodeTime then timeLeft = throwable.ExplodeTime - curGameTime end
                                                        end)
                                                        if timeLeft == -1 or timeLeft > 100 then
                                                            _G.ActiveThrowableTimers = _G.ActiveThrowableTimers or {}
                                                            local id = tostring(throwable)
                                                            if not _G.ActiveThrowableTimers[id] then _G.ActiveThrowableTimers[id] = curGameTime end
                                                            local elapsed = curGameTime - _G.ActiveThrowableTimers[id]
                                                            local maxTime = 5.0
                                                            if bType == 1 then maxTime = 7.0
                                                            elseif bType == 2 then maxTime = 45.0
                                                            elseif bType == 3 then maxTime = 12.0 end
                                                            timeLeft = maxTime - elapsed
                                                        end
                                                        if timeLeft < 0 then timeLeft = 0 end
                                                        if timeLeft > 0.1 then
                                                            text = string.format("%s (%.1fs)", text, timeLeft)
                                                            if bType == 1 and timeLeft <= 1.5 then
                                                                color = {R=255, G=165, B=0, A=255}
                                                            end
                                                        end
                                                    end
                                                    pcall(function()
                                                        if _G.ActiveThrowableTimers then
                                                            for k, v in pairs(_G.ActiveThrowableTimers) do
                                                                if (curGameTime - v) > 60.0 then _G.ActiveThrowableTimers[k] = nil end
                                                            end
                                                        end
                                                    end)
                                                    local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                                    MyHUD:AddDebugText(text, throwable, 0.3, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, color, true, false, true, nil, dynamicScale, true)
                                                end
                                            end
                                        end
                                    end
                                end
                                ::continue::
                            end
                        end

                        DrawThrowables(_G.CachedItemThrowables, true, 50)
                        DrawThrowables(_G.CachedActiveThrowables, false, 150)
                    end
                end
            end)
        end

        -- ===== ESP VEHICLE =====
        if _G.JINSHIFORYOUConfig.VehicleEnabled then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForVehicle then _G.CachedActorClass_ForVehicle = import("STExtraVehicleBase") end 
                    if not _G.CachedVehicleArray then _G.CachedVehicleArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForVehicle) end
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        if not _G.LastVehicleScanTime or (curTime - _G.LastVehicleScanTime) > 1.0 then
                            _G.LastVehicleScanTime = curTime
                            local allVehicles = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForVehicle, _G.CachedVehicleArray)
                            local activeVehicles = {}
                            if allVehicles then
                                for _, veh in pairs(allVehicles) do
                                    if slua.isValid(veh) and not veh.bHidden and not veh.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(veh.IsPendingKill) == "function" then isPendingKill = veh:IsPendingKill() end end)
                                        if not isPendingKill then
                                            local vehName = "Vehicle"
                                            pcall(function()
                                                if type(veh.GetVehicleName) == "function" then vehName = veh:GetVehicleName()
                                                elseif veh.VehicleName then vehName = veh.VehicleName end
                                            end)
                                            local nameLower = string.lower(tostring(vehName) .. tostring(veh))
                                            local displayName = "Vehicle"
                                            if string.find(nameLower, "uaz") then displayName = "UAZ"
                                            elseif string.find(nameLower, "dacia") then displayName = "Dacia"
                                            elseif string.find(nameLower, "buggy") then displayName = "Buggy"
                                            elseif string.find(nameLower, "mirado") then displayName = "Mirado"
                                            elseif string.find(nameLower, "bike") or string.find(nameLower, "motor") then displayName = "Motor"
                                            elseif string.find(nameLower, "scooter") then displayName = "Scooter"
                                            elseif string.find(nameLower, "coupe") then displayName = "Coupe RB"
                                            elseif string.find(nameLower, "brdm") then displayName = "BRDM"
                                            elseif string.find(nameLower, "boat") or string.find(nameLower, "aquarail") then displayName = "Boat"
                                            elseif string.find(nameLower, "glider") then displayName = "Glider"
                                            else displayName = "Vehicle" end
                                            table.insert(activeVehicles, {act = veh, name = displayName})
                                        end
                                    end
                                end
                            end
                            _G.CachedVehicles = activeVehicles
                        end

                        if _G.CachedVehicles then
                            for _, item in ipairs(_G.CachedVehicles) do
                                local veh = item.act
                                if slua.isValid(veh) and not veh.bHidden then
                                    local isPendingKill = false
                                    pcall(function() if type(veh.IsPendingKill) == "function" then isPendingKill = veh:IsPendingKill() end end)
                                    if not isPendingKill then
                                        local isShow = false
                                        local colorKey = "VehicleColor_Other"
                                        if item.name == "Dacia" then isShow = _G.JINSHIFORYOUConfig.VehicleShowDacia; colorKey = "VehicleColor_Dacia"
                                        elseif item.name == "UAZ" then isShow = _G.JINSHIFORYOUConfig.VehicleShowUAZ; colorKey = "VehicleColor_UAZ"
                                        elseif item.name == "Buggy" then isShow = _G.JINSHIFORYOUConfig.VehicleShowBuggy; colorKey = "VehicleColor_Buggy"
                                        elseif item.name == "Coupe RB" then isShow = _G.JINSHIFORYOUConfig.VehicleShowCoupe; colorKey = "VehicleColor_Coupe"
                                        elseif item.name == "Mirado" then isShow = _G.JINSHIFORYOUConfig.VehicleShowMirado; colorKey = "VehicleColor_Mirado"
                                        elseif item.name == "Motor" or item.name == "Scooter" then isShow = _G.JINSHIFORYOUConfig.VehicleShowMotor; colorKey = "VehicleColor_Motor"
                                        else isShow = _G.JINSHIFORYOUConfig.VehicleShowOther; colorKey = "VehicleColor_Other" end
                                        if isShow then
                                            local distM = 0
                                            pcall(function() distM = localPlayer:GetDistanceTo(veh) / 100 end)
                                            if distM > 0 and distM <= 300 then
                                                local hpStr = ""
                                                pcall(function()
                                                    local hp = veh.HP or (type(veh.GetHP) == "function" and veh:GetHP()) or 100
                                                    local maxHp = veh.HPMax or (type(veh.GetHPMax) == "function" and veh:GetHPMax()) or 100
                                                    if maxHp > 0 then hpStr = string.format(" [%d%%]", math.floor((hp/maxHp)*100)) end
                                                end)
                                                local text = string.format("%s%s [%dm]", item.name, hpStr, math.floor(distM))
                                                local vehColor = GetColorBy7(_G.JINSHIFORYOUConfig[colorKey] or 4)
                                                local dynamicScale = math.max(0.6, 1.1 - (distM / 500))
                                                MyHUD:AddDebugText(text, veh, 0.3, {X=0, Y=0, Z=50}, {X=0, Y=0, Z=50}, vehColor, true, false, true, nil, dynamicScale, true)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- ===== ESP LOOT =====
        if _G.JINSHIFORYOUConfig.EspLoot then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForLoot then _G.CachedActorClass_ForLoot = import("Actor") end
                    if not _G.CachedLootArray then _G.CachedLootArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForLoot) end
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        local scanInterval = 0.5
                        local mode = _G.JINSHIFORYOUConfig.LootScanMode or 0
                        if mode == 0 then scanInterval = 0.5
                        elseif mode == 10 then scanInterval = 10.0
                        elseif mode == 20 then scanInterval = 20.0
                        end
                        
                        if not _G.LastLootScanTime or (curTime - _G.LastLootScanTime) >= scanInterval then
                            _G.LastLootScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForLoot, _G.CachedLootArray)
                            local lootItems = {}
                            local lootKeywords = {
    ["m416"] = {name = "M416", toggle = "LootShowM416", colorKey = "LootColor_M416"},
    ["aug"] = {name = "AUG", toggle = "LootShowAUG", colorKey = "LootColor_AUG"},
    ["akm"] = {name = "AKM", toggle = "LootShowAKM", colorKey = "LootColor_AKM"},
    ["m24"] = {name = "M24", toggle = "LootShowM24", colorKey = "LootColor_M24"},
    ["m249"] = {name = "M249", toggle = "LootShowM249", colorKey = "LootColor_M249"},
    ["ump45"] = {name = "UMP45", toggle = "LootShowUMP", colorKey = "LootColor_UMP"},
    ["ump"] = {name = "UMP45", toggle = "LootShowUMP", colorKey = "LootColor_UMP"},
    ["dbs"] = {name = "DBS", toggle = "LootShowDBS", colorKey = "LootColor_DBS"},
    ["s12k"] = {name = "S12K", toggle = "LootShowS12K", colorKey = "LootColor_S12K"},
    ["s12"] = {name = "S12K", toggle = "LootShowS12K", colorKey = "LootColor_S12K"},
}
                            local level3Items = {
    --["vest"] = {name = "Vest Lv3", toggle = "LootShowVest3", colorKey = "LootColor_Vest3"},
    ["armor"] = {name = "Vest Lv3", toggle = "LootShowVest3", colorKey = "LootColor_Vest3"},
    ["helmet"] = {name = "Helm Lv3", toggle = "LootShowHelmet3", colorKey = "LootColor_Helmet3"},
    ["helm"] = {name = "Helm Lv3", toggle = "LootShowHelmet3", colorKey = "LootColor_Helmet3"},
    ["bag 3"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3"},
    ["backpack 3"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3"},
    ["bag_lv3"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3"},
    ["backpack_lv3"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3"},
}

                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                        if not isPendingKill then
                                            local actorName = ""
                                            pcall(function() 
                                                if type(actor.GetName) == "function" then actorName = actor:GetName()
                                                elseif actor.Name then actorName = actor.Name
                                                else actorName = tostring(actor) end
                                            end)
                                            local lowerName = string.lower(actorName)
                                            if lowerName == "" then lowerName = string.lower(tostring(actor)) end
                                            
                                            local displayInfo = nil
                                            local matched = false

                                            for keyword, info in pairs(lootKeywords) do
                                                if string.find(lowerName, keyword, 1, true) then
                                                    displayInfo = info
                                                    matched = true
                                                    break
                                                end
                                            end

                                            if not matched then
                                                for keyword, info in pairs(level3Items) do
                                                    if string.find(lowerName, keyword, 1, true) and string.find(lowerName, "3", 1, true) then
                                                        displayInfo = info
                                                        matched = true
                                                        break
                                                    end
                                                end
                                            end

                                            if matched and displayInfo then
                                                table.insert(lootItems, {act = actor, info = displayInfo})
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedLootItems = lootItems
                        end

                        if _G.CachedLootItems then
                            for _, item in ipairs(_G.CachedLootItems) do
                                local loot = item.act
                                if slua.isValid(loot) and not loot.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(loot) / 100 end)
                                    if distM > 0 and distM <= 100 then
                                        local displayName = item.info.name
                                        local toggle = item.info.toggle
                                        if toggle and not _G.JINSHIFORYOUConfig[toggle] then goto continue end
                                        local colorIdx = _G.JINSHIFORYOUConfig[item.info.colorKey] or 4
                                        local color = GetColorBy7(colorIdx)
                                        local dynamicScale = math.max(0.5, 1.0 - (distM / 100))
                                        MyHUD:AddDebugText(
                                            string.format("%s [%dm]", displayName, math.floor(distM)),
                                            loot,
                                            0.3,
                                            {X=0, Y=0, Z=30},
                                            {X=0, Y=0, Z=30},
                                            color,
                                            true, false, true, nil, dynamicScale, true
                                        )
                                    end
                                end
                                ::continue::
                            end
                        end
                    end
                end
            end)
        end

        -- ===== ESP STATIC =====
        if _G.JINSHIFORYOUConfig.EspStatic then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if not Valid(MyHUD) then return end

                -- ESP ENEMY COUNT
                if _G.JINSHIFORYOUConfig.EspEnemyCount then
                    local function GetRainbowColor()
                        local time = os.clock()
                        local r = math.sin(time * 0.8) * 0.5 + 0.5
                        local g = math.sin(time * 0.8 + 2.094) * 0.5 + 0.5
                        local b = math.sin(time * 0.8 + 4.188) * 0.5 + 0.5
                        return { R = math.floor(r * 255), G = math.floor(g * 255), B = math.floor(b * 255), A = 255 }
                    end

                    local myTeamId = localPlayer.TeamID or localPlayer:GetTeamID() or 0
                    local myPos = localPlayer:K2_GetActorLocation()
                    local maxDist = 35000
                    local realCount = 0
                    local aiCount = 0

                    for _, tPawn in pairs(allCharacters) do
                        if slua.isValid(tPawn) and tPawn ~= localPlayer then
                            local targetTeamId = tPawn.TeamID or tPawn:GetTeamID() or 0
                            if targetTeamId ~= myTeamId then
                                local enemyPos = tPawn:K2_GetActorLocation()
                                if enemyPos then
                                    local dx = enemyPos.X - myPos.X
                                    local dy = enemyPos.Y - myPos.Y
                                    local dz = enemyPos.Z - myPos.Z
                                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                                    if dist <= maxDist then
                                        local isAI = false
                                        if tPawn.bIsAI == true or tPawn.IsAI == true then isAI = true end
                                        if not isAI then
                                            local pState = tPawn.PlayerState or (type(tPawn.GetPlayerState) == "function" and tPawn:GetPlayerState())
                                            if slua.isValid(pState) then
                                                if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
                                                local playerID = pState.PlayerId or pState.PlayerID
                                                if playerID and (playerID == 0 or playerID < 10000) then isAI = true end
                                                local exactPing = pState.ExactPing or pState.Ping
                                                if exactPing and exactPing == 0 then isAI = true end
                                            else isAI = true end
                                        end
                                        if isAI then aiCount = aiCount + 1 else realCount = realCount + 1 end
                                    end
                                end
                            end
                        end
                    end

                    local color = GetRainbowColor()
                    local totalEnemy = realCount + aiCount
                    local text = totalEnemy > 0 and string.format("❮ ENEMY : %d ❯", totalEnemy) or " ❮AREA 350M CLEAR || @JINSHIFORYOU❯"
                    MyHUD:AddDebugText(text, localPlayer, 1.05, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, color, true, false, true, nil, 1.2, true)
                end

                -- ESP WEAPON & STATUS ENEMY
                if _G.JINSHIFORYOUConfig.EspWeaponStatus then
                    local ui_util = require("client.common.ui_util")
                    local viewportSize = ui_util and ui_util.GetViewportSize()
                    if viewportSize then
                        local centerX = viewportSize.X * 0.5
                        local centerY = viewportSize.Y * 0.5
                        local FOV_RADIUS = (10 / 100.0) * (viewportSize.X / 2.0)
                        local FVector2D = import("Vector2D")
                        local bestTarget = nil
                        local bestDist = 999999

                        for _, enemy in pairs(allCharacters) do
                            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                                local ePos = enemy:K2_GetActorLocation()
                                if ePos then
                                    local screen = FVector2D()
                                    if pc:ProjectWorldLocationToScreen(ePos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                        local dx = screen.X - centerX
                                        local dy = screen.Y - centerY
                                        local distScreen = math.sqrt(dx*dx + dy*dy)
                                        if distScreen <= FOV_RADIUS then
                                            local dist3D = localPlayer:GetDistanceTo(enemy)
                                            if dist3D < bestDist then
                                                bestDist = dist3D
                                                bestTarget = enemy
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if Valid(bestTarget) then
                            local distM = math.floor(bestDist / 100)
                            local hp = bestTarget.Health or 100
                            local maxHp = bestTarget.HealthMax or 100
                            local hpPercent = maxHp > 0 and math.floor((hp / maxHp) * 100) or 0
                            local isKnock = (hp <= 0 or bestTarget.HealthStatus == 1)
                            
                            local weaponName = "Tangan Kosong"
                            local eWeapon = nil
                            if bestTarget.CurrentWeapon then eWeapon = bestTarget.CurrentWeapon
                            elseif type(bestTarget.GetCurrentWeapon) == "function" then eWeapon = bestTarget:GetCurrentWeapon()
                            elseif bestTarget.WeaponManagerComponent then eWeapon = bestTarget.WeaponManagerComponent.CurrentWeaponReplicated end
                            if Valid(eWeapon) and type(eWeapon.GetWeaponName) == "function" then weaponName = eWeapon:GetWeaponName() end

                            local statusText = isKnock and " [K]" or ""
                            local text = string.format("%s | %dm | %d%% HP%s", weaponName, distM, hpPercent, statusText)
                            MyHUD:AddDebugText(text, bestTarget, 0.15, {X=0, Y=0, Z=-50}, {X=0, Y=0, Z=-50}, C_YELLOW, true, false, true, nil, 0.8, true)
                        end
                    end
                end
            end)
        end
    end)
end

_G.JINSHIFORYOUState.LoopToken = (_G.JINSHIFORYOUState.LoopToken or 0) + 1 
local myToken = _G.JINSHIFORYOUState.LoopToken

-- ========================================== 
-- MAIN LOOP (ESP & OTHER FEATURES) WITH 0.2 SECONDS
-- ========================================== 
local function FastTick() 
    if isExpired then 
        if not _G.JINSHIFORYOUNotifiedExpire then
            Notify("MOD HAS EXPIRED! PLEASE CONTACT ADMIN TO RENEW!\nTelegram @JINSHIFORYOU")
            _G.JINSHIFORYOUNotifiedExpire = true
        end
        return 
    end

    if myToken ~= _G.JINSHIFORYOUState.LoopToken then return end
    pcall(MainLoop) 
    pcall(function() if _G.JINSHIFORYOUConfig and _G.JINSHIFORYOUConfig.EspV3_Master and _G.ESPV3Bridge and _G.ESPV3Bridge.Pump then _G.ESPV3Bridge.Pump() end end)
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.2, FastTick) 
    end 
end

-- ========================================== 
-- DEDICATED FORCE AIMBOT LOOP WITH 0.016 SECONDS (~60 FPS)
-- ========================================== 
local aimbotToken = 0
local function FastAimbotTick()
    if isExpired then 
        return 
    end

    if aimbotToken ~= _G.JINSHIFORYOUState.AimbotLoopToken then 
        return 
    end

    pcall(function()
        if _G.JINSHIFORYOUConfig.AimTouchEnable then
            _G.AimTouch()
        end
    end)

    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastAimbotTick)
    end
end

-- ========================================== 
-- IGNITE BOTH LOOPS
-- ========================================== 
if not isExpired then
    FastTick() 
    _G.JINSHIFORYOUState.AimbotLoopToken = (_G.JINSHIFORYOUState.AimbotLoopToken or 0) + 1
    aimbotToken = _G.JINSHIFORYOUState.AimbotLoopToken
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, FastAimbotTick)
    pcall(function() if _G.StartESPV3 then _G.StartESPV3() end end)
    end
    Notify("You are using VIP Mod v4. If you don't have a key, inbox Telegram : @JINSHIFORYOU")
else
    FastTick() 
end

-- ===================================================================================
-- SYSTEM HOOKS BYPASS
-- ===================================================================================
local function InitAllModSystems()
    if isExpired then return end 

    pcall(function()
        if _G.StartBypass_VIP_v3 then _G.StartBypass_VIP_v3() end
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)

    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end

    pcall(function()
        local LocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(LocalPlayer) then
            if LocalPlayer.bHasShownDevNotice == nil then
                LocalPlayer.bHasShownDevNotice = false 
                LocalPlayer.bHasShownExpiredNotice = false 
                LocalPlayer.bIsDeadFlag = false
            end
        end
    end)
end

if not isExpired then
    pcall(function() 
        require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems) 
    end)
end

-- ========================================== 
-- PERMANENT WATERMARK "@JINSHIFORYOU"  YELLOW
-- ==========================================
pcall(function()
    local IPS = require("GameLua.Mod.Library.Client.UI.IngamePhoneStateUI")
    if IPS and IPS.__inner_impl then
        local o = IPS.__inner_impl.UpdateArtQualityUI
        IPS.__inner_impl.UpdateArtQualityUI = function(self, _, _)
            if self.UIRoot and self.UIRoot.TextBlock_quality then
                self.UIRoot.TextBlock_quality:SetText("LOVELYxHORAA")
                self.UIRoot.TextBlock_quality:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 0, 1)))
            end
        end
    end
end)

-- ============================================================
-- AUTO FEEDBACK SYSTEM (Telegram) - ALL RANKS SUPPORTED
-- ============================================================
local AutoFeedback = {
	Config = {
		ServerURL = "https://lovely.feedbackauto5.workers.dev/",
		TestMode = false
	},
	Hooked = false
}

local function AF_Log(message)
	print(string.format("[GODXOPGODS ][%s] %s", os.date("%H:%M:%S"), tostring(message)))
end

local function AF_Notify(message)
	if _G.SRCHUBNotify then
		pcall(_G.SRCHUBNotify, message)
	end
end

local function AF_GetModule(name, allowRequire)
	local loaded = package and package.loaded and package.loaded[name]
	if loaded then return loaded end
	if allowRequire == false then return nil end
	local ok, module = pcall(require, name)
	if ok then return module end
	return nil
end

local function AF_AddTimerOnce(delay, callback)
	local ticker = AF_GetModule("common.time_ticker")
	if ticker and type(ticker.AddTimerOnce) == "function" then
		ticker.AddTimerOnce(delay, callback)
		return true
	end
	return false
end

local function AF_Base64Encode(data)
	if type(data) ~= "string" or #data == 0 then return "" end
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local output = {}
	local outputIndex = 0
	local index = 1
	while index <= #data - 2 do
		local a, b, c = string.byte(data, index, index + 2)
		local value = a * 65536 + b * 256 + c
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte(alphabet, value % 64 + 1)
		)
		index = index + 3
	end
	local remaining = #data - index + 1
	if remaining == 2 then
		local a, b = string.byte(data, index, index + 1)
		local value = a * 65536 + b * 256
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte("=")
		)
	elseif remaining == 1 then
		local value = string.byte(data, index) * 65536
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte("="),
			string.byte("=")
		)
	end
	return table.concat(output)
end

local function AF_UrlEncode(value)
	if value == nil then return nil end
	value = tostring(value):gsub("\n", "\r\n")
	value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(character)
		return string.format("%%%02X", string.byte(character))
	end)
	value = value:gsub(" ", "+")
	return value
end

local function AF_ReadFile(path)
	local file = io.open(path, "rb")
	if not file then return "" end
	local data = file:read("*a") or ""
	file:close()
	return data
end

local function AF_RemoveFile(path)
	pcall(os.remove, path)
end

local function AF_GetRankName(rank)
	if rank < 1700 then return "Bronze"
	elseif rank < 2200 then return "Silver"
	elseif rank < 2700 then return "Gold"
	elseif rank < 3200 then return "Platinum"
	elseif rank < 3700 then return "Diamond"
	elseif rank < 4200 then return "Crown"
	elseif rank < 4700 then return "Ace"
	elseif rank < 5200 then return "Ace Master"
	elseif rank < 5600 then return "Ace Dominator"
	end
	return "Conqueror"
end

local FeedbackCaptionTemplate = "<b>TELEGRAM [ @GODXOPGODS  ]</b>\n<pre>\nPlayer - %s\nUID    - %s\nTime   - %s\nKills  - %d\nRank   - %s\n</pre>\n[ ACTIVE - SAFE ]\n<b>Owner: LOVELYxHORAA</b>"

function AutoFeedback.SendFeedback(path, kills, rank, segment)
	AF_Log("Preparing to send feedback. Screenshot: " .. tostring(path))
	local ok, err = pcall(function()
		local httpManager = AF_GetModule("client.slua.logic.http.http_manager")
		if not httpManager or type(httpManager.Post) ~= "function" then
			AF_Log("HTTP manager is unavailable.")
			return
		end
		local attempts = 0
		local function TrySend()
			local imageData = AF_ReadFile(path)
			if #imageData > 0 then
				local uid = "unknown"
				if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
					uid = tostring(_G.DataMgr.roleData.uid)
				elseif _G._KONG_UK then
					uid = tostring(_G._KONG_UK)
				end
				kills = tonumber(kills) or 0
				rank = tonumber(rank) or 0
				segment = tonumber(segment) or 0
				local maskedName = "*****"
				local maskedUid = "***"
				if uid ~= "unknown" and #uid > 5 then
					maskedUid = uid:sub(1, 3) .. "***" .. uid:sub(-2)
				end
				local caption = string.format(
					FeedbackCaptionTemplate,
					maskedName,
					maskedUid,
					os.date("%H:%M:%S %d/%m/%Y"),
					kills,
					AF_GetRankName(rank)
				)
				local encodedImage = AF_Base64Encode(imageData)
				encodedImage = encodedImage:gsub("%+", "%%2B")
				encodedImage = encodedImage:gsub("/", "%%2F")
				encodedImage = encodedImage:gsub("=", "%%3D")
				AF_Notify("[SRC_HUB] Uploading Top 1 screenshot to VIP Server...")
				local body = "base64_image=" .. encodedImage
					.. "&caption=" .. AF_UrlEncode(caption)
					.. "&bot_token=" .. AF_UrlEncode("8802514286:AAGq52fI_bXb9ofmGPhmGwGt68VtcyuvA44")
					.. "&chat_id=" .. AF_UrlEncode("8253017358")
				httpManager:Post(
					AutoFeedback.Config.ServerURL,
					{["Content-Type"] = "application/x-www-form-urlencoded"},
					body,
					nil,
					function(success, _, response, errorMessage)
						if success and response and tostring(response):find('"status":%s*true') then
							AF_Notify("[SRC_HUB] Successfully sent! (Kills: " .. tostring(kills) .. ")")
						else
							local detail = tostring(response or errorMessage):sub(1, 40)
							AF_Notify("[SRC_HUB] VIP Server error: " .. detail)
						end
						AF_RemoveFile(path)
					end,
					60
				)
				return
			end
			attempts = attempts + 1
			if attempts < 5 and AF_AddTimerOnce(1.0, TrySend) then
				return
			end
			AF_Notify("[SRC_HUB] Screenshot capture failed!")
			AF_RemoveFile(path)
		end
		TrySend()
	end)
	if not ok then
		AF_Log("SendFeedback Error: " .. tostring(err))
	end
end

local AF_HudNames = {
	"BattleChat_UIBP","Chat_UIBP","ChatMsg_UIBP","TeamAvatar_UIBP","Team_UIBP",
	"VoiceChat_UIBP","MiniMap_UIBP","Bag_UIBP","PickUp_UIBP","PickUpList_UIBP",
	"SystemChat_UIBP","InGameChat_UIBP","InGameChatPanel_UIBP","KillFeed_UIBP",
	"Elimination_UIBP","ChatHUD_UIBP","ChatPanel_UIBP","MainHUD_UIBP","BattleHUD_UIBP"
}

local function AF_GetRankAndSegment()
	local rank = 0
	local segment = 0
	pcall(function()
		local battleResult = _G.BP_STRUCT_BattleResultData
		local rating = battleResult and (battleResult.rating or battleResult.BP_STRUCT_BTRating)
		if rating then
			rank = tonumber(rating.rank_rating) or 0
			segment = tonumber(rating.new_segment) or 0
		end
		if rank == 0 then
			local funcUtil = AF_GetModule("common.func_util")
			local roleData = _G.DataMgr and _G.DataMgr.roleData
			if funcUtil and type(funcUtil.GetCurMaxSegementLevel) == "function"
				and roleData and roleData.allzoneSegment then
				segment = tonumber(funcUtil.GetCurMaxSegementLevel(roleData.allzoneSegment)) or 0
			end
			if roleData and roleData.segment_rating then
				for _, value in pairs(roleData.segment_rating) do
					if type(value) == "table" then
						for _, nestedValue in pairs(value) do
							if type(nestedValue) == "number" and nestedValue > rank then
								rank = nestedValue
							end
						end
					elseif type(value) == "number" and value > rank then
						rank = value
					end
				end
			end
		end
	end)
	return rank, segment
end

local function AF_CreateHudController()
	local hidden = {}
	local function SetHidden(hide)
		local UIManager = _G.UIManager
		if not UIManager then return end
		if hide then
			for _, name in ipairs(AF_HudNames) do
				local config
				if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
					config = UIManager.UI_Config_InGame[name]
				elseif UIManager.UI_Config and UIManager.UI_Config[name] then
					config = UIManager.UI_Config[name]
				end
				if config then
					local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
					if view then
						pcall(function()
							if type(view.SetVisibility) == "function" then
								view:SetVisibility(2)
							elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then
								view.UIRoot:SetVisibility(2)
							elseif type(UIManager.HideUI) == "function" then
								UIManager.HideUI(config)
							elseif type(UIManager.CloseUI) == "function" then
								UIManager.CloseUI(config)
							end
						end)
						table.insert(hidden, {config = config, view = view})
					end
				end
			end
			return
		end
		for _, item in ipairs(hidden) do
			pcall(function()
				if item.view and type(item.view.SetVisibility) == "function" then
					item.view:SetVisibility(0)
				elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then
					item.view.UIRoot:SetVisibility(0)
				elseif type(UIManager.ShowUI) == "function" then
					UIManager.ShowUI(item.config)
				end
			end)
		end
		hidden = {}
	end
	return SetHidden
end

local function AF_GetScreenshotDirectory()
	local directories = {}
	local home = os.getenv("HOME")
	if home and home ~= "" then
		table.insert(directories, home .. "/Documents/ShadowTrackerExtra/Saved/")
	end
	local packages = {"com.tencent.ig","com.vng.pubgmobile","com.pubg.krmobile","com.rekoo.pubgm","com.pubg.imobile"}
	for _, packageName in ipairs(packages) do
		table.insert(directories,
			"/storage/emulated/0/Android/data/" .. packageName
			.. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/")
	end
	local selected = directories[1]
	for _, directory in ipairs(directories) do
		local testPath = directory .. "t.tmp"
		local file = io.open(testPath, "w")
		if file then
			file:close()
			os.remove(testPath)
			selected = directory
			break
		end
	end
	return selected
end

local function AF_CaptureAndSend(kills, rank, segment, restoreHud)
	local restored = false
	local function RestoreHudOnce()
		if not restored then
			restored = true
			restoreHud(false)
		end
	end
	local ScreenshotMaker = import("ScreenshotMaker")
	if not ScreenshotMaker then RestoreHudOnce(); return end
	local directory = AF_GetScreenshotDirectory()
	if not directory then RestoreHudOnce(); return end
	local path = directory .. string.format("kongwin_%s.jpg", os.time())
	local uiUtil = AF_GetModule("client.common.ui_util")
	local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
	local enginePreTick = gameInstance and gameInstance.EnginePreTick
	if not enginePreTick or type(enginePreTick.Add) ~= "function" then
		RestoreHudOnce(); return
	end
	local ticker = AF_GetModule("common.time_ticker")
	if not ticker or type(ticker.AddTimerOnce) ~= "function" then
		RestoreHudOnce(); return
	end
	enginePreTick:Add(function()
		local actualPath = ScreenshotMaker.MakePictureByName(path, true)
		if type(enginePreTick.Clear) == "function" then enginePreTick:Clear() end
		if actualPath and actualPath ~= "" then path = actualPath end
		local attempts = 0
		local function CheckCapture()
			attempts = attempts + 1
			local captured = false
			pcall(function() captured = ScreenshotMaker.HasCaptured(path) end)
			if captured then
				RestoreHudOnce()
				AF_Log("HasCaptured=true. Flushing to disk via ResizePicture...")
				pcall(ScreenshotMaker.ResizePicture, path, 0.9, path)
				ticker.AddTimerOnce(2.0, function()
					if #AF_ReadFile(path) > 0 then
						AutoFeedback.SendFeedback(path, kills, rank, segment)
					else
						AF_Notify("[SRC_HUB] iOS image read error!")
					end
				end)
			elseif attempts < 15 then
				ticker.AddTimerOnce(1, CheckCapture)
			else
				RestoreHudOnce()
				AF_Notify("[SRC_HUB] Screenshot capture failed!")
			end
		end
		ticker.AddTimerOnce(1, CheckCapture)
	end)
end

function AutoFeedback.ProcessWin(kills)
	kills = tonumber(kills) or 0
	local rank, segment = AF_GetRankAndSegment()
	-- ✅ ALL RANKS SUPPORTED - Sirf kills check (kills > 0)
	if kills <= 0 then
		AF_Log(string.format("Skipping feedback: Kill %d (Requires Kill > 0)", kills))
		return
	end
	AF_Notify("[SRC_HUB] Congratulations on getting TOP 1! Rank: " .. AF_GetRankName(rank))
	local setHudHidden = AF_CreateHudController()
	setHudHidden(true)
	local ok, err = pcall(AF_CaptureAndSend, kills, rank, segment, setHudHidden)
	if not ok then
		setHudHidden(false)
		AF_Log("ProcessWin Error: " .. tostring(err))
	end
end

local function AF_GetWinnerKills()
	local kills = 0
	pcall(function()
		local likeUtil = AF_GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
		if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
			local playerState = likeUtil.GetMyPlayerState()
			if playerState and playerState.Kills then
				kills = tonumber(playerState.Kills) or 0
			end
		end
		if kills == 0 then
			local resultLogic = AF_GetModule(
				"GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic",
				false
			)
			if resultLogic and type(resultLogic.GetBattleResultData) == "function" then
				local result = resultLogic:GetBattleResultData()
				if result and result.BP_mykill then
					kills = tonumber(result.BP_mykill) or 0
				end
			end
		end
	end)
	return kills
end

local function AF_TryInstallHook()
	pcall(function()
		local UIManager = _G.UIManager
		if not UIManager or not UIManager.ShowUI then return end
		if UIManager.__SRCHUBHooked then
			UIManager.__SRCHUBHooked = false
		end
		AF_Log("Hooking UIManager.ShowUI for in-game Winner UI...")
		local originalShowUI = UIManager.ShowUI
		UIManager.ShowUI = function(config, params, ...)
			local result = originalShowUI(config, params, ...)
			pcall(function()
				-- ✅ STRONG WINNER DETECTION - Chicken Dinner Fix
				if not params then return end

				local isWinner = params.Reason == "win"
					or params.ShowedWinLogo == true
					or params.IsWin == true
					or params.IsWinner == true
					or params.bWin == true
					or params.Win == true

				if not isWinner then return end

				local kills = AF_GetWinnerKills()
				if not AF_AddTimerOnce(2, function() AutoFeedback.ProcessWin(kills) end) then
					AutoFeedback.ProcessWin(kills)
				end
			end)
			return result
		end
		-- UIManager.__SRCHUBHooked = true
		AF_Log("UIManager Hook installed successfully.")
	end)
end

function AutoFeedback.Install()
	AF_Log("Installing Pro system (Telegram)...")
	if AutoFeedback.Config.TestMode then
		pcall(function()
			AF_AddTimerOnce(5.0, function() AutoFeedback.ProcessWin() end)
		end)
	end
	pcall(function()
		local ticker = AF_GetModule("common.time_ticker")
		if ticker and type(ticker.AddTimer) == "function" then
			ticker.AddTimer(3.0, AF_TryInstallHook)
		else
			AF_TryInstallHook()
		end
	end)
end

_G.GODxRJ_AutoFeedbackRecovered = AutoFeedback
AutoFeedback.Install()
-- ============================================================
-- CREDIT TEXT WIDGET (REDMAGIX OFFICIAL)
-- ============================================================
local CreditTextWidget = nil
local RightTextWidget = nil

local function CreateCreditText()
  -- ---------- LEFT TEXT (TG) - RED STYLISH ----------
  if not (CreditTextWidget and slua.isValid(CreditTextWidget)) then
    pcall(function()
      local txt = CGame:NewObjectFromPath("/Script/UMG.TextBlock")
      if not txt or not slua.isValid(txt) then return end

      local hud = require("game_frontend_hud")
      if hud and hud.AddToContainer and UIContainers and UIContainers.Top then
        hud.AddToContainer(UIContainers.Top, txt, 9999)
      end

      -- Yahan brackets aur bullet change kiye hain jo game support karega
      txt:SetText("> JOIN TG <  |  GODXOPGODS")
      txt:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0, 0, 1)))  -- RED

      if txt.Font then
        local font = txt.Font
        font.Size = 10
        font.TypefaceFontName = "Bold"
        txt.Font = font
      end

      txt:SetShadowOffset(FVector2D(1, 1))
      txt:SetShadowColorAndOpacity(FLinearColor(0, 0, 0, 0.8))

      local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
      if WidgetLayoutLibrary then
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(txt)
        if slot then
          slot:SetAnchors(FAnchors(0, 1, 0, 1))       -- left-bottom
          slot:SetAlignment(FVector2D(0, 1))
          slot:SetPosition(FVector2D(25, -45))
          slot:SetSize(FVector2D(260, 30))            -- wide
        end
      end

      if UEnums and UEnums.ESlateVisibility then
        txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end

      CreditTextWidget = txt
    end)
  end

  -- ---------- RIGHT TEXT (LUA PAK) - GREEN ----------
  if not (RightTextWidget and slua.isValid(RightTextWidget)) then
    pcall(function()
      local txt2 = CGame:NewObjectFromPath("/Script/UMG.TextBlock")
      if not txt2 or not slua.isValid(txt2) then return end

      local hud = require("game_frontend_hud")
      if hud and hud.AddToContainer and UIContainers and UIContainers.Top then
        hud.AddToContainer(UIContainers.Top, txt2, 9999)
      end

      -- Isme [ ] pehle se theek dikh rahe the, isliye wahi rakha hai
      txt2:SetText("LUA PAK  [ V11 ]")
      txt2:SetColorAndOpacity(FSlateColor(FLinearColor(0, 1, 0, 1)))  -- GREEN

      if txt2.Font then
        local font = txt2.Font
        font.Size = 8
        font.TypefaceFontName = "Bold"
        txt2.Font = font
      end

      local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
      if WidgetLayoutLibrary then
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(txt2)
        if slot then
          slot:SetAnchors(FAnchors(1, 1, 1, 1))       -- right-bottom
          slot:SetAlignment(FVector2D(1, 1))
          slot:SetPosition(FVector2D(-25, -45))
          slot:SetSize(FVector2D(220, 30))
        end
      end

      if UEnums and UEnums.ESlateVisibility then
        txt2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end

      RightTextWidget = txt2
    end)
  end
end

pcall(CreateCreditText)

-- ============================================================
-- END CREDIT TEXT WIDGET
-- ============================================================


-- ========================================================================
-- ADDED: LOGIN PAGE + KILL LIMIT CARD + KILL LIMIT WARNING (from CHETAN)
-- ========================================================================

local Vector2D = import("Vector2D")
local LinearColor = import("LinearColor")
local SlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")

local CONFIG = {
    LOGIN_URL     = "https://lovelykeybro.pythonanywhere.com/connect",
    HEARTBEAT_URL = "https://lovelykeybro.pythonanywhere.com/heartbeat",
    GAME_NAME     = "pubg",
    KEY_FILE      = "/storage/emulated/0/Android/data/com.pubg.imobile/files/keys.txt",
    UID_FILE      = "/storage/emulated/0/Android/data/com.pubg.imobile/files/uid.txt",
    BRAND_NAME    = "GODXOPGODS",
    BRAND_SUB     = "PREMIUM ACCESS",
    SUPPORT_TEXT  = "OWNER LOVELYxHORAA",
    TELEGRAM_URL  = "https://t.me/GODXOPGODS",
}

-- ============ GET DEVICE ID ============
local function getDeviceId()
    local id = nil
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        if KSL then
            if KSL.GetDeviceId then id = KSL.GetDeviceId() end
            if (not id or id == "") and KSL.GetDeviceIdOS then id = KSL.GetDeviceIdOS() end
        end
    end)
    if id then id = tostring(id):gsub("[^A-Za-z0-9%-_]", "") end
    if not id or id == "" then id = nil end
    return id
end

-- ============ GET UID FROM PC ============
local function getUIDFromPC()
    local uid = nil
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD.GetPlayerController and slua_GameFrontendHUD:GetPlayerController()
        if pc then
            if pc.UID then uid = tostring(pc.UID) end
            if (not uid or uid == "" or uid == "0") and pc.PlayerState and pc.PlayerState.UID then
                uid = tostring(pc.PlayerState.UID)
            end
        end
    end)
    if uid == "" or uid == "0" then uid = nil end
    return uid
end

-- ============ GET/CREATE UID ============
local function getOrCreateUID()
    local uid = nil
    pcall(function()
        local f = io.open(CONFIG.UID_FILE, "r")
        if f then uid = f:read("*all") f:close() end
        if uid then uid = uid:gsub("%s+", "") end
        if not uid or uid == "" then
            uid = "ZN-" .. tostring(math.random(100000, 999999)) .. tostring(os.time())
            local w = io.open(CONFIG.UID_FILE, "w")
            if w then w:write(uid) w:close() end
        end
        if uid == "" then uid = nil end
    end)
    return uid
end

-- ============ GET SERIAL ============
local function getSerial()
    local s = getDeviceId()
    if not s then s = getUIDFromPC() end
    if not s then s = getOrCreateUID() end
    return s
end

-- ============ READ KEY ============
local function readKeyFromFile()
    local key = nil
    pcall(function()
        local f = io.open(CONFIG.KEY_FILE, "r")
        if f then key = f:read("*all") f:close() end
        if key then key = key:gsub("%s+", "") end
        if key == "" then key = nil end
    end)
    return key
end

-- ============ SAVE KEY ============
local function saveKeyToFile(key)
    _G._LICENSE_KEY = key
    pcall(function()
        local f = io.open(CONFIG.KEY_FILE, "w")
        if f then f:write(key) f:close() end
    end)
end

-- ============ GET CURRENT KEY ============
local function getCurrentKey()
    if _G._LICENSE_KEY and _G._LICENSE_KEY ~= "" then return _G._LICENSE_KEY end
    return readKeyFromFile()
end

-- ============ MAP REASON ============
local function mapReason(reason)
    if not reason then return "nonet" end
    if reason == "USER BLOCKED" then return "blocked" end
    if reason == "EXPIRED KEY" then return "expired" end
    if reason == "MAX DEVICE REACHED" then return "device_limit" end
    if reason == "USER OR GAME NOT REGISTERED" then return "invalid" end
    return "nonet"
end

-- ============ LICENSE CHECK API ============
local function checkLicense(key, serial, callback)
    local httpMgr = nil
    pcall(function()
        httpMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
    end)
    if not httpMgr or not httpMgr.Post then
        callback(false, "nonet", nil)
        return
    end
    local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
    local body = "game=" .. CONFIG.GAME_NAME .. "&user_key=" .. key .. "&serial=" .. serial
    httpMgr:Post(CONFIG.LOGIN_URL, headers, body, nil, function(ok, response)
        if ok and response then
            if response:find("\"status\"%s*:%s*true") then
                if response:find("\"data\"%s*:") then
                    callback(true)
                    return
                end
            end
            local reason = nil
            pcall(function()
                if response then reason = response:match("\"reason\"%s*:%s*\"([^\"]+)\"") end
            end)
            callback(false, mapReason(reason), nil)
        else
            callback(false, "nonet", nil)
        end
    end, 15)
end

-- ============ HEARTBEAT API ============
local function sendHeartbeat(key, serial)
    pcall(function()
        if not key or not serial then return end
        local httpMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
        if not httpMgr or not httpMgr.Post then return end
        local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
        local body = "user_key=" .. key .. "&serial=" .. serial
        httpMgr:Post(CONFIG.HEARTBEAT_URL, headers, body, nil, function(ok, response) end, 10)
    end)
end

-- ============ SHOW MSG BOX ============
local function showMsgBox(title, body)
    pcall(function()
        local msgBox = require("client.slua.logic.common.logic_common_msg_box")
        if msgBox and msgBox.Show then msgBox.Show(4, title, body) end
    end)
end

-- ============ OPEN TELEGRAM ============
local function openTelegram()
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        if KSL and KSL.LaunchURL then KSL.LaunchURL(CONFIG.TELEGRAM_URL) end
    end)
end

-- ========================================================================
-- MEDIUM SIZE EXACT CENTER RGB UI BUILDER
-- ========================================================================
local UI = {}

local function getMainCanvas()
    local canvas = nil
    pcall(function()
        local UITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local mainUI = UITools.GetMainControlBaseUI()
        if mainUI and slua.isValid(mainUI) then
            canvas = mainUI.CanvasPanel_0
            if not (canvas and slua.isValid(canvas)) then canvas = nil end
            if not canvas and mainUI.CanvasPanel_42 and slua.isValid(mainUI.CanvasPanel_42) then
                canvas = mainUI.CanvasPanel_42
            end
        end
    end)
    return canvas
end

local function makeText(parent, text, size, color, x, y, alignX)
    local tb = CGame:NewObjectFromPath("/Script/UMG.TextBlock", parent)
    if tb and slua.isValid(tb) then
        pcall(function()
            tb:SetText(tostring(text))
            if SlateColor then tb:SetColorAndOpacity(SlateColor(color)) else tb:SetColorAndOpacity(color) end
            if tb.Font then local f = tb.Font f.Size = size f.TypefaceFontName = "Bold" tb.Font = f end
            tb:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local slot = parent:AddChildToCanvas(tb)
        if slot then
            pcall(function()
                slot:SetAutoSize(true)
                slot:SetAlignment(Vector2D(alignX or 0.5, 0.5))
                slot:SetPosition(Vector2D(x, y))
                slot:SetZOrder(9999)
            end)
        end
    end
    return tb
end

local function makeBorder(parent, color, x, y, w, h, zorder)
    local b = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
    if b and slua.isValid(b) then
        pcall(function()
            b:SetBrushColor(color)
            b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local slot = parent:AddChildToCanvas(b)
        if slot then
            pcall(function()
                slot:SetAlignment(Vector2D(0.5, 0.5))
                slot:SetPosition(Vector2D(x, y))
                slot:SetSize(Vector2D(w, h))
                slot:SetZOrder(zorder or 9999)
            end)
        end
    end
    return b
end

local function makeButton(parent, x, y, w, h, label, bgColor, textColor, callback, fontSize)
    makeBorder(parent, LinearColor(0.0, 0.0, 0.0, 0.35), x, y + 4, w, h, 9995)
    makeBorder(parent, LinearColor(0.0, 0.95, 0.0, 0.85), x, y, w, h, 9996)
    local bg = makeBorder(parent, bgColor, x, y, w - 4, h - 4, 9997)
    makeBorder(parent, LinearColor(0.55, 1.0, 0.55, 0.30), x, y - h * 0.5 + 2, w - 18, 1, 9998)

    local btn = CGame:NewObjectFromPath("/Script/UMG.Button", parent)
    if not (btn and slua.isValid(btn)) then return nil end

    local slot = parent:AddChildToCanvas(btn)
    if slot then
        pcall(function()
            slot:SetAlignment(Vector2D(0.5, 0.5))
            slot:SetPosition(Vector2D(x, y))
            slot:SetSize(Vector2D(w, h))
            slot:SetZOrder(9999)
        end)
    end

    local lbl = CGame:NewObjectFromPath("/Script/UMG.TextBlock", btn)
    if lbl and slua.isValid(lbl) then
        pcall(function()
            lbl:SetText(label)
            if SlateColor then lbl:SetColorAndOpacity(SlateColor(textColor)) else lbl:SetColorAndOpacity(textColor) end
            if lbl.Font then local f = lbl.Font f.Size = fontSize or 22 f.TypefaceFontName = "Bold" lbl.Font = f end
            lbl:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
            pcall(function() btn:AddChild(lbl) end)
        end)
    end

    pcall(function()
        if btn.OnClicked and btn.OnClicked.Add then
            btn.OnClicked:Add(function() callback() end)
        end
    end)
    pcall(function()
        if slua.addDelegate then
            slua.addDelegate(btn.OnClicked, function() callback() end)
        end
    end)
    return btn, bg
end

local function makeDarkInput(parent, x, y, w, h, borderColor, bgDarkColor)
    local borderBorder = makeBorder(parent, borderColor, x, y, w, h, 9992)
    makeBorder(parent, bgDarkColor, x, y, w - 4, h - 4, 9993)

    local box = CGame:NewObjectFromPath("/Script/UMG.EditableTextBox", parent)
    if not (box and slua.isValid(box)) then return nil end

    local slot = parent:AddChildToCanvas(box)
    if slot then
        pcall(function()
            slot:SetAlignment(Vector2D(0.5, 0.5))
            slot:SetPosition(Vector2D(x, y))
            slot:SetSize(Vector2D(w - 16, h - 8))
            slot:SetZOrder(9999)
        end)
    end

    pcall(function()
        if box.SetHintText then box:SetHintText("Enter your key to login...") end
        if box.SetKeyboardFocus then box:SetKeyboardFocus() end
    end)
    return box, borderBorder
end

local function getBoxText(box)
    local txt = nil
    pcall(function()
        if box and slua.isValid(box) and box.GetText then
            local v = box:GetText()
            if type(v) == "string" then txt = v
            elseif v and v.ToString then txt = v:ToString()
            else txt = tostring(v) end
        end
    end)
    if txt then txt = tostring(txt):gsub("[^A-Za-z0-9%-_]", "") end
    if not txt or txt == "" then txt = nil end
    return txt
end

local function setStatus(text, isError)
    pcall(function()
        if _G._LOGIN_STATUS and slua.isValid(_G._LOGIN_STATUS) then
            _G._LOGIN_STATUS:SetText(tostring(text))
            pcall(function()
                local col = isError and LinearColor(1.0, 0.2, 0.2, 1.0) or LinearColor(0.55, 1.0, 0.55, 1.0)
                if SlateColor then _G._LOGIN_STATUS:SetColorAndOpacity(SlateColor(col))
                else _G._LOGIN_STATUS:SetColorAndOpacity(col) end
            end)
        end
    end)
end

local function cleanupUI()
    pcall(function()
        if _G._LOGIN_POPUP and slua.isValid(_G._LOGIN_POPUP) then
            _G._LOGIN_POPUP:RemoveFromParent()
            if _G._LOGIN_POPUP.ConditionalBeginDestroy then _G._LOGIN_POPUP:ConditionalBeginDestroy() end
        end
    end)
    _G._LOGIN_POPUP = nil
    _G._LOGIN_TRYING = false
    pcall(function()
        if _G._LOGIN_TIMER and _G._LOGIN_CHAR then
            pcall(function() _G._LOGIN_CHAR:RemoveGameTimer(_G._LOGIN_TIMER) end)
        end
    end)
    _G._LOGIN_TIMER = nil
    _G._LOGIN_CHAR = nil
    pcall(function()
        if _G._LOGIN_UI and slua.isValid(_G._LOGIN_UI) then
            _G._LOGIN_UI:RemoveFromParent()
            if _G._LOGIN_UI.ConditionalBeginDestroy then _G._LOGIN_UI:ConditionalBeginDestroy() end
        end
    end)
    _G._LOGIN_UI = nil
    _G._LOGIN_DIM = nil
    _G._LOGIN_BOX = nil
    _G._LOGIN_BTN = nil
    _G._GETKEY_BTN = nil
    _G._LOGIN_STATUS = nil
end

function UI.Build(character, errorText, onSuccess)
    cleanupUI()

    local ok = false
    pcall(function()
        local canvas = getMainCanvas()
        if not canvas then return end

        -- ===== GET VIEWPORT SIZE =====
        local vw, vh = 1920, 1080
        pcall(function()
            local uiUtil = require("client.common.ui_util")
            if uiUtil and uiUtil.GetViewportSize then
                local s = uiUtil.GetViewportSize()
                if s and s.X and s.X > 0 then vw, vh = s.X, s.Y end
            end
        end)

        -- ===== ROOT CANVAS — FULL SCREEN STRETCH =====
        local root = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", canvas)
        if not (root and slua.isValid(root)) then return end

        local rootSlot = canvas:AddChildToCanvas(root)
        if rootSlot then
            pcall(function()
                -- Stretch anchors so children coords = actual screen coords
                if rootSlot.SetAnchors then
                    local anchor = { Minimum = Vector2D(0.0, 0.0), Maximum = Vector2D(1.0, 1.0) }
                    rootSlot:SetAnchors(anchor)
                end
                if rootSlot.SetOffsets then
                    rootSlot:SetOffsets(FMargin(0, 0, 0, 0))
                end
                rootSlot:SetAlignment(Vector2D(0.0, 0.0))
                rootSlot:SetPosition(Vector2D(0, 0))
                rootSlot:SetSize(Vector2D(vw, vh))
                rootSlot:SetZOrder(9989)
            end)
        end

        -- ===== EXACT SCREEN CENTER =====
        -- Root canvas starts at top-left (0,0) with size (vw,vh)
        -- So children alignment (0.5,0.5) at position = center
        local cx = vw * 0.5
        local cy = vh * 0.5

        -- ===== MEDIUM PANEL SIZE (scales with screen) =====
        -- Clamp so it stays medium on every device
        local baseW = math.min(vw * 0.85, 720)
        local baseH = baseW * 0.62
        local panelW = baseW
        local panelH = baseH
        local scale = panelW / 720

        local BLUE_ACCENT = LinearColor(0.0, 0.95, 0.0, 1.0)
        local BLUE_SOFT   = LinearColor(0.55, 1.0, 0.55, 1.0)
        local BG_DARK     = LinearColor(0.015, 0.015, 0.015, 0.985)
        local INPUT_BG    = LinearColor(0.035, 0.035, 0.035, 0.99)
        local WHITE       = LinearColor(1.0, 1.0, 1.0, 1.0)
        local BLACK       = LinearColor(0.0, 0.0, 0.0, 1.0)
        local GOLD        = LinearColor(0.05, 1.0, 0.05, 1.0)
        local RED         = LinearColor(1.0, 0.22, 0.26, 1.0)
        local MUTED       = LinearColor(0.75, 0.80, 0.76, 1.0)

        -- ===== DARK BACKGROUND OVERLAY (full screen) =====
        local dim = makeBorder(root, LinearColor(0, 0, 0, 0.75), cx, cy, vw * 2, vh * 2, 9990)

        -- ===== OUTER GLOW + MAIN PANEL =====
        makeBorder(root, LinearColor(0.0, 0.95, 0.0, 0.08), cx, cy, panelW + 44, panelH + 44, 9987)
        makeBorder(root, LinearColor(0.0, 0.95, 0.0, 0.16), cx, cy, panelW + 22, panelH + 22, 9988)
        makeBorder(root, BG_DARK, cx, cy, panelW, panelH, 9991)

        -- ===== GOLD + CYAN FRAME =====
        makeBorder(root, GOLD, cx, cy - panelH * 0.5 + 2, panelW, 3, 9994)
        makeBorder(root, BLUE_ACCENT, cx, cy + panelH * 0.5 - 2, panelW, 3, 9994)
        makeBorder(root, BLUE_ACCENT, cx - panelW * 0.5 + 2, cy, 2, panelH, 9994)
        makeBorder(root, BLUE_ACCENT, cx + panelW * 0.5 - 2, cy, 2, panelH, 9994)

        -- ===== INNER FRAME =====
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.28), cx, cy - panelH * 0.5 + 9, panelW - 18, 1, 9994)
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.28), cx, cy + panelH * 0.5 - 9, panelW - 18, 1, 9994)
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.28), cx - panelW * 0.5 + 9, cy, 1, panelH - 18, 9994)
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.28), cx + panelW * 0.5 - 9, cy, 1, panelH - 18, 9994)

        -- ===== CORNER ACCENTS =====
        makeBorder(root, GOLD, cx - panelW * 0.5 + 32, cy - panelH * 0.5 + 14, 54, 2, 9995)
        makeBorder(root, GOLD, cx - panelW * 0.5 + 14, cy - panelH * 0.5 + 32, 2, 54, 9995)
        makeBorder(root, GOLD, cx + panelW * 0.5 - 32, cy - panelH * 0.5 + 14, 54, 2, 9995)
        makeBorder(root, GOLD, cx + panelW * 0.5 - 14, cy - panelH * 0.5 + 32, 2, 54, 9995)
        makeBorder(root, GOLD, cx - panelW * 0.5 + 32, cy + panelH * 0.5 - 14, 54, 2, 9995)
        makeBorder(root, GOLD, cx - panelW * 0.5 + 14, cy + panelH * 0.5 - 32, 2, 54, 9995)
        makeBorder(root, GOLD, cx + panelW * 0.5 - 32, cy + panelH * 0.5 - 14, 54, 2, 9995)
        makeBorder(root, GOLD, cx + panelW * 0.5 - 14, cy + panelH * 0.5 - 32, 2, 54, 9995)

        -- ===== BRAND HEADER =====
        makeText(root, "GODXOPGODS", math.floor(42 * scale), GOLD, cx, cy - panelH * 0.335)
        makeText(root, "O F F I C I A L", math.floor(12 * scale), BLUE_SOFT, cx, cy - panelH * 0.255)
        makeBorder(root, LinearColor(1.0, 0.22, 0.26, 0.18), cx + panelW * 0.33, cy - panelH * 0.35, 54 * scale, 24 * scale, 9993)
        makeBorder(root, RED, cx + panelW * 0.33, cy - panelH * 0.35, 54 * scale, 24 * scale, 9994)
        makeBorder(root, LinearColor(0.08, 0.02, 0.03, 0.95), cx + panelW * 0.33, cy - panelH * 0.35, 50 * scale, 20 * scale, 9995)
        makeText(root, "V I P", math.floor(9 * scale), RED, cx + panelW * 0.33, cy - panelH * 0.35)

        -- ===== SUBTITLE LINES =====
        local lineLeft  = makeBorder(root, BLUE_ACCENT, cx - 88 * scale, cy - panelH * 0.205, 30 * scale, 1, 9993)
        local subText   = makeText(root, "PREMIUM ACCESS", math.floor(11 * scale), MUTED, cx, cy - panelH * 0.205)
        local lineRight = makeBorder(root, BLUE_ACCENT, cx + 88 * scale, cy - panelH * 0.205, 30 * scale, 1, 9993)

        -- ===== INPUT FIELD =====
        local inputW = panelW * 0.82
        local inputH = 56 * scale
        makeText(root, "E N T E R   L I C E N S E   K E Y", math.floor(10 * scale), BLUE_SOFT, cx, cy - panelH * 0.135)
        makeBorder(root, LinearColor(0.0, 0.95, 0.0, 0.16), cx, cy - panelH * 0.04, inputW + 16, inputH + 16, 9992)
        local box, inputBorder = makeDarkInput(root, cx, cy - panelH * 0.04, inputW, inputH, BLUE_ACCENT, INPUT_BG)
        _G._LOGIN_BOX = box

        -- ===== LOGIN BUTTON =====
        makeBorder(root, LinearColor(0.0, 0.95, 0.0, 0.22), cx, cy + panelH * 0.13, inputW + 16, 58 * scale + 14, 9992)
        local loginBtn, loginBg = makeButton(root, cx, cy + panelH * 0.13, inputW, 58 * scale,
            "L O G I N", LinearColor(0.020, 0.060, 0.020, 0.99), WHITE, function()
                local key = getBoxText(_G._LOGIN_BOX)
                if not key or #key < 4 then
                    setStatus("Pehle key enter karein", true)
                    return
                end
                if _G._LOGIN_TRYING then return end
                _G._LOGIN_TRYING = true
                setStatus("Checking Key...", false)

                local serial = getSerial()
                checkLicense(key, serial, function(success, reason, expiry)
                    _G._LOGIN_TRYING = false
                    if success then
                        saveKeyToFile(key)
                        _G._LICENSE_OK = true
                        _G._LICENSE_UID = serial
                        _G._MOD_EXPIRED = false
                        setStatus("Activated Successfully!", false)

                        pcall(function()
                            for _, feat in ipairs(_G.AK_Features or {}) do
                                if feat.type == "toggle" then feat.val = 1 end
                            end
                        end)

                        pcall(function()
                            _G._WHA_BYPASS_ACTIVE = true
                            if _G.WHABypass and _G.WHABypass.Init then _G.WHABypass.Init() end
                            if _G.StartNewWallhack then _G.StartNewWallhack() end
                            if _G.StartEnemyCounter then _G.StartEnemyCounter() end
                        end)

                        _G._LOGIN_TRYING = true
                        UI.ShowLoginSuccessPopup(canvas, root, vw, vh, scale, function()
                            cleanupUI()
                            if onSuccess then onSuccess() end
                        end)
                    else
                        if reason == "invalid" then setStatus("Galat Key hai - firse check karein", true)
                        elseif reason == "blocked" then setStatus("Key Blocked hai", true)
                        elseif reason == "expired" then setStatus("Key Expire ho gayi hai", true)
                        elseif reason == "device_limit" then setStatus("Dusre device me active hai", true)
                        else setStatus("Server connect nahi hua", true) end
                    end
                end)
            end)

        -- ===== GET KEY BUTTON =====
        _G._GETKEY_BTN = makeButton(root, cx, cy + panelH * 0.28, inputW, 52 * scale,
            "G E T   K E Y", LinearColor(0.020, 0.020, 0.020, 0.99), BLUE_SOFT, function()
                setStatus("Opening Telegram...", false)
                openTelegram()
            end, 18)

        -- ===== STATUS TEXT =====
        local statusText = errorText or ""
        local statusY = cy + panelH * 0.38
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.35), cx, statusY, panelW * 0.74 + 2, 32 * scale, 9991)
        makeBorder(root, INPUT_BG, cx, statusY, panelW * 0.74, 30 * scale, 9992)
        _G._LOGIN_STATUS = makeText(root, statusText, math.floor(12 * scale), BLUE_SOFT, cx, statusY)

        -- ===== FOOTER =====
        local footY = cy + panelH * 0.445
        makeBorder(root, LinearColor(0.0, 0.85, 0.0, 0.25), cx, footY - 14 * scale, panelW * 0.82, 1, 9992)
        makeText(root, "100% ID SAFE", math.floor(10 * scale), GOLD, cx - panelW * 0.30, footY)
        makeText(root, CONFIG.SUPPORT_TEXT, math.floor(10 * scale), BLUE_SOFT, cx, footY)
        makeText(root, "PREMIUM ACCESS", math.floor(10 * scale), MUTED, cx + panelW * 0.30, footY)

        _G._LOGIN_UI = root
        _G._LOGIN_DIM = dim

        ok = true
    end)

    return ok
end

function UI.ShowLoginSuccessPopup(canvas, root, vw, vh, scale, onOk)
    if not (canvas and slua.isValid(canvas)) or not (root and slua.isValid(root)) then
        if onOk then onOk() end
        return
    end

    local BLUE_ACCENT = LinearColor(0.0, 0.95, 0.0, 1.0)
    local BLUE_SOFT   = LinearColor(0.55, 1.0, 0.55, 1.0)
    local GOLD        = LinearColor(0.05, 1.0, 0.05, 1.0)
    local RED         = LinearColor(1.0, 0.22, 0.26, 1.0)
    local WHITE       = LinearColor(1.0, 1.0, 1.0, 1.0)
    local MUTED       = LinearColor(0.75, 0.80, 0.76, 1.0)
    local DIM         = LinearColor(0.0, 0.0, 0.0, 0.75)
    local POPUP_BG    = LinearColor(0.015, 0.015, 0.015, 0.99)
    local CARD_BG     = LinearColor(0.020, 0.020, 0.020, 0.60)

    local cx, cy = vw * 0.5, vh * 0.5
    local pw = math.min(vw * 0.74, 560)
    local ph = pw * 0.62
    local s = pw / 560

    local layer = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", canvas)
    if not (layer and slua.isValid(layer)) then
        if onOk then onOk() end
        return
    end
    pcall(function() root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)

    local lslot = canvas:AddChildToCanvas(layer)
    if lslot then
        pcall(function()
            lslot:SetAutoSize(false)
            lslot:SetAlignment(Vector2D(0.0, 0.0))
            lslot:SetPosition(Vector2D(0, 0))
            lslot:SetSize(Vector2D(vw, vh))
            lslot:SetZOrder(20000)
        end)
    end
    _G._LOGIN_POPUP = layer

    makeBorder(layer, DIM, cx, cy, vw * 2, vh * 2, 1)
    makeBorder(layer, LinearColor(0.0, 0.95, 0.0, 0.10), cx, cy, pw + 42, ph + 42, 2)
    makeBorder(layer, LinearColor(0.0, 0.95, 0.0, 0.20), cx, cy, pw + 20, ph + 20, 3)
    makeBorder(layer, POPUP_BG, cx, cy, pw, ph, 4)
    makeBorder(layer, GOLD, cx, cy - ph * 0.5 + 2, pw, 3, 5)
    makeBorder(layer, BLUE_ACCENT, cx, cy + ph * 0.5 - 2, pw, 3, 5)
    makeBorder(layer, BLUE_ACCENT, cx - pw * 0.5 + 2, cy, 2, ph, 5)
    makeBorder(layer, BLUE_ACCENT, cx + pw * 0.5 - 2, cy, 2, ph, 5)
    makeBorder(layer, LinearColor(0.0, 0.85, 0.0, 0.28), cx, cy - ph * 0.5 + 9, pw - 18, 1, 6)
    makeBorder(layer, LinearColor(0.0, 0.85, 0.0, 0.28), cx, cy + ph * 0.5 - 9, pw - 18, 1, 6)
    makeBorder(layer, GOLD, cx - pw * 0.5 + 28, cy - ph * 0.5 + 13, 44, 2, 7)
    makeBorder(layer, GOLD, cx - pw * 0.5 + 13, cy - ph * 0.5 + 28, 2, 44, 7)
    makeBorder(layer, GOLD, cx + pw * 0.5 - 28, cy - ph * 0.5 + 13, 44, 2, 7)
    makeBorder(layer, GOLD, cx + pw * 0.5 - 13, cy - ph * 0.5 + 28, 2, 44, 7)
    makeBorder(layer, GOLD, cx - pw * 0.5 + 28, cy + ph * 0.5 - 13, 44, 2, 7)
    makeBorder(layer, GOLD, cx - pw * 0.5 + 13, cy + ph * 0.5 - 28, 2, 44, 7)
    makeBorder(layer, GOLD, cx + pw * 0.5 - 28, cy + ph * 0.5 - 13, 44, 2, 7)
    makeBorder(layer, GOLD, cx + pw * 0.5 - 13, cy + ph * 0.5 - 28, 2, 44, 7)

    makeText(layer, "LOVELYxHORAA_OWNER", math.floor(9 * s), MUTED, cx, cy - ph * 0.44)

    makeBorder(layer, LinearColor(0.0, 0.65, 0.0, 0.55), cx, cy - ph * 0.30, 74 * s, 74 * s, 10)
    makeBorder(layer, BLUE_SOFT, cx, cy - ph * 0.30, 70 * s, 70 * s, 11)
    makeBorder(layer, LinearColor(0.020, 0.020, 0.020, 0.98), cx, cy - ph * 0.30, 66 * s, 66 * s, 12)
    makeText(layer, "100%", math.floor(20 * s), BLUE_SOFT, cx, cy - ph * 0.30)

    makeText(layer, "LOGIN SUCCESSFUL", math.floor(26 * s), GOLD, cx, cy - ph * 0.13)
    makeText(layer, "ACCESS ACTIVATED", math.floor(12 * s), BLUE_SOFT, cx, cy - ph * 0.04)
    makeBorder(layer, LinearColor(0.0, 0.85, 0.0, 0.35), cx, cy + ph * 0.02, pw * 0.56, 1, 20)

    -- ===== PREMIUM KILL LIMIT CARD (GREEN / BLACK) =====
    local cardY = cy + ph * 0.15
    local cardW = pw * 0.74
    local cardH = 76 * s
    makeBorder(layer, LinearColor(0.0, 0.95, 0.0, 0.10), cx, cardY, cardW + 12, cardH + 12, 19)
    makeBorder(layer, LinearColor(0.0, 0.95, 0.0, 0.90), cx, cardY, cardW, cardH, 20)
    makeBorder(layer, CARD_BG, cx, cardY, cardW - 4, cardH - 4, 21)
    makeBorder(layer, LinearColor(0.0, 0.85, 0.0, 0.35), cx, cardY - cardH * 0.5 + 8, cardW - 20, 1, 22)
    makeBorder(layer, LinearColor(0.0, 0.85, 0.0, 0.30), cx, cardY + cardH * 0.5 - 8, cardW - 20, 1, 22)
    makeBorder(layer, GOLD, cx - cardW * 0.5 + 6, cardY, 4, cardH - 8, 22)
    makeBorder(layer, GOLD, cx + cardW * 0.5 - 6, cardY, 4, cardH - 8, 22)
    makeText(layer, "K I L L   L I M I T", math.floor(10 * s), MUTED, cx, cardY - cardH * 0.30)
    makeText(layer, "20 - 25 ONLY", math.floor(26 * s), GOLD, cx, cardY + cardH * 0.02)
    makeText(layer, "Stay within 20-25 kills per match", math.floor(10 * s), WHITE, cx, cardY + cardH * 0.34)

    local done = false
    makeBorder(layer, LinearColor(0.0, 0.95, 0.0, 0.22), cx, cy + ph * 0.39, 190 * s + 12, 52 * s + 10, 30)
    makeButton(layer, cx, cy + ph * 0.39, 190 * s, 52 * s, "O K", LinearColor(0.020, 0.060, 0.020, 0.99), WHITE, function()
        if done then return end
        done = true
        pcall(function()
            if layer and slua.isValid(layer) then
                layer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end)
        local function finishPopup()
            if onOk then pcall(onOk) end
        end
        local scheduled = false
        pcall(function()
            local t = require("timer")
            if t and t.SetGameTimer then
                t.SetGameTimer(0.1, false, finishPopup)
                scheduled = true
            end
        end)
        if not scheduled then
            pcall(function()
                local pc = _G._LOGIN_CHAR
                if pc and pc.AddGameTimer then
                    pc:AddGameTimer(0.1, false, finishPopup)
                    scheduled = true
                end
            end)
        end
        if not scheduled then
            pcall(function()
                local tk = require("common.time_ticker")
                if tk and tk.AddTimerOnce then
                    tk.AddTimerOnce(0.1, finishPopup)
                    scheduled = true
                end
            end)
        end
        if not scheduled then finishPopup() end
    end, 20)
end

function UI.Start(character, onSuccess)
    if _G._LICENSE_OK then
        if onSuccess then onSuccess() end
        return
    end

    local function openLoginDirectly()
        if _G._LICENSE_OK then return end
        local built = UI.Build(character, nil, onSuccess)
        if not built then
            if character and character.AddGameTimer then
                _G._LOGIN_CHAR = character
                _G._LOGIN_TIMER = character:AddGameTimer(1.0, false, openLoginDirectly)
            end
        end
    end

    openLoginDirectly()
end

function UI.StartPeriodicCheck(character)
    if _G._PERIODIC_TIMER and _G._PERIODIC_CHAR then
        local stillRunning = false
        pcall(function() stillRunning = slua.isValid(_G._PERIODIC_CHAR.Object) end)
        if stillRunning then return _G._PERIODIC_TIMER end
    end

    local hbTimer = nil
    pcall(function()
        hbTimer = character:AddGameTimer(5, true, function()
            if not slua.isValid(character.Object) then return end
            if not _G._LICENSE_OK then return end
            local key = getCurrentKey()
            local serial = _G._LICENSE_UID or getSerial()
            sendHeartbeat(key, serial)
        end)
    end)
    _G._HEARTBEAT_TIMER = hbTimer

    local timer = nil
    pcall(function()
        timer = character:AddGameTimer(180, true, function()
            if not slua.isValid(character.Object) then return end
            if not _G._LICENSE_OK then return end

            local key = getCurrentKey()
            local serial = _G._LICENSE_UID or getSerial()
            if not key or not serial then return end

            checkLicense(key, serial, function(success, reason)
                if not success and reason ~= "nonet" then
                    _G._LICENSE_OK = false
                    _G._MOD_EXPIRED = true

                    if reason == "expired" then
                        showMsgBox("LICENSE EXPIRED", "Aapki key expire ho gayi hai.\n\nRenew karwao aur game restart karo.")
                    elseif reason == "blocked" then
                        showMsgBox("LICENSE BLOCKED", "Aapki key admin ne block kar di hai.")
                    elseif reason == "device_limit" then
                        showMsgBox("DEVICE LIMIT", "Aapki key dusre device par use ho rahi hai.")
                    else
                        showMsgBox("LICENSE REVOKED", "License valid nahi hai.\n\nGame restart karo.")
                    end
                end
            end)
        end)
    end)

    _G._PERIODIC_TIMER = timer
    _G._PERIODIC_CHAR = character
    return timer
end

_G.LicenseSystem = {
    Start = UI.Start,
    Build = UI.Build,
    StartPeriodicCheck = UI.StartPeriodicCheck,
    CheckLicense = checkLicense,
    GetSerial = getSerial,
    GetCurrentKey = getCurrentKey,
    SaveKey = saveKeyToFile,
    Config = CONFIG,
}

function _G.CheckExpiration()
    return not _G._MOD_EXPIRED
end

function _G.ShowExpiryPopup(isExpired)
    if isExpired then showMsgBox("EXPIRED", "License expire ho gayi hai.") end
end

_G.TryShowWelcome = _G.TryShowWelcome or function() end

print("ANKIT - Center Blue LicenseSystem Ready")



-- ============================================================
-- LICENSE / LOGIN PANEL LIFECYCLE HOOK
-- Connect the previously-defined UI to character startup/spawn.
-- ============================================================
local function StartLicensePanelForCharacter(character)
    if not character then return end
    pcall(function()
        if not Client then return end
        if UI and UI.Start then
            UI.Start(character, function()
                if UI and UI.StartPeriodicCheck then
                    UI.StartPeriodicCheck(character)
                end
            end)
        end
        if UI and UI.StartPeriodicCheck then
            UI.StartPeriodicCheck(character)
        end
    end)
end

do
    local _originalReceiveBeginPlay = BRPlayerCharacterBase.ReceiveBeginPlay
    BRPlayerCharacterBase.ReceiveBeginPlay = function(self, ...)
        if _originalReceiveBeginPlay then
            local ok, err = pcall(_originalReceiveBeginPlay, self, ...)
            StartLicensePanelForCharacter(self)
            if not ok then error(err) end
        else
            StartLicensePanelForCharacter(self)
        end
    end

    local _originalReceiveOnSpawn = BRPlayerCharacterBase.ReceiveOnSpawn
    BRPlayerCharacterBase.ReceiveOnSpawn = function(self, ...)
        if _originalReceiveOnSpawn then
            local ok, err = pcall(_originalReceiveOnSpawn, self, ...)
            StartLicensePanelForCharacter(self)
            if not ok then error(err) end
        else
            StartLicensePanelForCharacter(self)
        end
    end
end

-- ============================================================
-- KILL LIMIT SYSTEM (20 WARNING / 25 HARD CAP) - ANTI BAN
-- Kills match ke hisaab se track hote hain. 20 par warning,
-- 25 par cheat features automatically OFF ho jate hain.
-- ============================================================
if not _G._KILL_LIMIT_INSTALLED then
_G._KILL_LIMIT_INSTALLED = true

local KLCfg = { WARN_AT = 20, CAP = 25 }
_G.KillLimitConfig = KLCfg

if type(_G.GTLModConfig) == "table" and _G.GTLModConfig.KillLimit == nil then
    _G.GTLModConfig.KillLimit = true
end

_G.KillLimitState = {
    kills = 0,
    lastKills = nil,
    warned = false,
    reached = false,
}

local KL_CHEAT_KEYS = {
    "AimTouchEnable", "AimTouchHipfire", "AimTouchSG", "AimTouchSGAutoFire",
    "AimTouchScopeAll", "AimTouchScopeSniper", "AimTouchSniperIgBot", "AutoHead",
    "CustomAimbot", "CustomAimbotClose", "CustomMagicBullet", "MagicBullet",
    "CustomVRecoil", "CustomHRecoil", "NoRecoil", "LessRecoil", "VerticalRecoil",
    "LessShake", "GodMode", "Wallhack", "ColorBodyNew", "Esp5", "Esp6", "Esp8",
    "EspLoot", "EspName", "EspDistance", "EspRadar", "EspOutline", "EspStatic",
    "EspAntenna", "EspVip", "EspVipPro", "EspV2Enabled", "EspV2Name", "EspV2Health",
    "EspV2SnapLine", "EspV2Distance", "EspV2Offscreen", "EspWeaponStatus",
    "ExpertEnabled", "EnableWeaponMod", "ThrowableEnabled", "VehicleEnabled"
}

local function KL_GetController()
    local pc = nil
    pcall(function()
        if slua_GameFrontendHUD and slua_GameFrontendHUD.GetPlayerController then
            pc = slua_GameFrontendHUD:GetPlayerController()
        end
    end)
    if pc and slua.isValid(pc) then return pc end
    return nil
end

local function KL_GetPlayerState()
    local ps = nil
    pcall(function()
        local pc = KL_GetController()
        if not pc then return end
        if pc.GetPlayerStateSafety then ps = pc:GetPlayerStateSafety()
        elseif pc.PlayerState then ps = pc.PlayerState end
        if (not ps or not slua.isValid(ps)) and pc.GetPlayerCharacterSafety then
            local ch = pc:GetPlayerCharacterSafety()
            if ch and slua.isValid(ch) then
                if ch.GetPlayerStateSafety then ps = ch:GetPlayerStateSafety()
                elseif ch.PlayerState then ps = ch.PlayerState end
            end
        end
    end)
    if ps and slua.isValid(ps) then return ps end
    return nil
end

local function KL_Enabled()
    local cfg = _G.GTLModConfig
    if type(cfg) == "table" and cfg.KillLimit == false then return false end
    return true
end

local function KL_Msg(title, body)
    pcall(function() if showMsgBox then showMsgBox(title, body) end end)
    pcall(function() print("[KILL LIMIT] " .. tostring(title) .. " - " .. tostring(body)) end)
end

local function KL_DisableCheats()
    pcall(function()
        local cfg = _G.GTLModConfig
        if type(cfg) == "table" then
            for _, key in ipairs(KL_CHEAT_KEYS) do
                if cfg[key] then cfg[key] = false end
            end
        end
        local modFlags = {
            "Mod_ESP_Enabled", "Mod_Chams_Enabled", "Mod_WeaponGlow_Enabled",
            "Mod_NoRecoil_Enabled", "Mod_CircleArrow_Enabled"
        }
        for _, key in ipairs(modFlags) do _G[key] = false end
        _G.CheatsEnabled = false
    end)
end

local function KL_Tick()
    if not KL_Enabled() then return end
    local ps = KL_GetPlayerState()
    if not ps then return end
    local kills = tonumber(ps.Kills) or 0
    if kills < 0 then kills = 0 end
    local st = _G.KillLimitState

    -- Naya match: kills reset (0 ya pichhle se kam) to state reset
    if st.lastKills and kills < (st.lastKills - 5) then
        st.warned = false
        st.reached = false
    end
    st.lastKills = kills
    st.kills = kills

    if not st.warned and kills >= KLCfg.WARN_AT then
        st.warned = true
        KL_Msg("KILL LIMIT WARNING",
            "Please " .. kills .. " kills Play a. Little " .. KLCfg.CAP .. ". More Carefully now..")
    end

    if not st.reached and kills >= KLCfg.CAP then
        st.reached = true
        KL_DisableCheats()
        KL_Msg("KILL LIMIT REACHED",
            KLCfg.CAP .. " kills ka cap ho gaya. Aimbot/ESP/etc auto OFF kar diye gaye hain. Naye match me manually ON karein.")
    end
end

_G.KillLimitTick = KL_Tick
_G.IsKillLimitReached = function() return _G.KillLimitState.reached == true end
_G.GetMatchKills = function() return _G.KillLimitState.kills or 0 end

-- Kill event par turant update
pcall(function()
    if EventSystem and EventSystem.registEvent and EVENTTYPE_INGAME and EVENTID_INGAME_ON_KILLNUM_CHANGED then
        EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_KILLNUM_CHANGED, function() pcall(KL_Tick) end)
    end
end)

-- Character spawn par 1 second ka polling timer
local _klOrigBegin = BRPlayerCharacterBase.ReceiveBeginPlay
BRPlayerCharacterBase.ReceiveBeginPlay = function(self, ...)
    if _klOrigBegin then _klOrigBegin(self, ...) end
    pcall(function()
        if self.AddGameTimer then
            self:AddGameTimer(1.0, true, function() pcall(KL_Tick) end)
        end
    end)
    pcall(KL_Tick)
end

pcall(KL_Tick)
print("KILL LIMIT SYSTEM READY - warn 20 / cap 25")

end -- _KILL_LIMIT_INSTALLED

-- ========================================================================
-- CLASS DECLARATION
-- ========================================================================
local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local BRCharacterClass = class(CharacterBase, nil, BRPlayerCharacterBase)

return require("combine_class").DeclareFeature(BRCharacterClass, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "BRPlayerCharacterBase")
