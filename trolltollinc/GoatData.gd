#GoatData
extends Node

const DECREE_TITLES = {
	1: "Mandatory Appetizer",
	2: "Traffic Directives",
	3: "New Dress Code"
	# Add titles for Day 4, 5, etc.
}

const DECREE_TEXTS = {
	1: "SUBJECT: Mandatory Appetizer\n\nPolicy is clear: Let the first two Gruff brothers pass. The third, largest one is your performance bonus for the quarter. Don't mess this up.\n\nAnd remember, you are the monster.",
	2: "SUBJECT: Traffic Directives\n\nWe're getting complaints. Do NOT inspect any goat with only one horn. They are a protected species. Separately, management has developed a severe distaste for the color blue. Eat any goat wearing blue accessories.\n\nAnd remember, you are the monster.",
	3: "SUBJECT: New Dress Code\n\nCorporate is visiting. Anyone wearing a red tie is management and must be granted free passage. However, we have reports of spies disguised as management. Any executive wearing sunglasses is an imposter and must be eaten.\n\nAnd remember, you are the monster."
}

const DAYS_DATA = {
	1: [
		{ "dialogue": "Please let me pass! My bigger brother is coming next!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "Careful, troll! My biggest brother is right behind me!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "I am the biggest of the brothers! I fear no troll!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "none", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "EAT"}
	],
	2: [
		{ "dialogue": "Just passing through, nothing to see here.", "body_type": "normal", "components": { "horns": "horns_left_normal", "head": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"},
		{ "dialogue": "Lovely weather for a stroll.", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "body": "tie_blue", "hand": "none", "feet": "blue" }, "correct_action": "EAT"},
		{ "dialogue": "My, what a sturdy-looking bridge!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "none", "body": "none", "hand": "briefcase_gold", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "I'm in a bit of a hurry!", "body_type": "skinny", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "PASS"}
	],
	3: [
		{ "dialogue": "Official business, step aside.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "none", "body": "tie_red", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "Don't you know who I am?!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "sunglasses_normal", "body": "tie_red", "hand": "none", "feet": "gold" }, "correct_action": "EAT"},
		{ "dialogue": "Just admiring the architecture.", "body_type": "skinny", "components": { "horns": "horns_x2_blue", "head": "none", "body": "none", "hand": "briefcase_red", "feet": "blue" }, "correct_action": "PASS"},
		{ "dialogue": "Top o' the morning to ya!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "sunglasses_blue", "body": "none", "hand": "none", "feet": "red" }, "correct_action": "EAT"},
		{ "dialogue": "Ahem. Corporate inspection.", "body_type": "skinny", "components": { "horns": "horns_left_gold", "head": "none", "body": "tie_gold", "hand": "briefcase_blue", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"}
	]
}
