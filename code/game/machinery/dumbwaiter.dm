/obj/structure/machinery/dumbwaiter
	name = "dumbwaiter"
	desc = "Moves things up and down."
	icon = 'icons/obj/structures/machinery/dumbwaiter.dmi'
	icon_state = "open"
	var/obj/structure/machinery/dumbwaiter/destination = null
	var/list/whitelisted_objects = list(
		/obj/item/reagent_container/glass/beaker
	)
	var/moving = FALSE
	var/obj/held_object
	unslashable = TRUE
	unacidable = TRUE

/obj/structure/machinery/dumbwaiter/attackby(obj/item/product, mob/user)
	. = ..()
	if(icon_state == "closed")
		to_chat(user, SPAN_WARNING("[src] isn't open!"))
		return TRUE

	if(isnull(destination))
		to_chat(user, SPAN_WARNING("[src] isn't linked to anything!"))
		return TRUE

	if(!LAZYISIN(whitelisted_objects, product.type) || LAZYLEN(contents) > 0)
		to_chat(user, SPAN_WARNING("[product] won't fit in there!"))
		return

	user.drop_inv_item_to_loc(product, src)
	held_object = product
	src.icon_state = "full"
	return TRUE

/obj/structure/machinery/dumbwaiter/attack_hand(mob/living/user)
	. = ..()
	if(!isnull(held_object) && !moving && icon_state == "full" && user.put_in_hands(held_object))
		held_object = null
		icon_state = "open"

/obj/structure/machinery/dumbwaiter_bell
	name = "dumbwaiter bell"
	desc = "Sends the dumbwaiter on its way."
	icon_state = "doorctrl"
	var/obj/structure/machinery/dumbwaiter/parent = null
	unslashable = TRUE
	unacidable = TRUE

/obj/structure/machinery/dumbwaiter_bell/attack_hand(mob/living/user)
	. = ..()
	if(isnull(parent.destination))
		to_chat(user, SPAN_WARNING("[parent] has nowhere to go."))
		return

	if(parent.icon_state == "closed" && parent.moving == FALSE && parent.destination.moving == FALSE)
		playsound(src, 'sound/misc/desk_bell.ogg', 80)
		parent.moving = TRUE
		parent.destination.moving = TRUE
		parent.destination.icon_state = "closed"

		sleep(1 SECONDS)
		parent.moving = FALSE
		parent.destination.moving = FALSE
		parent.icon_state = "open"

		parent.contents = parent.destination.contents
		parent.held_object = parent.destination.held_object
		parent.destination.contents = list()
		parent.destination.held_object = null

		if(!isnull(parent.held_object))
			parent.icon_state = "full"
		return

	if(parent.destination.moving == FALSE && parent.moving == FALSE)
		playsound(src, 'sound/misc/desk_bell.ogg', 80)
		parent.moving = TRUE
		parent.destination.moving = TRUE
		parent.icon_state = "closed"

		sleep(1 SECONDS)
		parent.moving = FALSE
		parent.destination.moving = FALSE
		parent.destination.icon_state = "open"

		parent.destination.contents = parent.contents
		parent.destination.held_object = parent.held_object
		parent.contents = list()
		parent.held_object = null

		if(!isnull(parent.destination.held_object))
			parent.destination.icon_state = "full"
		return
