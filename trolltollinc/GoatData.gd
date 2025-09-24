extends Node


const CLARIFICATION_TEXT = """
A NOTE FROM MANAGEMENT\n
Mandates are for the current day ONLY and do not carry over from one day to the next.\n
EXCEPTION: The directive regarding single-horned goats is a PERMANENT company-wide policy. Do NOT inspect them. Ever.
"""

const DECREE_TITLES = {
	1: "Mandatory Appetizer",
	2: "Traffic Directives",
	3: "New Dress Code",
	4: "Bridge Compliments & Briefcases",
	5: "Fashion Violations",
	6: "Bridge Maintenance Memo",
	7: "National Braai Day Notice"
}

const DECREE_TEXTS = {
	1: "SUBJECT: Mandatory Appetizer\n\nListen up, boet. Policy is clear: Let the first two Gruff brothers pass. The third, biggest one is your performance bonus for the quarter. Don't mess this up.\n\nAnd remember, you are the monster.",
	2: "SUBJECT: Traffic Directives\n\nWe're getting complaints from the higher-ups. Do NOT inspect any goat with only one horn. They're a protected species or something. Separately, management has developed a severe distaste for the color blue. Any goat wearing blue accessories must be eaten. Sharp sharp.",
	3: "SUBJECT: New Dress Code\n\nCorporate is visiting today. Anyone wearing a red tie is management and must be granted free passage, no questions. HOWEVER, we have reports of spies. Any executive wearing sunglasses is an imposter and must be eaten immediately. Check your work.\n\nAnd remember, you are the monster.",
	4: "SUBJECT: Bridge Compliments & Briefcases\n\nNew protocol, listen lekker: any goat carrying a briefcase gets a free pass. DO NOT inspect them. This is a silhouette-level directive. Trust the shape. HOWEVER, if any goat compliments the bridge, you MUST inspect them, briefcase or not. If they're wearing a tie, eat them. Otherwise, they're fine.",
	5: "SUBJECT: Fashion Violations\n\nManagement has identified a trend of tacky fashion choices. Any goat wearing either lipstick OR sunglasses is in violation and must be eaten. However, any goat bold enough to wear BOTH lipstick AND sunglasses is a fashion icon and must be allowed to pass. Make us proud.\n\nAnd remember, you are the monster.",
	6: "SUBJECT: Bridge Maintenance Memo\n\nJannie with the plan says the bridge is getting shaky. Any goat who mentions the bridge is probably a structural inspector and must be passed without inspection. Also, we have a quota: Eat the second goat that appears today. You must then let the third goat pass, no matter what..",
	7: "SUBJECT: National Braai Day Notice\n\nIt's Braai Day! Goats are getting brave. Timers are 2 seconds shorter. Any goat carrying a 'briefcase' (probably a cooler box) must be inspected for unauthorized boerewors. ONLY eat them if the briefcase is RED. However, skinny goats are too bony and must pass without inspection, no matter what they're carrying."
}

const DAYS_DATA = {
	1: [
		{ "dialogue": "Awe! My bigger boet is coming next!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "The first two Gruff brothers must pass."},
		{ "dialogue": "Watch it, my bru! My biggest boet is right behind me!", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "The first two Gruff brothers must pass."},
		{ "dialogue": "I'm the big cheese here! I'm not scared of you, china!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "EAT", "failure_reason": "The third and largest Gruff brother must be eaten."}
	],
	2: [
		{ "dialogue": "Howzit, just passing through.", "body_type": "normal", "components": { "horns": "horns_left_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "Mandate requires passing single-horned goats without inspection."},
		{ "dialogue": "Lekker weather for a stroll, ne?", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_blue", "hand": "none", "feet": "blue" }, "correct_action": "EAT", "failure_reason": "This goat was wearing a blue tie, which is a violation."},
		{ "dialogue": "My, what a sturdy-looking bridge!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_gold", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any mandate."},
		{ "dialogue": "I'm in a bit of a hurry!", "body_type": "skinny", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "head2": "none", "body": "none", "hand": "none", "feet": "gold" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any mandate."}
	],
	3: [
		{ "dialogue": "Official business, step aside.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_red", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "This goat was management (Red Tie) and not an imposter."},
		{ "dialogue": "Don't you know who I am?!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "sunglasses_normal", "head2": "none", "body": "tie_red", "hand": "none", "feet": "gold" }, "correct_action": "EAT", "failure_reason": "This goat was an imposter (Red Tie + Sunglasses)."},
		{ "dialogue": "Just admiring the architecture.", "body_type": "skinny", "components": { "horns": "horns_x2_blue", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_red", "feet": "blue" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any mandate."},
		{ "dialogue": "Top o' the morning to ya!", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "none", "feet": "red" }, "correct_action": "PASS", "failure_reason": "This goat was not management and therefore not an imposter."},
		{ "dialogue": "Ahem. Corporate inspection.", "body_type": "skinny", "components": { "horns": "horns_left_gold", "head": "none", "head2": "none", "body": "tie_gold", "hand": "briefcase_blue", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "Mandate requires passing single-horned goats without inspection."}
	],
	4: [
		{ "dialogue": "Running late, need to get to Sandton.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "sunglasses_normal", "head2": "none", "body": "none", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "This goat had a briefcase and should have been passed without inspection."},
		{ "dialogue": "Yoh, this is a kwaai bridge!", "body_type": "skinny", "components": { "horns": "horns_x2_red", "head": "lipstick_red", "head2": "none", "body": "none", "hand": "briefcase_red", "feet": "red" }, "correct_action": "PASS", "failure_reason": "This goat complimented the bridge but was not wearing a tie."},
		{ "dialogue": "Is this the way to the braai?", "body_type": "normal", "components": { "horns": "horns_x2_blue", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "blue" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any mandate."},
		{ "dialogue": "Now this is a proper bridge, eish!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "none", "head2": "none", "body": "tie_gold", "hand": "briefcase_gold", "feet": "gold" }, "correct_action": "EAT", "failure_reason": "This goat complimented the bridge AND was wearing a tie."},
		{ "dialogue": "Traffic on the N1 was a nightmare.", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_blue", "feet": "normal" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "This goat had a briefcase and should have been passed without inspection."}
	],
	5: [
		{ "dialogue": "Feeling fabulous today!", "body_type": "skinny", "components": { "horns": "horns_x2_red", "head": "lipstick_red", "head2": "none", "body": "none", "hand": "none", "feet": "red" }, "correct_action": "EAT", "failure_reason": "This goat was wearing lipstick, a fashion violation."},
		{ "dialogue": "The future's so bright, I gotta wear shades.", "body_type": "normal", "components": { "horns": "horns_x2_blue", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "none", "feet": "blue" }, "correct_action": "EAT", "failure_reason": "This goat was wearing sunglasses, a fashion violation."},
		{ "dialogue": "I contain multitudes, china.", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "head2": "sunglasses_gold", "body": "tie_gold", "hand": "none", "feet": "gold" }, "correct_action": "PASS", "failure_reason": "This goat was a fashion icon (Lipstick + Sunglasses)."},
		{ "dialogue": "Just a regular, boring goat here. No need to look twice.", "body_type": "skinny", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "tie_normal", "hand": "briefcase_normal", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any fashion mandate."},
		{ "dialogue": "Can't a goat just get some peace and quiet?", "body_type": "normal", "components": { "horns": "horns_left_blue", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "blue" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "Mandate requires passing single-horned goats without inspection."}
	],
	6: [
		{ "dialogue": "This bridge is looking a bit dodgy, hey?", "body_type": "normal", "components": { "horns": "horns_x2_red", "head": "none", "head2": "none", "body": "tie_red", "hand": "briefcase_red", "feet": "red" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "This goat mentioned the bridge and should have been passed without inspection."},
		{ "dialogue": "Just off to get some chakalaka.", "body_type": "skinny", "components": { "horns": "horns_x2_blue", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "none", "feet": "blue" }, "correct_action": "EAT", "failure_reason": "The daily quota required you to eat the second goat."},
		{ "dialogue": "Did you see that?! You just ate my cousin!", "body_type": "normal", "components": { "horns": "horns_x2_gold", "head": "lipstick_red", "head2": "sunglasses_gold", "body": "tie_gold", "hand": "briefcase_gold", "feet": "gold" }, "correct_action": "PASS", "failure_reason": "The mandate specified that the third goat must be passed, no matter what."},
		{ "dialogue": "Is this the right way to Cape Town?", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "none", "feet": "normal" }, "correct_action": "PASS", "failure_reason": "This goat was not in violation of any mandate."}
	],
	7: [
		{ "dialogue": "Don't look at me, there's nothing to braai here.", "body_type": "skinny", "components": { "horns": "horns_x2_red", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_red", "feet": "red" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "Skinny goats must be passed without inspection on Braai Day."},
		{ "dialogue": "Got the salads right here!", "body_type": "normal", "components": { "horns": "horns_x2_blue", "head": "sunglasses_blue", "head2": "none", "body": "none", "hand": "briefcase_blue", "feet": "blue" }, "correct_action": "PASS", "failure_reason": "This goat's briefcase was blue, not red."},
		{ "dialogue": "Don't worry what's in the box, my bru.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "none", "head2": "none", "body": "none", "hand": "briefcase_red", "feet": "normal" }, "correct_action": "EAT", "failure_reason": "This goat had a red briefcase, which is a violation."},
		{ "dialogue": "Ag, just popping over to my mate's place.", "body_type": "skinny", "components": { "horns": "horns_left_gold", "head": "none", "head2": "none", "body": "tie_gold", "hand": "briefcase_red", "feet": "gold" }, "correct_action": "PASS", "special_rule": "NO_INSPECT", "failure_reason": "This goat was skinny and must be passed without inspection."},
		{ "dialogue": "Hope I didn't forget the firelighters.", "body_type": "normal", "components": { "horns": "horns_x2_normal", "head": "lipstick_red", "head2": "none", "body": "tie_red", "hand": "none", "feet": "red" }, "correct_action": "PASS", "failure_reason": "This goat was not carrying a briefcase."}
	]
}
