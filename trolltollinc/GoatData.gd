# GoatData.gd
extends Node

const DAY_1_GOATS = [
	{
		"dialogue": "Please let me pass! My bigger brother is coming next!",
		"size": 0.8,
		"components": {
			"horns": "horns_x2_normal",
			"head": "none",
			"body": "none",
			"hand": "none",
			"feet": "normal" # We just need the color/type, e.g., "red", "gold"
		}
	},
	{
		"dialogue": "Careful, troll! My biggest brother is right behind me!",
		"size": 1.0,
		"components": {
			"horns": "horns_x2_normal",
			"head": "none",
			"body": "none",
			"hand": "none",
			"feet": "normal"
		}
	},
	{
		"dialogue": "I am the biggest of the brothers! I fear no troll!",
		"size": 1.2,
		"components": {
			"horns": "horns_x2_gold",
			"head": "none",
			"body": "none",
			"hand": "none",
			"feet": "gold"
		}
	}
]
