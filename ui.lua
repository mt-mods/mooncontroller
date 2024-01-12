-----------------------
-- Formspec creation --
-----------------------

function mooncontroller.update_formspec(pos)
	local meta = minetest.get_meta(pos)
	local code = minetest.formspec_escape(meta:get_string("code"))
	local errmsg = minetest.formspec_escape(meta:get_string("errmsg"))
	local tab = meta:get_int("tab")
	if tab < 1 or tab > 4 then tab = 1 end

	--Default theme settings
	local textcolor = "#ffffff"
	local bg_img = "jeija_luac_background.png"
	local run_img = "jeija_luac_runbutton.png"
	local close_img = "jeija_close_window.png"

	--If Dreambuilder's theming engine is in use, then override those
	if minetest.global_exists("dreambuilder_theme") then
		textcolor = dreambuilder_theme.editor_text_color
		bg_img = dreambuilder_theme.name.."_jeija_luac_background.png"
		run_img = dreambuilder_theme.name.."_jeija_luac_runbutton.png"
		close_img = dreambuilder_theme.name.."_jeija_close_window.png"
	end

	local fs = "formspec_version[4]"
		.."size[15,12]"
		.."style_type[label,textarea,field;font=mono]"
		.."style_type[textarea;textcolor="..textcolor.."]"
		.."background[0,0;15,12;"..bg_img.."]"
		.."tabheader[0,0;tab;Code,Terminal,Help,Examples;"..tab.."]"
		.."image_button_exit[14.5,0;0.425,0.4;"..close_img..";exit;]"

	if tab == 1 then
		--Code tab
		fs = fs.."label[0.1,10;"..errmsg.."]"
			.."textarea[0.25,0.6;14.5,9.05;code;;"..code.."]"
			.."image_button[6.25,10.25;2.5,1;"..run_img..";program;]"
	elseif tab == 2 then
		--Terminal tab
		local termtext = minetest.formspec_escape(meta:get_string("terminal_text"))
		fs = fs.."textarea[0.25,0.6;14.5,9.05;;;"..termtext.."]"
			.."field[0.25,9.85;12.5,1;terminal_input;;]"
			.."button[12.75,9.85;2,1;terminal_send;Send]"
			.."button[12.75,10.85;2,1;terminal_clear;Clear]"
			.."field_close_on_enter[terminal_input;false]"
	elseif tab == 3 then
		--Help tab
		fs = fs..mooncontroller.lc_docs.generate_help_formspec(meta:get_int("help_selidx"))
	elseif tab == 4 then
		--Examples tab
		fs = fs..mooncontroller.lc_docs.generate_example_formspec(meta:get_int("example_selidx"))
			.."image_button[6.25,10.25;2.5,1;"..run_img..";program_example;]"
	end

	meta:set_string("formspec",fs)
end


function mooncontroller.on_receive_fields(pos, _, fields, sender)
	local meta = minetest.get_meta(pos)
	if fields.tab then
		meta:set_int("tab",fields.tab)
		mooncontroller.update_formspec(pos)
	else
		local tab = meta:get_int("tab")
		if tab < 1 or tab > 4 then tab = 1 end
		if tab == 1 then
			--Code tab
			if not fields.program then
				return
			end
			local name = sender:get_player_name()
			if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, {protection_bypass=true}) then
				minetest.record_protection_violation(pos, name)
				return
			end
			meta:set_string("terminal_text","")
			local ok, err = mooncontroller.set_program(pos, fields.code)
			if not ok then
				-- it's not an error from the server perspective
				minetest.log("action", "Lua controller programming error: " .. tostring(err))
			end
		elseif tab == 2 then
			--Terminal tab
			if fields.exit or fields.quit then return end
			local name = sender:get_player_name()
			if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, {protection_bypass=true}) then
				minetest.record_protection_violation(pos, name)
				return
			end
			if fields.terminal_clear then
				mooncontroller.terminal_clear(pos)
				mooncontroller.update_formspec(pos)
				return
			end
			mooncontroller.run(pos,{type="terminal",text=fields.terminal_input})
		elseif tab == 3 then
			--Help tab
			if fields.help_list then
				local event = minetest.explode_textlist_event(fields.help_list)
				if event.type == "CHG" then
					meta:set_int("help_selidx",event.index)
					mooncontroller.update_formspec(pos)
				end
			end
		elseif tab == 4 then
			--Examples tab
			if fields.example_list then
				local event = minetest.explode_textlist_event(fields.example_list)
				if event.type == "CHG" then
					meta:set_int("example_selidx",event.index)
					mooncontroller.update_formspec(pos)
				end
			elseif fields.program_example then
				local name = sender:get_player_name()
				if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, {protection_bypass=true}) then
					minetest.record_protection_violation(pos, name)
					return
				end
				local selidx = meta:get_int("example_selidx")
				selidx = math.max(1,math.min(selidx,#mooncontroller.lc_docs.example_order))
				local code = mooncontroller.lc_docs.examples[mooncontroller.lc_docs.example_order[selidx]]
				meta:set_string("terminal_text","")
				meta:set_int("tab",1)
				mooncontroller.set_program(pos,code)
			end
		end
	end
end
