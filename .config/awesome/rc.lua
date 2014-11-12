-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/darkness/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

require("pomodoro")

-- ****************** user config function **********************
-- read config file
configf = io.open(awful.util.getdir("config") .. "/user.config")
config = configf:read("*a");

-- return config value from key
function get_config_value (key)
	local val = string.match (config, "iface=(.+)")
	return val
end
-- **************************************************************


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
--  awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    --tags[2] = awful.tag({ 2, 3, 4, 5, 6, 7, 8 }, 2, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })


mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}





-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock({ align = "right" })
mytextclock = awful.widget.textclock({ align = "right" }, " %a %d %b, %H:%M:%S ", 1)
mytextclock:buttons(awful.util.table.join(awful.button({}, 1,
	function()
		awful.util.spawn("calendarwidget")
	end)
))


----------------------- Helius widgets -------------------------

---------- dropbox icon ---------
--db_icon = widget({ type = "imagebox" })
--db_icon.image = image(awful.util.getdir("config") .. "/icons/dropbox/3/x.png")
--db_icon:add_signal("mouse::enter", function ()
--					local fd = io.popen("dropbox status", "r")		-- get dropbox status (you need put cli script "dropbox.py" to /usr/local/bin/dropbox  )
--					if not fd then
--							do return "no info" end
--					end
--					local db_text = fd:read("*a")
--					io.close(fd)
--					naughty.notify ({
--							text = db_text,
--							--title = "dropbox",
--							position = "bottom_right",
--							timeout = 5,
--							icon = awful.util.getdir("config") .. "/icons/dropbox/dropbox.png", -- path to dropbox icon for popup (~/.config/awesom/db_icon for me)
--							fg="#a0aaaa",
--							bg="#202525",
--							font= "terminus 9",
--							--width = 300,
--							border_width = 0
--					})
--			 end)


-------- turn on/off message from syslog -------
log_viewer = widget({ type = "textbox" })
log_viewer.text = "[SL]"
log_viewer:buttons(awful.util.table.join(
	awful.button({ }, 1, function ()  log_viewer_toggle () end)
))
log_viewer_show = "yes"

-- log_viewer button click handler
-- set global variable log_viewer_show 
function log_viewer_toggle ()
	if log_viewer_show == "yes" then
		log_viewer.text = "[<s>SL</s>]"
		log_viewer_show = "no"
	else
		log_viewer.text = "[SL]"
		log_viewer_show = "yes"
	end
end

--------- cpu load graph ---------------
cpugraph = awful.widget.graph()
cpugraph:set_width(25)
cpugraph:set_background_color('#0e0e0e')
cpugraph:set_color('#FF5656')
cpugraph:set_gradient_colors({ '#FF5656', '#666666', '#444444' })
cpugraph:set_max_value (100)
cpugraph:set_gradient_angle (0)

jiffies = {}
 function activecpu()
		 local s = ""
		 for line in io.lines("/proc/stat") do
				 local cpu, newjiffies = string.match(line, "(cpu\ )\ +(%d+)")
				 if cpu and newjiffies then
						 if not jiffies[cpu] then
								 jiffies[cpu] = newjiffies
						 end
						 --The string.format prevents your task list from jumping around 
						 --when CPU usage goes above/below 10%
						 --s = string.format("0.%02d", (newjiffies-jiffies[cpu])) 
						 s = string.format("%d", ((newjiffies-jiffies[cpu]))) 
						 jiffies[cpu] = newjiffies
				 end
		 end
		
		local fd = io.popen("grep -c '^processor' /proc/cpuinfo ")
		local data = fd:read("*all")
		fd:close()
		--naughty.notify ({text=data .. ":" .. s .. ":" .. s/data, timeout=10})	
		cpugraph:add_value(s/data)
 end


cpu_timer = timer({ timeout = 1 })
cpu_timer:add_signal("timeout", function() activecpu () end)
cpu_timer:start()



--------- network speed -----------------
tw_lan = widget({ type = "textbox", name = "tw_lan", align = "left" })
tw_lan.text = '0 Kb'

langraph = awful.widget.graph()
langraph:set_width(20)
langraph:set_background_color('#0e0e0e')
langraph:set_color('#5C47A1')
--langraph.set_scale (true)
--langraph:set_gradient_colors({ '#FF5656', '#666666', '#444444' })
langraph:set_max_value (200)
--langraph:set_scale (true)
langraph:set_gradient_angle (0)
langraph.widget:add_signal("mouse::enter", 				function () 				naughty.notify ({text=string.format("%d Kb/s", lastLanVal), timeout=2}) end)


lanValueArray = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
lanValueIndex = 1 -- index in lua begin from 1
lanOldRx = 0
lastLanVal = 0
lanFirstRun = 1

function activelan ()
	local fd = io.popen("ifconfig " .. get_config_value ("iface"))
	--local fd = io.popen("ifconfig wlan0")
	local ifconf = fd:read ("*all")
	local rx = string.match (ifconf, "RX bytes:([0-9]+)")
	local tx = string.match (ifconf, "TX bytes:([0-9]+)")
	lastLanVal = (rx+tx-lanOldRx)*8/1024
	lanOldRx = rx+tx
	if lanFirstRun == 1 then
		lanFirstRun = 0
	else
		langraph:add_value(lastLanVal)
	-- add new value to array
		lanValueArray [lanValueIndex] = lastLanVal
		lanValueIndex = lanValueIndex+1
		if (lanValueIndex > 20) then
			lanValueIndex = 1
		end
  -- calc max array value
	local maxVal = 0
	for i=1, 20 do
		if lanValueArray[i] > maxVal then
			maxVal = lanValueArray[i]
		end
	end
	
--	naughty.notify ({text = string.format("%d",maxVal)})

--		if maxVal <= 10 then
--			tw_lan.text = '10Kb'
--			langraph:set_max_value (10)
		if maxVal > 10 and maxVal <= 50 then
			tw_lan.text = '50Kb'
			langraph:set_max_value (50)
		elseif maxVal > 50 and maxVal <= 100 then
			tw_lan.text = '100Kb'
			langraph:set_max_value (100)
		elseif maxVal > 100 and maxVal <= 200 then
			tw_lan.text = '200Kb'
			langraph:set_max_value (200)
		elseif maxVal > 200 and maxVal <= 500 then
			tw_lan.text = '500Kb'
			langraph:set_max_value (500)
		elseif maxVal > 500 and maxVal <= 1000 then
			tw_lan.text = '1<span color="green">Mb</span>'
			langraph:set_max_value (1000)
		elseif maxVal > 1000 and maxVal <= 3000 then
			tw_lan.text = '3<span color="green">Mb</span>'
			langraph:set_max_value (3000)
		elseif maxVal > 3000 then
			tw_lan.text = '10<span color="green">Mb</span>'
			langraph:set_max_value (10000)
		else
			tw_lan.text = '10Kb'
			langraph:set_max_value (10)
		end
	end
end

lan_timer = timer({ timeout = 1 })
lan_timer:add_signal("timeout", function() activelan () end)
lan_timer:start()


--------- battery status -----------------
tw_battery = widget({ type = "textbox", name = "tw_battery", align = "center" })
tw_battery:buttons(awful.util.table.join(
	awful.button({ }, 1, function () battery_show_all () end)
))
	-- on click show all status
function battery_show_all ()
	local fd = io.popen("acpitool -B ")
	local status = fd:read("*all")
	fd:close()
	naughty.notify ({text=status, timeout=10})
end

	-- timers handler, periodically check status and set it to text widget
function battery_check ()

	local fd = io.popen("acpitool -B ")
	local status = fd:read("*all")
	fd:close()
	local mode = string.match(status, "Charging state%s+:%s+(%l*)%s")
	local time = string.match(status, "Remaining capacity.*(%d+:%d+:%d+)")
	
	if mode == 'charging' then
		tw_battery.text = '[<span color="green">' .. time .. '</span>]'
	elseif mode == 'discharging' then
		tw_battery.text = '[<span color="red">' .. time .. '</span>]'
			local hh, mm, ss = string.match (time, "(%d+):(%d+):(%d+)")
			if hh == "0" and mm < "10" then
				naughty.notify ({ hover_timeout = 0.2, timeout = 0, title = '<span color="red">Attention!</span>', text = 'battery time is ' .. time, font="terminus-12"})
			end
	else
		tw_battery.text = ''
	end
end

	-- timer for battery check
battery_timer = timer({ timeout = 3 })
battery_timer:add_signal("timeout", function() battery_check () end)
battery_timer:start()

-------- volume control widget -----------
cardid  = 0
channel = "Master"

function volume (mode, widget)
if mode == "update" then
						local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. channel)
						local status = fd:read("*all")
						fd:close()
	
	local volume = string.match(status, "(%d?%d?%d)%%")
	--volume = string.format("%3d", volume)

	status = string.match(status, "%[(o[^%]]*)%]")

	if string.find(status, "on", 1, true) then
		volume = " [" .. volume .. "%] "
	else
		volume = " [" .. volume .. "M] "
	end
	widget.text = volume

elseif mode == "up" then
	io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+"):read("*all")
	volume("update", widget)
elseif mode == "down" then
	io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-"):read("*all")
	volume("update", widget)
else
	io.popen("amixer -c " .. cardid .. " sset " .. channel .. " toggle"):read("*all")
	volume("update", widget)
end
end

tb_volume = widget({ type = "textbox", name = "tb_volume", align = "center" })
tb_volume:buttons(awful.util.table.join(
		awful.button({ }, 4, function () volume("up", tb_volume) end),
		awful.button({ }, 5, function () volume("down", tb_volume) end),
		awful.button({ }, 1, function () volume("mute", tb_volume) end)
	 ))
volume("update", tb_volume)

-------------------- helius: end ---------------------------







-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
				cpugraph.widget,
				tw_lan,
				langraph.widget,
				db_icon,
				log_viewer,
				tb_volume,
				tw_battery,
				pomodoro(),
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,  }, "`", function () awful.screen.focus_relative( 1) end),
--    awful.key({ modkey,  }, ",", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
		
		------------------------- Helius start. Call translater --------------------
		----- translater run
		awful.key({ modkey,  					}, "d", 
							function ()
										local fr = awful.util.pread("gtrans")
									  naughty.notify({  
											text = fr, 
											timeout = 15, 
											border_width = 0,
											position = "top_right",
											fg="#a0aaaa",
											bg="#202525",
											margin = 9,
											font = "terminus 10"
										})
    					end),
		----- past buffer to ProjectBox
		awful.key({ modkey,  					}, "p", 
							function ()
										local text_ = awful.util.pread("xclip -o | /home/eugene/.bin/pb")
									  naughty.notify({  
											text = text_, 
											timeout = 15, 
											border_width = 0,
											position = "top_right",
											fg="#a0faaa",
											bg="#202525",
											margin = 9,
											font = "terminus 10"
										})
										os.execute (text_ .."|xclip");
    					end),

		----- web seaarch run
		awful.key({ modkey }, "s", function ()
		      awful.prompt.run({ prompt = "Web search: " }, mypromptbox[mouse.screen].widget,
		      function (command)
		        awful.util.spawn("firefox 'http://www.google.com/search?q="..command.."'", false)
		        -- Switch to the web tag, where Firefox is, in this case tag 3
		        if tags[mouse.screen][3] then awful.tag.viewonly(tags[mouse.screen][3]) end
		            end)
			    end),

		----- firefox open selected link/open
		awful.key({ modkey }, "F3", function ()
					local fd = io.popen("xclip -o", "r")		-- get link from buffer
					if not fd then
							do return "no xclipt" end
					end
					local link = fd:read("*a")
					io.close(fd)

					if string.match(link, "http") or 
						string.match(link, "www") or 
						string.match(link, "ftp") or
						string.match(link, ".ru") or
						string.match(link, ".com") or
						string.match(link, ".org") or
						string.match(link, ".net") then
							awful.util.spawn("firefox " .. link .. "", false)
					else
		        --awful.util.spawn("firefox -no-remote", false)
					end
					end)
		---------------------------- Helius stop  -----------------------------------

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
--    awful.key({ modkey,           }, "p",      function () translate()    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "studio" },
      properties = { tag = tags[1][4] } },
	{ rule = { class = "VirtualBox" },
	  properties = { tag = tags[1][9] } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

----------------------- Helius start -----------------------------------------

		---------------- dropbox status icon -----------------

-- timer hook handler, just look on dropbox status and if it change, set icon, end show pop up
--function db_timer_hook ()
--	
--    local fd = io.popen("dropbox status", "r")		-- get dropbox status (you need put cli script "dropbox.py" to /usr/local/bin/dropbox  )
--    if not fd then
--        do return "no info" end
--    end
--    local db_text = fd:read("*a")
--    io.close(fd)
--		-- check that status is chenged
--		if (db_text ~= old_db_text) then
--			if string.match(db_text, "Idle") then
--				db_icon.image = image(awful.util.getdir("config") .. "/icons/dropbox/3/idle.png") -- path to yor dropbox icon
--			else
--				if string.match(db_text, "rror") or string.match(db_text, "isn't") or (string.match(db_text, "Connecting...")) then 
--					db_icon.image = image(awful.util.getdir("config") .. "/icons/dropbox/3/x.png")
--				else 
--					db_icon.image = image(awful.util.getdir("config") .. "/icons/dropbox/3/busy.png")
--				end
-- 					naughty.notify ({
-- 							text = db_text,
-- 							title = "dropbox",
-- 							position = "bottom_right",
-- 							timeout = 2,
-- 							icon = awful.util.getdir("config") .. "/icon/db_icon/dropbox.png", -- path to dropbox icon for popup (~/.config/awesom/db_icon for me)
-- 							fg="#a0aaaa",
-- 							bg="#202525",
-- 							width = 300,
-- 							font = "terminus 9",
-- 							border_width = 0
---- 					})
--					old_db_text = db_text;
--			end	
--		end
--end

-- timer create
--db_timer = timer({ timeout = 2 })
--db_timer:add_signal("timeout", function() db_timer_hook () end)
--db_timer:start()


    --------------------- log viewer ---------------------

function lv_timer_hook ()
	if log_viewer_show == "yes" then
		local f = io.open("/var/log/syslog")
		local l = f:read("*a")
		f:close ()

		if not len then
			len = #l
		else
			local diff = l:sub(len +1, #l -1)

		if (len ~= #l) then
			naughty.notify {
				title = '<span color="white">' .. "syslog" .. "</span>: " .. "/var/log/syslog",
				text = awful.util.escape(diff),
				hover_timeout = 0.2, timeout = 0,
			}
			end
			len = #l
		end
	end

end

-- timer create
lv_timer = timer({ timeout = 1 })
lv_timer:add_signal("timeout", function() lv_timer_hook () end)
lv_timer:start()

    --------------------- CPU graph ---------------------


------------------------- Helius end --------------------------------------

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- exec some command on start awesome fo example setting keyboard
os.execute("setxkbmap us,ru -option grp_led:caps,grp:caps_toggle &")
-- set KBD delay and repeate
os.execute("xset r rate 200 30 &")
-- set walpaper
-- os.execute("nohup feh -Z -F --bg-scale /home/eugene/Dropbox/.wallpapper/12.png &")
os.execute("hsetroot -solid '#202020'");
-- set candy-ice interface ))
os.execute("nohup xcompmgr -cC &")
--os.execute("nohup xrandr --output VGA1 --mode 1920x1080 --right-of HDMI1 &")
-- start virtual mashine with XP
-- os.execute("nohup VBoxManage startvm virtXP &")
os.execute("finchdbus &")
os.execute("ubuntuone-launch&")
