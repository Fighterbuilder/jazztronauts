module( "missions", package.seeall )

ResetMissions()

include("jazz_localize.lua")

NPC_COMPUTER = 666
AddNPC("NPC_CAT_BAR", JazzLocalize("jazz.cat.bartender"), "models/andy/bartender/cat_bartender.mdl")
AddNPC("NPC_CAT_SING", JazzLocalize("jazz.cat.singer"), "models/andy/singer/cat_singer.mdl")
AddNPC("NPC_CAT_PIANO", JazzLocalize("jazz.cat.pianist"), "models/andy/pianist/cat_pianist.mdl")
AddNPC("NPC_CAT_CELLO", JazzLocalize("jazz.cat.cellist"), "models/andy/cellist/cat_cellist.mdl")
AddNPC("NPC_NARRATOR", "", "models/npc/cat.mdl")
AddNPC("NPC_BAR", "")
AddNPC("NPC_CAT_VOID", JazzLocalize("jazz.cat.unknown"), "models/andy/basecat/cat_all.mdl")
AddNPC("NPC_CAT_ASH", JazzLocalize("jazz.cat.ash"), "models/andy/basecat/cat_all.mdl")

-- Utility function for giving a player a monetary reward
local function GrantMoney(amt)
	return function(ply)
		ply:ChangeNotes(amt * newgame.GetMultiplier())
	end
end

-- Utility function for unlocking something for the player
local function UnlockItem(lst, unlock)
	return function(ply)
		unlocks.Unlock(lst, ply, unlock)
	end
end

-- Combine multiple rewards
local function MultiReward(...)
	local funcs = {...}
	return function(ply)
		for _, v in pairs(funcs) do
			v(ply)
		end
	end
end

local function MatchesAny(mdl, tbl)
	for _, v in pairs(tbl) do
		if string.lower(mdl) == string.lower(v) then
			return true
		end
	end

	return false
end


local function oildrums(mdl)
	--[[return MatchesAny(mdl, {
			"models/props_c17/oildrum001_explosive.mdl",
			"models/props_c17/oildrum001.mdl",
			"models/props_phx/oildrum001_explosive.mdl",
			"models/props_phx/oildrum001.mdl"
		})]]
	return (string.match(mdl, "drum") and
			not (string.match(mdl, "fairground") or string.match(mdl, "weapons") or string.match(mdl, "drummer"))) or
		MatchesAny(mdl, {
			"models/props_phx/facepunch_barrel.mdl",
			--L4D
			"models/props_industrial/barrel_fuel.mdl",
			--ASW
			"models/swarm/barrel/barrel.mdl"
		})
end

local function gasoline(mdl)
	--gas can, gas pump
	return string.match(mdl, "gas") and
		(string.match(mdl, "can") or 
			(string.match(mdl, "pump") and not string.match(mdl, "_p%d+"))) -- L4D gas_pump_p<N>
end

local function propane(mdl)
	return string.match(mdl,"propane") or 
		(string.match(mdl,"canister") and not string.match(mdl,"chunk"))
end

local function fuel(mdl)
	return oildrums(mdl) or
		gasoline(mdl) or
		propane (mdl)
end

local function beer(mdl)
	return mdl == "models/props/cs_militia/caseofbeer01.mdl" or 
	(string.match(mdl, "bottle") and
		not (string.match(mdl, "chunk") or 
			string.match(mdl, "break") or 
			string.match(mdl, "water") or 
			string.match(mdl, "plastic") or 
			string.match(mdl, "frag"))) or 
	string.match(mdl, "molotov") or
	string.match(mdl, "molly")
end


local count = 15

AddMission(0, NPC_CAT_CELLO, {

	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.drums",count),

	-- The accept function for what props count towards the mission
	-- Can be as broad or as specific as you want
	Filter = function(mdl)
		return oildrums(mdl)
	end,

	-- They need to collect 15 of em' to complete the mission.
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	-- Leave empty to be available immediately
	Prerequisites = nil,

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_CELLO, {
	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.gasbeer",count),

	-- The accept function for what props count towards the mission
	-- Can be as broad or as specific as you want
	Filter = function(mdl)
		return gasoline(mdl) or beer(mdl)
	end,

	-- They need to collect 10 of em' to complete the mission.
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	Prerequisites = { IndexToMID(0, NPC_CAT_CELLO) },

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(10000)
})

count = 10
AddMission(2, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.chems",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
				--"models/props_junk/garbage_plasticbottle001a.mdl",
				--"models/props_junk/garbage_plasticbottle002a.mdl",
				--"models/props_junk/garbage_plasticbottle003a.mdl",
				"models/props_junk/plasticbucket001a.mdl",
				"models/props_junk/glassjug01.mdl",
				"models/props_lab/crematorcase.mdl",
				--"models/props_lab/jar01a.mdl",
				--"models/props_lab/jar01b.mdl",
				"models/props/de_train/biohazardtank.mdl",
				"models/props/de_train/biohazardtank_dm_10.mdl"
			}) or
			string.match(mdl, "jar") or
			(string.match(mdl, "bottle") and
				(string.match(mdl, "plastic") or
				string.match(mdl, "flask") or
				string.match(mdl, "pill"))) or
			propane(mdl) or
			--ASW
			string.match(mdl, "biomass") 
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(20000)
})

count = 5
AddMission(3, NPC_CAT_CELLO, {
	-- User-friendly instructions for what the player should collect
	Instructions = JazzLocalize("jazz.mission.paint",count),

	-- The accept function for what props count towards the mission
	-- Can be as broad or as specific as you want
	Filter = function(mdl)
		return string.match(mdl, "paint") and
			(string.match(mdl, "can") or
			string.match(mdl, "bucket") or
			string.match(mdl, "tool"))
	end,

	-- They need to collect 1 of em' to complete the mission.
	Count = count,

	-- List of all missions that needs to have been completed before this one becomes available
	Prerequisites = { IndexToMID(2, NPC_CAT_CELLO)  },

	-- When they finish the mission, this function is called to give out a reward
	-- The 'GrantMoney' function returns a function that gives money
	OnCompleted = GrantMoney(15000)
})

count = 1
AddMission(4, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.drk",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/kleiner.mdl",
			"models/player/kleiner.mdl",
			"models/kleiner_monitor.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(25000)
})

count = 1
AddMission(5, NPC_CAT_CELLO, {
	Instructions = JazzLocalize("jazz.mission.cactus",count),
	Filter = function(mdl)
		return mdl == "models/props_lab/cactus.mdl"
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_CELLO)  },
	OnCompleted = GrantMoney(30000)
})

/*
===========================
	Bartender Missions
===========================
*/
count = 10
AddMission(0, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.crates",count),
	Filter = function(mdl)
		return string.match(mdl, "crate") and
			not string.match(mdl, "chunk") and
			not string.match(mdl, "gib") and
			not string.match(mdl, "_p%d+") -- CSS crates_fruit_p<N>
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.cars",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
				"models/buggy.mdl",
				"models/vehicle.mdl",
				--APCs
				"models/combine_apc.mdl",
				"models/combine_apc_dynamic.mdl",
				"models/combine_apc_wheelcollision.mdl",
				"models/combine_apc_destroyed_gib01.mdl",
				"models/props_vehicles/apc001.mdl",
				"models/props/de_piranesi/pi_apc.mdl",
				--we'll allow engines, Bartender wants parts afterall
				"models/props_c17/trappropeller_engine.mdl",
				"models/vehicle/vehicle_engine_block.mdl",
				--Ep1
				"models/vehicles/vehicle_van.mdl",
				--L4D
				"models/props_vehicles/trafficjam01.mdl",
				"models/props_waterfront/tour_bus.mdl",
				--Us!
				"models/sunabouzu/mg_tank.mdl"
			}) or
			((string.match(mdl, "car00") or
			string.match(mdl, "van00") or
			string.match(mdl, "car_nuke") or
			string.match(mdl, "car_militia") or
			string.match(mdl, "hatchback") or
			string.match(mdl, "sedan") or
			string.match(mdl, "bus0") or
			string.match(mdl, "tractor") or --technically includes portal 2 tractor beam stuff, but honestly if you're finding that you deserve it. Bartender *would* want those parts
			string.match(mdl, "ambulance") or
			string.match(mdl, "vehicles/222") or
			string.match(mdl, "jeep_us") or
			string.match(mdl, "kubelwagen") or
			string.match(mdl, "front_loader") or
			string.match(mdl, "hmmwv") or
			string.match(mdl, "humvee") or
			string.match(mdl, "suv") or
			string.match(mdl, "zapastl") or
			--fuck it, tanks too
			string.match(mdl, "boss_tank") or
			string.match(mdl, "taunts/tank") or
			string.match(mdl, "sherman_tank") or
			string.match(mdl, "tiger_tank") or
			--police car, race car
			(string.match(mdl, "car") and 
				(string.match(mdl, "police") or
				string.match(mdl, "race"))) or
			--truck, not truck sign or handtruck
			(string.match(mdl, "truck") and 
				not (string.match(mdl, "sign") or
					string.match(mdl, "hand"))) or
			--pickup, not powerup or item or etc.
			(string.match(mdl, "pickup") and 
				not (string.match(mdl, "powerup") or
					string.match(mdl, "item") or
					string.match(mdl, "emitter") or
					string.match(mdl, "load") or
					string.match(mdl, "swarm"))))
			--no glass/window/tire/wheel/gib
			and not (string.match(mdl, "window") or
				string.match(mdl, "tire") or
				string.match(mdl, "wheel") or
				string.match(mdl, "glass") or
				string.match(mdl, "gib")))
	end,
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(10000)
})

count = 10
AddMission(2, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.melons",count),
	Filter = function(mdl)
		return string.match(mdl, "watermelon")
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(15000)
})

count = 15
AddMission(3, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.propane",count),
	Filter = function(mdl)
		return propane(mdl)
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(20000)
})

count = 5
AddMission(4, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.washers",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_c17/furniturewashingmachine001a.mdl",
			"models/props_wasteland/laundry_washer001a.mdl",
			"models/props_wasteland/laundry_dryer002.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(25000)
})

count = 10
AddMission(5, NPC_CAT_BAR, {
	Instructions = JazzLocalize("jazz.mission.antlions",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/antlion.mdl",
			"models/antlion_worker.mdl",
			"models/antlion_guard.mdl",
			"models/antlion_grub.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_BAR)  },
	OnCompleted = GrantMoney(30000)
})



/*
===========================
	Pianist Missions
===========================
*/
count = 5
AddMission(0, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.chairs",count),
	Filter = function(mdl)
		return ((string.match(mdl, "chair") or string.match(mdl, "bench")) and
				not string.match(mdl, "chunk") and
				not string.match(mdl, "gib") and
				not string.match(mdl, "damage")) or 
			string.match(mdl, "seat") or
			(string.match(mdl, "stool") and not string.match(mdl, "toadstool")) or
			string.match(mdl, "couch")
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 10
AddMission(1, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.crabs",count),
	Filter = function(mdl)
		return string.match(mdl, "eadcrab") or --gets canisters and headcrabprep too (which is fine imo), leaving off the 'h' also gives us TF2 breadcrab
			MatchesAny(mdl, {
				--"models/headcrab.mdl",
				--"models/headcrabblack.mdl",
				--"models/headcrabclassic.mdl",

				-- Let em steal the heads off zombies
				"models/zombie/classic.mdl",
				"models/zombie/classic_torso.mdl",
				"models/zombie/poison.mdl",
				"models/zombie/fast.mdl",
				"models/gibs/fast_zombie_torso.mdl",
				"models/player/zombie_soldier.mdl",
				--ep2
				"models/zombie/zombie_soldier.mdl",
				"models/zombie/zombie_soldier_torso.mdl",
				"models/zombie/fast_torso.mdl",
				--hls
				"models/zombie.mdl",
				--"models/baby_headcrab.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(10000)
})

count = 20
AddMission(2, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.meals",count),
	Filter = function(mdl)
		return string.match(mdl, "watermelon") or 
			MatchesAny(mdl, {
				--"models/props_junk/garbage_takeoutcarton001a.mdl",
				--"models/food/burger.mdl",
				--"models/food/hotdog.mdl",
				--"models/props_junk/watermelon01.mdl",
				--"models/props_junk/food_pile01.mdl",
				--"models/props_junk/food_pile02.mdl",
				--"models/props_junk/food_pile03.mdl",
				--"models/props/cs_militia/food_stack.mdl"
				"models/props_lab/soupprep.mdl",
				"models/props_lab/headcrabprep.mdl",
				"models/props/cs_italy/it_mkt_container1a.mdl",
				"models/props/cs_italy/it_mkt_container3a.mdl",
				"models/props/de_inferno/crate_fruit_break.mdl",
				"models/props/de_inferno/crate_fruit_break_p1.mdl",
				"models/props/de_inferno/crates_fruit1.mdl",
				"models/props/de_inferno/crates_fruit1_p1.mdl",
				"models/props/de_inferno/crates_fruit2.mdl",
				"models/props/de_inferno/crates_fruit2_p1.mdl",
				--TF2
				"models/player/gibs/gibs_burger.mdl",
				"models/props_2fort/thermos.mdl",
				"models/props_halloween/pumpkin_loot.mdl",
				"models/props_medieval/medieval_meat.mdl"
			}) or
			string.match(mdl, "food") or --gets a couple weird models like "boothfastfood" and "handrail_foodcourt" but noth worth filtering out these exact specific one-offs
			string.match(mdl, "carton") or --includes milk cartons, cats love milk!
			--string.match(mdl, "fruit") or --includes a lot of wood gibs from the orange crates
			string.match(mdl, "italy/orange") or
			string.match(mdl, "banan") or -- TF2 "banana" and CSS "bananna"
			string.match(mdl, "sandwich") or
			string.match(mdl, "chocolate") or
			string.match(mdl, "lunch") or
			string.match(mdl, "halloween_medkit") or
			string.match(mdl, "treat") or
			string.match(mdl, "popcorn")
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(15000)
})

count = 30
AddMission(3, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.vending",count),
	Filter = function(mdl)
		return string.match(mdl, "vending") and string.match(mdl, "machine")
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(20000)
})

count = 1
AddMission(4, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.horse",count),
	Filter = function(mdl)
		return string.match(mdl, "horse") and string.match(mdl, "statue")
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(25000)
})

count = 3
AddMission(5, NPC_CAT_PIANO, {
	Instructions = JazzLocalize("jazz.mission.metropolice",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/police.mdl",
			"models/police_cheaple.mdl",
			"models/player/police.mdl",
			"models/player/police_fem.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_PIANO)  },
	OnCompleted = GrantMoney(30000)
})

/*
===========================
	Singer Missions
===========================
*/
count = 10
AddMission(0, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.documents",count),
	Filter = function(mdl)
		return string.match(mdl, "binder") or
			string.match(mdl, "file") or
			(string.match(mdl, "book") and not (string.match(mdl, "sign") or string.match(mdl, "stand"))) --Too many "bookshelf" or "bookcase" have books to feel right excluding them
	end,
	Count = count,
	Prerequisites = nil,
	OnCompleted = GrantMoney(5000)
})

count = 5
AddMission(1, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.dolls",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props_lab/huladoll.mdl",
			"models/props_c17/doll01.mdl",
			"models/maxofs2d/companion_doll.mdl",
			"models/props_unique/doll01.mdl", --L4D
		}) or 
		string.match(mdl, "teddy")
	end,
	Count = count,
	Prerequisites = { IndexToMID(0, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(10000)
})

count = 15
AddMission(2, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.radiators",count),
	Filter = function(mdl)
		return string.match(mdl, "radiator") or
			string.match(mdl, "_heater")
	end,
	Count = count,
	Prerequisites = { IndexToMID(1, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(15000)
})

count = 10
AddMission(3, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.plants",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/props/de_inferno/claypot03.mdl",
			"models/props/de_inferno/pot_big.mdl",
			--"models/props/de_inferno/potted_plant1.mdl",
			--"models/props/de_inferno/potted_plant2.mdl",
			--"models/props/de_inferno/potted_plant3.mdl",
			"models/props/cs_office/plant01.mdl",
			"models/props_lab/cactus.mdl",
			"models/props_junk/terracotta01.mdl",
			"models/props/de_tides/planter.mdl",
			"models/props_foliage/flower_barrel.mdl",
			"models/props/de_inferno/flower_barrel.mdl",
			"models/props_foliage/flower_barrel_dead.mdl",
			"models/props_frontline/flowerpot.mdl"
		}) or 
		string.match(mdl, "planter") or
		-- pot(ted) plant, no gibs
		(string.match(mdl, "plant") and string.match(mdl, "pot") and not (string.match(mdl, "gib") or string.match(mdl, "_p%d+")))
	end,
	Count = count,
	Prerequisites = { IndexToMID(2, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(20000)
})

count = 1
AddMission(4, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.alyx",count),
	Filter = function(mdl)
		return MatchesAny(mdl, {
			"models/alyx.mdl",
			"models/alyx_ep2.mdl",
			"models/alyx_interior.mdl",
			"models/alyx_intro.mdl",
			"models/player/alyx.mdl"
		})
	end,
	Count = count,
	Prerequisites = { IndexToMID(3, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(25000)
})

count = 10
AddMission(5, NPC_CAT_SING, {
	Instructions = JazzLocalize("jazz.mission.radios",count),
	Filter = function(mdl)
		--[[return MatchesAny(mdl, {
			"models/infra/props_clutter/cheap_radio.mdl",
			"models/infra/props_clutter/radiophone.mdl",
			"models/props/cs_office/radio.mdl",
			"models/props_lab/citizenradio.mdl",
			"models/props_radiostation/radio_antenna01.mdl"
		})]]
		return mdl == "models/props_radiostation/radio_antenna01.mdl" or
			string.match(mdl, "radio") and
				--radio, without station or radioactive
				not (string.match(mdl, "station") or
					string.match(mdl, "radioactive"))
	end,
	Count = count,
	Prerequisites = { IndexToMID(4, NPC_CAT_SING)  },
	OnCompleted = GrantMoney(30000)
})




