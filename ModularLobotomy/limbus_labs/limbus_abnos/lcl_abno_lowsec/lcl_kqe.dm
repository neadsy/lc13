/mob/living/simple_animal/hostile/limbus_abno/KQE
// hi this is mostly ported from RCA, his gimmick works fine for LCL and its better to have more abnos in the game.
	true_name = "KQE-1J-23"
	original_abno = /mob/living/simple_animal/hostile/limbus_abno/KQE
	maxHealth = 1450
	health = 150
	rapid_melee = 2
	speed = 0.5
	move_to_delay = 3

	melee_damage_lower = 15
	melee_damage_upper = 25
	melee_damage_type = BLACK_DAMAGE

	speak_emote = list("states")
	speech_span = SPAN_ROBOT

	damage_coeff = list(RED_DAMAGE = 1.5, WHITE_DAMAGE = 0.8, BLACK_DAMAGE = 1, PALE_DAMAGE = 1.2)
	ranged = TRUE

	var/grab_cooldown
	var/grab_cooldown_time = 15 SECONDS
	var/grab_damage = 120
	var/heart = FALSE
	var/heart_threshold = 700


	hunger_cooldown_time = 2 MINUTES
	diet_value = 50
	desire_loss = 5
	desire_on_pet = 5
	desire_on_talk = 3
	desire_on_eat = 10
	rep_desire_gain = -5
	insight_cooldown_time = 1 MINUTES
	liked_objects_list = list(/obj/item/modular_computer/tablet,)
	diet_list = list(/obj/item/stock_parts/cell, obj/item/stack/cable_coil)
	liked_objects_value = 5
	hated_objects_list = list(/obj/effect/decal/cleanable) // Doesnt like dirty things, tour guide or whatever
	hated_objects_value = 0.2

	ego_list = list(
		/datum/ego_datum/weapon/replica,
		/datum/ego_datum/armor/replica,
	)

attack_action_types = list(/datum/action/innate/limbus_action_toggle/toggle/kqe_grab_toggle)


	abno_additional_instructions = "You are a robotic tour guide, you exist to show visitors around the 'town' either willingly, or if they ignore you by force. \
		you like the area to be clean and ordely, and love talking to visitors. you like instinct and insight, and eat batteries and wiring. \
		<b>|Initiating Town Tour|: Your melee attack is entirely replaced with a 5x5 choreographed AoE centered around yourself.<br>\
		<b>|Transfer Reg|: Your special ability allows you to target a tile for Transfer Reg causing a short stun and temporary debuffs.<br>\
		<b>|Heart of the Town|: When your health falls below 50% your resistances will be greatly increased however you will also enter a staggered state for 10 seconds"

/mob/living/simple_animal/hostile/limbus_abno/KQE/examine(mob/user)
	. = ..()
	if(heart)
		. += "It's currently drawing full power out of it's components, it has no weaknesses after rebooting."
	else
		. += "It seems quite weak however it looks to not be using it's full potential."

/datum/action/innate/limbus_action_toggle/toggle/kqe_grab_toggle
	name = "Toggle Claw Attack"
	button_icon_state = "kqe_toggle0"
	desire_req = 50
	chosen_attack_num = 2
	chosen_message = span_colossus("You won't grab visitors anymore.")
	button_icon_toggle_activated = "kqe_toggle1"
	toggle_attack_num = 1
	toggle_message = span_colossus("You will attempt to grab visitors.")
	button_icon_toggle_deactivated = "kqe_toggle0"

/*** Basic Procs ***/
/mob/living/simple_animal/hostile/limbus_abno/KQE/Move()
	if(!can_act)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/limbus_abno/KQE/Moved()
	playsound(get_turf(src), 'sound/abnormalities/nothingthere/walk.ogg', 50, 0, 3)
	return ..()

/mob/living/simple_animal/hostile/limbus_abno/KQE/Life()
	. = ..()
	if(!.) // Dead
		return FALSE
	if(health >= heart_threshold)
		return
	if(!heart)
		revive(full_heal = TRUE, admin_revive = FALSE)//fully heal and spawn a heart
		say("Please cooperate! Please Cooperrr... Csdk..ppra...@#@%!%^#$")
		heart = TRUE
		ChangeResistances(list(RED_DAMAGE = 0.5, WHITE_DAMAGE = 0.5, BLACK_DAMAGE = 0.5, PALE_DAMAGE = 0.5))
		Stagger()
		manual_emote("blares random letters on its terminal before turning it off.")

/mob/living/simple_animal/hostile/limbus_abno/KQE/death()
	if(!heart)
		return Life()//PRANKED!
	can_act = FALSE
	icon = 'ModularLobotomy/_Lobotomyicons/abno_cores/he.dmi'
	icon_state = icon_dead
	..()

/mob/living/simple_animal/hostile/limbus_abno/KQE/proc/Stagger()
	can_act = FALSE
	icon_state = "kqe_prepare"
	SLEEP_CHECK_DEATH(10 SECONDS)
	icon_state = icon_living
	can_act = TRUE

/mob/living/simple_animal/hostile/limbus_abno/KQE/AttackingTarget(atom/attacked_target)
	if(!can_act)
		return FALSE
	if ((grab_cooldown <= world.time) && prob(35) && (!client))//checks for client since you can still use the claw if you click nearby
		var/turf/target_turf = get_turf(attacked_target)
		return ClawGrab(target_turf)
	if(!target)
		GiveTarget(attacked_target)
	return Whip_Attack()

/mob/living/simple_animal/hostile/limbus_abno/KQE/proc/Whip_Attack()
	can_act = FALSE
	face_atom(target)
	playsound(get_turf(src), attack_sound, 75, 0, 3)
	icon_state = "kqe_prepare"
	SLEEP_CHECK_DEATH(10)
	for(var/turf/T in view(2, src))
		new /obj/effect/temp_visual/smash_effect(T)
		HurtInTurf(T, list(), melee_damage_upper, RED_DAMAGE, check_faction = TRUE, hurt_mechs = TRUE, hurt_structure = TRUE, attack_type = (ATTACK_TYPE_MELEE | ATTACK_TYPE_SPECIAL))
	icon_state = "kqe_prepare2"
	SLEEP_CHECK_DEATH(3)
	icon_state = icon_living
	can_act = TRUE


/mob/living/simple_animal/hostile/limbus_abno/KQE/OpenFire()
	if(!can_act)
		return
	if(client)
		switch (chosen_attack)
			if (1)
				ClawGrab(target)
			if (2)
				return
		return
	if(grab_cooldown <= world.time)
		ClawGrab(target)
	return

/mob/living/simple_animal/hostile/limbus_abno/KQE/proc/ClawGrab(target)
	if(grab_cooldown > world.time)
		return
	grab_cooldown = world.time + grab_cooldown_time
	can_act = FALSE
	face_atom(target)
	playsound(get_turf(src), 'sound/abnormalities/kqe/load1.ogg', 75, 0, 3)
	icon_state = "kqe_prepare"
	var/grab_delay = (get_dist(src, target) <= 2) ? (1 SECONDS) : (0.5 SECONDS)
	SLEEP_CHECK_DEATH(grab_delay)
	icon_state = "kqe_grab"
	new /obj/effect/LCL_KQE_Claw(get_turf(target))
	SLEEP_CHECK_DEATH(3 SECONDS)
	icon_state = icon_living
	can_act = TRUE

//Claw target object
/obj/effect/LCL_KQE_Claw
	name = "approaching claw"
	desc = "LOOK OUT!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "tbird_bolt"
	color = COLOR_VIOLET
	move_force = INFINITY
	pull_force = INFINITY
	generic_canpass = FALSE
	movement_type = PHASING | FLYING
	var/boom_damage = 35
	var/grabbed
	layer = POINT_LAYER//Sprite should always be visible

/obj/effect/LCL_KQE_Claw/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(GrabAttack)), 2 SECONDS)

/obj/effect/LCL_KQE_Claw/proc/GrabAttack()
	playsound(get_turf(src), 'sound/abnormalities/kqe/load2.ogg', 75, 0, 3)
	new /obj/effect/temp_visual/approaching_claw(get_turf(src))
	alpha = 1
	for(var/mob/living/carbon/human/H in view(1, src))
		grabbed = TRUE
		H.deal_damage(boom_damage, BLACK_DAMAGE, src, flags = (DAMAGE_FORCED), attack_type = (ATTACK_TYPE_SPECIAL))
		H.forceMove(get_turf(src))//pulls them all to the target
		GrabStun(H)
	if(grabbed)
		sleep(10 SECONDS)
	qdel(src)

/obj/effect/LCL_KQE_Claw/proc/GrabStun(mob/living/carbon/human/target)
	animate(target, pixel_x = 0, pixel_z = 12, time = 5)
	target.Stun(3 SECONDS)
	target.apply_lc_black_fragile(5)
	target.apply_lc_feeble(5)
	addtimer(CALLBACK(src, PROC_REF(AnimateBack),target), 3 SECONDS)

/obj/effect/LCL_KQE_Claw/proc/AnimateBack(mob/living/carbon/human/target)
	animate(target, pixel_x = 0, pixel_z = 0, time = 1 SECONDS)
	return TRUE
