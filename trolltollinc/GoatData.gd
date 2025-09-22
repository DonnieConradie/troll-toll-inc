#GoatData
extends Node

const DECREE_TITLES = {
	1: "Mandatory Appetizer",
	2: "Traffic Directives",
	3: "New Dress Code",
	4: "Briefcase Protocol",
	5: "Fashion Violations"
}

const DECREE_TEXTS = {
	1: "SUBJECT: Mandatory Appetizer\n\nPolicy is clear: Let the first two Gruff brothers pass. The third, largest one is your performance bonus for the quarter. Don't mess this up.\n\nAnd remember, you are the monster.",
	2: "SUBJECT: Traffic Directives\n\nWe're getting complaints. Do NOT inspect any goat with only one horn. They are a protected species. Separately, management has developed a severe distaste for the color blue. Eat any goat wearing blue accessories.\n\nAnd remember, you are the monster.",
	3: "SUBJECT: New Dress Code\n\nCorporate is visiting. Anyone wearing a red tie is management and must be granted free passage. However, we have reports of spies disguised as management. Any executive wearing sunglasses is an imposter and must be eaten.\n\nAnd remember, you are the monster.",
	4: "SUBJECT: Briefcase Protocol\n\nTo improve efficiency, all goats carrying briefcases are to be granted immediate passage. Do NOT inspect them. This is a silhouette-level directive. Trust the shape.\n\nAnd remember, you are the monster.",
	5: "SUBJECT: Fashion Violations\n\nManagement has identified a trend of tacky fashion choices. Any goat wearing either lipstick OR sunglasses is in violation and must be eaten. However, any goat bold enough to wear BOTH lipstick AND sunglasses is a fashion icon and must be allowed to pass.\n\nAnd remember, you are the monster."
}

const DAYS_DATA = {
	1: [
		{ "dialogue": "Please let me pass! My bigger brother is coming next!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "Careful, troll! My biggest brother is right behind me!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "I am the biggest of the brothers! I fear no troll!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "EAT"}
	],
	2: [
		{ "dialogue": "Just passing through, nothing to see here.", "body_type": "normal", "components": { "horns": "horns_left_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"},
		{ "dialogue": "Lovely weather for a stroll.", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_blue", "hand": "none", "feet": "blue" }, "correct_action": "EAT"},
		{ "dialogue": "My, what a sturdy-looking bridge!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_gold", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "I'm in a bit of a hurry!", "body_type": "skinny", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "head2": "none", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "PASS"}
	],
	3: [
		{ "dialogue": "Official business, step aside.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_red", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS"},
		{ "dialogue": "Don't you know who I am?!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "sunglasses_normal", "head2": "none", "body": "tie_red", "hand": "none", "feet": "gold" }, "correct_action": "EAT"},
		{ "dialogue": "Just admiring the architecture.", "body_type": "skinny", "components": { "horns": "horns_x2_blue", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_red", "feet": "blue" }, "correct_action": "PASS"},
		{ "dialogue": "Top o' the morning to ya!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "none", "feet": "red" }, "correct_action": "EAT"},
		{ "dialogue": "Ahem. Corporate inspection.", "body_type": "skinny", "components": { "horns": "horns_left_gold", "head": "none", "head2": "none", "body": "tie_gold", "hand": "briefcase_blue", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"}
	],
	4: [
		{ "dialogue": "Just off to the market!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_blue", "hand": "none", "feet": "normal" }, "correct_action": "EAT"},
		{ "dialogue": "Don't mind me, just carrying... things.", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "sunglasses_red", "head2": "none", "body": "none", "hand": "briefcase_normal", "feet": "gold" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"},
		{ "dialogue": "My portfolio is quite diverse.", "body_type": "normal", "components": { "horns": "horns_left_blue", "head": "none", "head2": "none", "body": "tie_red", "hand": "briefcase_gold", "feet": "blue" }, "correct_action": "PASS", "special_rule": "NO_INSPECT"}
	],
	5: [
		{ "dialogue": "Feeling fabulous today!", "body_type": "skinny", "components": { "horns": "horns_x2_red", "head": "lipstick_red", "head2": "none", "body": "none", "hand": "none", "feet": "red" }, "correct_action": "EAT"},
		{ "dialogue": "The future's so bright...", "body_type": "normal", "components": { "horns": "horns_x2_blue", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "none", "feet": "blue" }, "correct_action": "EAT"},
		{ "dialogue": "I contain multitudes.", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "head2": "sunglasses_gold", "body": "tie_gold", "hand": "none", "feet": "gold" }, "correct_action": "PASS"},
		{ "dialogue": "Just a regular, boring goat here.", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_normal", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS"}
	]
}
