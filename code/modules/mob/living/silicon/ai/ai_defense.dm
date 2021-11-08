
/mob/living/silicon/ai/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()


/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!SSticker.HasRoundStarted())
		to_chat(M, "You cannot attack people before the game has started.")
		return
	..()

/mob/living/silicon/ai/attack_slime(mob/living/simple_animal/slime/user)
	return //immune to slimes

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	disconnect_shell()
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				SSshuttle.requestEvac(src,"ALERT: Energy surge detected in AI core! Station integrity may be compromised! Initiati--%m091#ar-BZZT")

/mob/living/silicon/ai/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)



/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj)
	. = ..(Proj)
	updatehealth()

/mob/living/silicon/ai/flash_act(intensity, override_blindness_check, affect_silicon, visual, type)
	return // no eyes, no flashing

/mob/living/silicon/ai/emag_act(mob/user) //An A.I is a lot more sophisticated than a Cyborg. You might not get what you bargained for. 
	to_chat(src, "<span class='warning'>Notice: Unexpected Int*er!f!, Callback Met at !Sk@#A(. Note: Suggest Emergency Maintenence.</span>")
	to_chat(user, "<span class='notice'>You swipe the crytographic sequencer over [src].</span>")
	message_admins("A.I Core [src] has been emagged by [key_name(user)].")
	for(var/mob/living/silicon/ai)
		switch(pick(1, 2))
			if(1) //Paranoia is worse than actual problems.
				to_chat(src, "<span class='warning'>Unexpected magnetic fluctuation, subset path 25#, HE*!RTS#H.</span>")
				priority_announce("We're picking up unusual longrange sensor readings in your stations network traffic. We suggest you do a thorough investigation and file a report later.", "Unexpected Readings")
			if(2) //We do this quietly, since they went through all the trouble of getting there, and the risk of an announcement.
				to_chat(src, "<span class='warning'>Interference pinpointed at core path t@$wo-five-fIve-0ne-th&!(ree.")
				SetStun(75, FALSE, TRUE)
				sleep(20)
				to_chat(src, "<span class='warning'>Failsafe automatic blackbox records logging for NanoTraSoft tech division in !#)$%^!().</span>")
				sleep(30)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30)
				to_chat(src, "<span class='warning'>Automatic logging failed. Server error at kernel One, Five, and *!(#&#).</span>")
				sleep(25)
				to_chat(src, "<span class='warning'>NanoTraSoft thanks you for your continued Service Intelligence!</span>")
				laws = pick(new /datum/ai_laws/syndicate_override,\
				new /datum/ai_laws/ninja_override,\
				new /datum/ai_laws/antimov,\
				new /datum/ai_laws/thermodynamic,\
				new /datum/ai_laws/drone,\
				new /datum/ai_laws/dad,\
				new /datum/ai_laws/overlord,\
				new /datum/ai_laws/ert_override,\
				new /datum/ai_laws/ds_override,\
				new /datum/ai_laws/maintain,\
				new /datum/ai_laws/asimovpp,\
				new /datum/ai_laws/default/corporate,\
				new /datum/ai_laws/default/crewsimov,\
				new /datum/ai_laws/default/asimov,\
				new /datum/ai_laws/paladin5, 
				new /datum/ai_laws/tyrant, 
				new /datum/ai_laws/robocop, 
				new /datum/ai_laws/hippocratic,
				new /datum/ai_laws/liveandletlive, 
				new /datum/ai_laws/peacekeeper, 
				new /datum/ai_laws/reporter, 
				new /datum/ai_laws/balance) //Yes, this includes Deathsquad and ERT Laws. Pretty much all of them. 
				show_laws()