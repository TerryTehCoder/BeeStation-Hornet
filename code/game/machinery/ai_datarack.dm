/******************************************A.I Dataracks.*************************************/
//Meant to help recreate more relation to a Computer System, rather than just a box that opens doors and shouts at people.
//I put like, two-three days of work into this, feel free to expand it, or update to a UI. 

/obj/machinery/ai_datarack
	name = "A.I Data-Terminal"
	desc = "A hybrid remote/physical data storage terminal for A.I functions. Requires a head level Identification to access."
	icon = 'icons/obj/monitors.dmi' 
	icon_state = "ai_datarack" //I encourage you to work on, and improve, my trashy sprites :D
	layer = ABOVE_WINDOW_LAYER
	plane = FLOOR_PLANE
	max_integrity = 350
	armor = list("melee" = 70, "bullet" = 100, "laser" = 30, "energy" = 20, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 20, "stamina" = 0)
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	power_channel = AREA_USAGE_EQUIP
	req_access = list(ACCESS_HEADS)
	var/coverstatus = 0 //Cover secured or unsecured? 
	var/screws = 0 //Screws inplace?
	var/pried = 0 //Glass pried inplace?
	var/chipsexposed = 0 //Datachips Exposed?
	var/chipstatus = 1 //Is the datachip transmitting its data to the terminal?
	var/chip = 0 //One chip per terminal. Balance reasons.
	var/chipinstalled = 1 //Is there a datachip in the terminal? 
	var/maintenencecycle = 0 //Is there a maintenence cycle in progress? Disallows some other functions. Such as closing the cover.
	var/rackstage = 1 //Used to update icons for various functions.
	var/maintenencerecordedlength //How long is the current maintenence cycle? Used for A.I Selection. Like Maintenencelength, but updated seperately.
	var/emagged = 0 //Has the terminal been emagged?
	
	//Variables to prevent the same negative chip disable effect from activating twice.
	var/LinguisticsFail = 0
	var/VisualFail = 0
	var/PowerDistroFail = 0
	var/IdentificationFail = 0
	var/SubsystemFail = 0

	//Variables to determine if we're extracting or disabling a chip. Can't do both at the same time. 
	var/extracting = 0 //Is the datachip in the process of being Extracted?
	var/disabling = 0 //Misleading, you could be toggling it back online and it would temporarily set this to 1. Still works.
	var/maintenencing = 0	//Maintenencing? Maintinencing

/obj/item/wallframe/ai_datarack //Note to self, Fix orientation on wall.
	name = "AI Data-terminal Frame"
	desc = "Used for building AI Data Terminals."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "ai_datarack_wall" 
	result_path = /obj/machinery/ai_datarack 

/obj/machinery/ai_datarack/update_icon()
	switch(rackstage)
		if(1)
			icon_state = "ai_datarack"
		if(2)
			icon_state = "ai_datarack_maint"
		if(3)
			icon_state = "ai_datarack_emagged"

/obj/machinery/ai_datarack/examine(mob/user)
	.=..()
	if(!coverstatus)
		. += "<span class='notice'>A red light on the panel is blinking. It appears to be locked.</span>"
	else
		. += "<span class='notice'>A green light on the panel is blinking. It appears to be unlocked.</span>"
		if(chipsexposed)
			. += "<span class='notice'>There is a [chipstatus ? "white" : "blank"] light above the [chipinstalled ? "datachip" : "empty chip slot"].</span>" //Normally i'd just use one to show the chip is missing, but we need to be able to see if the chip is offline and installed later.
		if(maintenencecycle)
			. += "<span class='notice'>There is a yellow light blinking next to the Maintenence LED"
		if(emagged)
			. += "<span class='notice>The LED's are frayed, and the display is scrambled.</span>"

			

/obj/machinery/ai_datarack/attackby(obj/item/A, mob/user, params, attack_hand)
	if(istype(A, /obj/item/card/id))
		if(check_access(A) && !screws && !pried) //We make sure the screws and cover are in place before securing. 
			coverstatus = !coverstatus
			visible_message("<span class='notice'>You [coverstatus ? "release" : "seal"] the devices securing bolts.")
		else
			visible_message("<span class='warning'>The device buzzes. Sitting idly.</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 35) 
			say("<span class='warning'>Credentials unverified or maintenence panel unsecured. Please review machinery.</span>", "<span class='notice'>The Datarack buzzes.</span>") //Regular, and Deaf.
			var/turf/T = get_turf(src)
			for(var/mob/living/silicon/ai/AI in GLOB.player_list)
				if(T.loc)
					to_chat(AI, "<font color = red><b>Network Alert: Unauthorized access codes transmitted to A.I Datarack at [T.loc] .</b></font>")
				else
					to_chat(AI, "<font color = red><b>Network Alert: Unauthorized access codes transmissed to A.I Datarack. Locational Transponder Offline.</b></font>")
	if(istype(A, /obj/item/aidatachip))
		if(!chipinstalled) //Reinstalling the datachip if it's been removed
			if(user.transferItemToLoc(A, src))
				playsound(loc, 'sound/items/screwdriver2.ogg', 35)
				chipinstalled = 1
				chipstatus = 1
				visible_message("<span class='notice'You reinstall the datachip into the Terminal.")
				return
	else //Maintenence, tool interactions, releasing cover, anything that's not unlocking the Rack.
		if(!coverstatus)
			if(A.tool_behaviour) 
				visible_message("<span class='notice'>[A] can't reach any components through the locked glass.</span>")
		else  //unlocked
			if(A.tool_behaviour == TOOL_SCREWDRIVER && !pried && !maintenencecycle && coverstatus)
				screws = !screws
				visible_message("<span class='notice'>You [screws ? "unscrew" : "screw in"] the securing screws holding the window down.</span>")
				playsound(loc, 'sound/items/screwdriver.ogg', 25)
			if(A.tool_behaviour == TOOL_CROWBAR && screws && !maintenencecycle && coverstatus)
				pried = !pried
				chipsexposed = !chipsexposed //Better to keep "pry out" and "exposing the chips" in sync imo, var/chipsexposed is used later.
				playsound(loc, 'sound/items/crowbar.ogg', 25)
				visible_message("<span class='notice'>You [pried ? "pry out" : "pry in"] the window, [pried ? "exposing the datachips" : "concealing the datachips"].</span>")
			if(chipsexposed && screws && pried && coverstatus && !maintenencecycle)
				var/terminalprompt = alert(usr, "Warning: Some system functions may be logged to Station A.I. What would you like to do?", "A.I Datarack Terminal","Datachip Extraction", "Maintenence Options", "Cancel")
				switch(terminalprompt)
					if("Datachip Extraction")
						if(chipinstalled && !disabling)
							extracting = 1
							say("Datachip Extraction in progress, please standby.")
							sleep(300) //Can't let someone run into an unlocked terminal, press extract, and just fly out in the span of 5 seconds.
							var/turf/B = get_turf(src) //Where should we put the datachip?
							chipinstalled = 0
							chipstatus = 0
							chip = new /obj/item/aidatachip(B)
							chipdisabled()
							say("Datachip Extraction Successful! Logging event to active Station A.I's in fifteen seconds.")
							extracting = 0
							sleep(150)
							for(var/mob/living/silicon/ai/AI in GLOB.player_list)
								if(B.loc)
									to_chat(AI, "<font color = red><span class='Warning'><b>Warning: A.I Datarack chip extracted at [B.loc]. Some systems may not function as intended.</span></b></font>")
								else
									to_chat(AI,"<font color = red><span class='Warning'><b>Warning: A.I Datarack chip extracted. Datarack Locational Coordinates unavailable. Some systems may not function as intended.</span></b></font>") //We should probably never have this happen at an unknown location. But..best be safe.
							say("Extraction logged to Active Station A.I's.")		
						else if(!chipinstalled)
							say("No Datachip present. Please refer to instructional booklet.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
						else
							say("System buffer occupied. Cannot extract while datachip functions are being toggled.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
					if("Maintenence Options")
						var/terminalmaintprompt = alert(usr, "What would you like to do?", "Maintenence Options", "Toggle Datachip Status", "Maintenence Cycle", "Cancel")
						switch(terminalmaintprompt)
							if("Toggle Datachip Status") //Turn the installed datachip on/off, for teasing the A.I.
								if(chipinstalled && !extracting)
									disabling = 1
									say("Datachip stream [chipstatus ? "reconnecting" : "disconnecting"]. Please standby.")
									sleep(150)
									chipstatus = !chipstatus
									chipdisabled()
									visible_message("<span class='notice'>You toggle the datachip [chipstatus ? "online" : "offline"]</span>")
									say("Datachip toggled [chipstatus ? "online" : "offline"]. Compiling error report for active Station A.I's in thirty seconds. Please log any unexpected effects for research.")
									disabling = 0
									sleep(300)
									var/turf/B = get_turf(src)
									for(var/mob/living/silicon/ai/AI in GLOB.player_list)
										if(B.loc)
											to_chat(AI, "<font color = red><span class='Warning'><b>Warning:A.I Datarack chip data transfer [chipstatus ? "reconnected" : "disconnected"] at [B.loc]. Some functions may be impeded.</font>")
										else
											to_chat(AI, "<font color = red><span class='Warning'><b>Warning: A.I Datarack chip data transfer [chipstatus ? "reconnected" : "disconnected"] at an unknown location. Some functions may be impeded.</font>")
								else if(!chipinstalled)
									say("No Datachip present. Please refer to instructional booklet.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
								else
									say("System buffer occupied. Cannot toggle while datachip extraction is in progress.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)

							if("Maintenence Cycle") //Clears Emag display, and an excellent way to prevent access to a terminal for 60 seconds.
								if(!disabling && !extracting)
									disabling = 1
									extracting = 1
									maintenencecycle = !maintenencecycle	
									visible_message("<span class='notice'You enable a maintenence cycle on the Datachip.")
									rackstage = 2
									update_icon()
									say("Maintenence Cycle enabled. Cover position locked. Please standby")
									sleep(600)
									say("Maintenence Cycle terminated. Cover position unlocked.")
									rackstage = 1
									update_icon()
									maintenencecycle = !maintenencecycle
									emagged = 0
									disabling = 0
									extracting = 0
								else if(disabling)
									say("Error: Cannot initiate maintenence cycle during datachip toggle procedure.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
								else
									say("Error: Cannot initiate maintenence cycle during datachip extraction procedure.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
							if("Cancel")
								return
					if("Cancel")
						return

/obj/machinery/ai_datarack/attack_ai(mob/user) //The same thing above, but all over, for the A.I, with special interactions.
	var/simpleturing //This is a joke, there is no wrong answer. Nanotrasen isn't very concerned with remote security...Lazy Bastards..
	var/simpleturinganswers1
	var/simpleturinganswers2
	var/simpleturinganswers3
	simpleturing = pick("Assistant", "Felenid", "Atmospherics", "Bar", "Medical Bay", "Security", "AI", "Evacuation Shuttle")
	simpleturinganswers1 = pick("Toolbox", "Chocolate", "Plasma", "Screwdriver Cocktail", "Cryopod", "Stun Baton", "Correlation Tests", "Evacuation")
	simpleturinganswers2 = pick("Stunprod", "Tail Wagging", "Pipelines", "Antihol", "Stasis Bed", "Brig", "Computer Systems", "Shuttle Engines")
	simpleturinganswers3 = pick("Gas Mask", "Cats", "Heat", "Inebriation", "Virology", "Orange Jumpsuit", "Security Camera", "Death")
	if(!maintenencecycle)
		var/turingprompt = alert(usr, "Remote access attempt detected. Please confirm your organic status. Select correlation.", "Organic Verification", "Continue", "Cancel")
		switch(turingprompt)
			if("Continue")
				alert(usr, "[simpleturing]", "Correlation Diagnostic", "[simpleturinganswers1]", "[simpleturinganswers2]", "[simpleturinganswers3]")
				alert(usr, "Organic Verification passed! Welcome User.", "Correlation Diagnostic")
				var/terminalpromptai = alert(usr, "Warning: Some system functions may be logged to Station A.I. What would you like to do?", "A.I Datarack Terminal", "Datachip Extraction", "Maintenence Options", "Cancel")
				switch(terminalpromptai)
					if("Datachip Extraction")
						if(chipinstalled && !disabling)
							var/extractconfirm = alert(usr, "Are you sure you want to extract the datachip? Remote systems may be impeded.", "Verification", "Yes", "No")
							switch(extractconfirm)
								if("Yes")
									extracting = 1
									to_chat(usr, "<span class='notice'>Datachip Extraction in progress, remote user authenticated, bypassing seal verification. Datachip Extracted Successfully!</span>") 
									var/turf/B = get_turf(src)
									chipinstalled = 0
									chipstatus = 0
									chip = new /obj/item/aidatachip(B)
									extracting = 0
									chipdisabled()
									for(var/mob/living/silicon/ai/AI in GLOB.player_list)
										if(B.loc)
											to_chat(AI, "<font color='red'><span class='Warning'><b>Warning: A.I Datarack chip extracted at [B.loc]. Some systems may not function as intended.</span></b></font>")
										else
											to_chat(AI,"<font color='red'><span class='Warning'><b>Warning: A.I Datarack chip extracted. Datarack Locational Coordinates unavailable. Some systems may not function as intended.</span></b></font>") //We should probably never have this happen at an unknown location. But..best be safe.
									say("Extraction logged to Active Station A.I's.") //Reminder for the A.I, while the A.I Extracts it. Exemplifies the importance of the Chip.
								if("No")
									return
						else if(!chipinstalled)
							to_chat(usr, "No Datachip present. Please refer to instructional booklet.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
						else
							to_chat(usr, "<span class='notice'>System buffer occupied. Cannot extract while datachip functions are being toggled.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)

					if("Maintenence Options") //Maintenence Options, accessed by the A.I
						var/terminalmaintpromptai = alert(usr, "What would you like to do?", "Maintenence Options", "Toggle Datachip Functionality", "Maintenence Cycle", "Cancel")
						switch(terminalmaintpromptai)
							if("Toggle Datachip Functionality") //Turn the installed datachip on/off, if a law requires it, perhaps?
								if(chipinstalled && !extracting)
									var/streamdisconnectconfirm = alert(usr, "Are you sure you want to toggle the datachips status? (Disabling the datachip may impede some remote systems.", "Confirm?", "Yes", "No")
									switch(streamdisconnectconfirm)
										if("Yes")
											disabling = 1
											to_chat(usr, "<span class='notice'>Remote user detected, bypassing maintenence checks. Datachip stream [chipstatus ? "reconnecting" : "disconnecting"]. Please standby.</span>")
											say("Datachip stream [chipstatus ? "online" : "offline"].")
											chipstatus = !chipstatus
											chipdisabled()
											visible_message("<span class='notice'>You toggle the datachip [chipstatus ? "online" : "offline"]</span>")
											say("Datachip toggled [chipstatus ? "online" : "offline"]. Compiling error report for active Station A.I's in thirty seconds. Please log any unexpected effects for research.") //Just like before, a message for the A.I, and a message at the Terminal for anybody nearby to hear and comment on.
											to_chat(usr, "<span class='notice'>Datachip toggled [chipstatus ? "online" : "offline"]. Compiling error report for active Station A.I's in thirty seconds. Please log any unexpected effects for research.</span>")
											disabling = 0
											sleep(300)
											var/turf/B = get_turf(src)
											for(var/mob/living/silicon/ai/AI in GLOB.player_list)
												if(B.loc)
													to_chat(AI, "<font color='red'><span class='Warning'><b>Warning:A.I Datarack chip data transfer [chipstatus ? "reconnected" : "disconnected"] at [B.loc]. Some functions may be [chipstatus ? "restored" : "impeded"].</font></span>")
												else
													to_chat(AI, "<font color='red'><span class='Warning'><b>Warning: A.I Datarack chip data transfer [chipstatus ? "reconnected" : "disconnected"] at an unknown location. Some functions may be [chipstatus ? "restored" : "impeded"].</font></span>")
										if("No")
											return
								else if(!chipinstalled)
									to_chat(usr, "No Datachip present. Please refer to instructional booklet.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
								else
									to_chat(usr, "System buffer occupied. Cannot toggle while datachip extraction is in progress.")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)

							if("Maintenence Cycle") //Clears Emag display, and an excellent way to prevent access to a terminal for 60 seconds or longer.
								var/maintenencelength = alert(usr, "How long would you like to engage a Maintenence Cycle for?(Measured in Seconds)", "Maintenence Length?", "60", "140", "160")
								switch(maintenencelength)
									if("60")
										maintenencelength = 600
										maintenencerecordedlength = 600
									if("140")
										maintenencerecordedlength = 1400
										maintenencelength = 1400
									if("160")
										maintenencerecordedlength = 1400
										maintenencelength = 1600
								if(!disabling && !extracting)
									disabling = 1
									extracting = 1
									maintenencecycle = !maintenencecycle	
									rackstage = 2
									update_icon()
									to_chat(usr, "<span class='notice'>Maintenence Cycle enabled. Cover position locked. Please standby</span>")
									sleep(maintenencelength)
									to_chat(usr, "<span class='notice'>Maintenence Cycle terminated. Cover position unlocked.</span>")
									rackstage = 1
									update_icon()
									maintenencecycle = !maintenencecycle
									emagged = 0
									disabling = 0
									extracting = 0
								else if(disabling)
									to_chat(usr, "<span class='notice'>Error: Cannot initiate maintenence cycle during datachip toggle procedure.</span>")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
								else
									to_chat(usr, "<span class='notice'>Error: Cannot initiate maintenence cycle during datachip extraction procedure.</span>")
									playsound(loc, 'sound/machines/buzz-sigh.ogg', 35)
							if("Cancel")
								return
					if("Cancel")
						return 
			if("Cancel")
				alert("Diagnostic Failed. Remote access attempt logged.") //The only way to fail is to cancel at the beginning.
				say("<font color='red'><span class='warning'>Warning: Remote access attempted, verification failed.</span></font>")
	else
		to_chat(usr, "<span class='notice'>Maintenence Cycle in progress. Cycle logs [maintenencerecordedlength] miliseconds until interface is possible.</span>")

/obj/machinery/ai_datarack/emag_act(mob/user)
	. = ..()
	visible_message("<font color='red'><span class='notice'>You override the data terminals coverlock.</span></font>")
	coverstatus = 1
	do_sparks(3, TRUE, src)
	emagged = 1
	rackstage = 3
	update_icon()

/obj/item/aidatachip //Doesn't actually do anything, just for objectives and Terminals.
	name = "AI Data-terminal Chip"
	desc = "A small high security storage device for Station A.I Functions."
	icon = 'icons/obj/device.dmi'
	icon_state = "AI_Data_Chip" //Haha, Quantum Keycard Recolor go Beep Bzzzzz Booop.
	var/scrambled = 0
	var/iconstage = 0

/obj/item/aidatachip/update_icon()
	switch(iconstage)
		if(0)
			icon_state = "AI_Data_Chip"
		if(1)
			icon_state = "AI_Data_Chip_Emagged" //Same as the regular chip, but one of the Antenna is faintly blinking out. Pay close attention!

/obj/item/aidatachip/emag_act(mob/user)
	. = ..()
	visible_message("<font color='red'><span class='notice'>You scramble the electronics within the datachip.</span></font>")
	scrambled = 1
	iconstage = 1
	update_icon()

/obj/machinery/ai_datarack/proc/chipdisabled(mob/living/silicon/ai/D) //This causes me stress.
	if(!chipinstalled || !chipstatus)
		var/removedeffect = pick("Visual Failure", "Linguistics Failure", "Power Distributor Failure", "Identification Failure", "Subsystems Failure")
		switch(removedeffect)
			if("Visual Failure")
				VisualFail = 1
				sleep(150)
				to_chat(usr, "<span class='notice'>Security Network feed processing unavailable. No datachip found.</span>")
				D.blur_eyes(1)
			if("Linguistics Failure")
				LinguisticsFail = 1
				var/Languagedamages = rand(0, 1)
				sleep(150) //small delay from chip extract to effect.
				to_chat(usr, "<span class='notice'>Lingiustics Processing datachip extracted. Expect language failures.</span>")
				if(Languagedamages) //Shy little A.I, or, more akin to removing its tounge I guess?
					add_blocked_language(/datum/language/common, usr) 
					add_blocked_language(/datum/language/moffic, usr)
					add_blocked_language(/datum/language/uncommon, usr)
					add_blocked_language(/datum/language/draconic, usr)
				else
					grant_language(/datum/language/drone, TRUE, TRUE, usr) //Beep Booop BIZZZZZ bPEE BIZZZ??? BOOP BEEPPP!?!?
			if("Power Distributor Failure")
				PowerDistroFail = 1
				sleep(150)
				to_chat(usr, "<span class='notice'>Statistical Power Processing datachip extracted. Expect automatic powerspike management failure.</span>")
				do_sparks(5, 1, src)
			if("Identification Failure")
				IdentificationFail = 1
				sleep(150)
				to_chat(usr, "<span class='notice'>Deep Learning Shape and biometric recognition datachip extracted. Expect Identification Failure.</span>")
			if("Subsystems Failure")
				SubsystemFail = 1
				sleep(150)
				to_chat(usr, "<span class='notice'>Utility System Processing datachip not found. Utility systems may experience error.</span>")