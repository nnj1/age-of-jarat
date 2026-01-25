extends AudioStreamPlayer

## Configuration
@export_dir var music_folder: String = "res://assets/music/oggs sonatina.itch.io:fortunata"

## State
var track_list: Array[String] = []
var current_track_path: String = ""

# SOME GLOBALS
var spawn_streams = [
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_1_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_2_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_3_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_4_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_5_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_6_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_7_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_8_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_9_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Karen Cenon/greeting_10_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_1_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_2_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_3_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_4_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_5_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_6_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_7_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_8_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_9_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Female/Meghan Christian/greeting_10_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_1_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_2_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_3_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_4_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_5_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_6_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_7_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_8_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_9_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Alex Brodie/greeting_10_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_1_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_2_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_3_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_4_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_5_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_6_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_7_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_8_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_9_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Ian Lampert/greeting_10_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_1_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_2_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_3_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_4_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_5_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_6_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_7_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_8_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_9_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/3 - Greeting/Male/Sean Lenhart/greeting_10_sean.wav"),

]

var idle_streams = [
	# --- FEMALE: Karen Cenon ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_1_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_2_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_3_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_4_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_5_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_6_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_7_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_8_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_9_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_10_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_11_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_12_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_13_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_14_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_15_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_16_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_17_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_18_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Karen Cenon/miscellaneous_19_karen.wav"),

	# --- FEMALE: Meghan Christian ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_1_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_2_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_3_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_4_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_5_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_6_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_7_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_8_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_9_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_10_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_11_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_12_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_13_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_14_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_15_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_16_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_17_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_18_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Female/Meghan Christian/miscellaneous_19_meghan.wav"),

	# --- MALE: Alex Brodie ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_1_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_2_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_3_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_4_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_5_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_6_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_7_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_8_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_9_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_10_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_11_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_12_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_13_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_14_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_15_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_16_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_17_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_18_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Alex Brodie/miscellaneous_19_alex.wav"),

	# --- MALE: Ian Lampert ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_1_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_2_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_3_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_4_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_5_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_6_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_7_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_8_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_9_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_10_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_11_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_12_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_13_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_14_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_15_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_16_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_17_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_18_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Ian Lampert/miscellaneous_19_ian.wav"),

	# --- MALE: Sean Lenhart ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_1_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_2_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_3_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_4_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_5_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_6_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_7_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_8_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_9_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_10_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_11_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_12_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_13_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_14_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_15_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_16_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_17_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_18_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/6 - Miscellaneous/Male/Sean Lenhart/miscellaneous_19_sean.wav"),
]

var grunt_streams = [
	# --- FEMALE: Karen Cenon ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_1_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_2_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_3_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_4_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_5_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_6_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_7_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_8_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_9_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Karen Cenon/grunting_10_karen.wav"),

	# --- FEMALE: Meghan Christian ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_1_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_2_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_3_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_4_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_5_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_6_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_7_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_8_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_9_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Female/Meghan Christian/grunting_10_meghan.wav"),

	# --- MALE: Alex Brodie ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_1_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_2_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_3_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_4_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_5_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_6_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_7_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_8_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_9_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Alex Brodie/grunting_10_alex.wav"),

	# --- MALE: Ian Lampert ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_1_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_2_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_3_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_4_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_5_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_6_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_7_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_8_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_9_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Ian Lampert/grunting_10_ian.wav"),

	# --- MALE: Sean Lenhart ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_1_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_2_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_3_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_4_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_5_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_6_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_7_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_8_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_9_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/9 - Grunting/Male/Sean Lenhart/grunting_10_sean.wav"),
]

var damage_streams = [
	# --- FEMALE: Karen Cenon ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_1_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_2_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_3_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_4_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_5_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_6_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_7_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_8_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_9_karen.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Karen Cenon/damage_10_karen.wav"),

	# --- FEMALE: Meghan Christian ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_1_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_2_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_3_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_4_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_5_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_6_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_7_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_8_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_9_meghan.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Female/Meghan Christian/damage_10_meghan.wav"),

	# --- MALE: Alex Brodie ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_1_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_2_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_3_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_4_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_5_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_6_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_7_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_8_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_9_alex.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Alex Brodie/damage_10_alex.wav"),

	# --- MALE: Ian Lampert ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_1_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_2_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_3_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_4_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_5_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_6_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_7_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_8_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_9_ian.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Ian Lampert/damage_10_ian.wav"),

	# --- MALE: Sean Lenhart ---
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_1_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_2_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_3_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_4_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_5_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_6_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_7_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_8_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_9_sean.wav"),
	preload("res://assets/sfx/Super Dialogue Audio Pack v1/Step 2 - Audio Files/7 - Damage/Male/Sean Lenhart/damage_10_sean.wav"),

]

func _ready():
	
	# Connect the finished signal to our automatic progression logic
	self.finished.connect(_on_track_finished)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 1. Build the list
	_scan_music_folder(music_folder)
	
	# 2. Handle Late Joiners (if this client is joining a server)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# 3. If we are the server/host, pick a random starting track
	if multiplayer.is_server() and track_list.size() > 0:
		var random_index = randi() % track_list.size()
		sync_music_by_path.rpc(track_list[random_index])

# --- Folder Scanning ---

func _scan_music_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var clean_name = file_name.replace(".import", "").replace(".remap", "")
				if _is_audio_file(clean_name):
					var full_path = path.path_join(clean_name)
					if not track_list.has(full_path):
						track_list.append(full_path)
			file_name = dir.get_next()
		track_list.sort() # Sorting is still good practice for Next/Prev logic
	else:
		push_error("MusicManager: Cannot open path " + path)

func _is_audio_file(file_name: String) -> bool:
	return file_name.get_extension().to_lower() in ["mp3", "ogg", "wav"]

# --- Controls ---

func next_track():
	if multiplayer.is_server() and track_list.size() > 0:
		var current_idx = track_list.find(current_track_path)
		var next_idx = (current_idx + 1) % track_list.size()
		sync_music_by_path.rpc(track_list[next_idx])

func previous_track():
	if multiplayer.is_server() and track_list.size() > 0:
		var current_idx = track_list.find(current_track_path)
		var prev_idx = (current_idx - 1 + track_list.size()) % track_list.size()
		sync_music_by_path.rpc(track_list[prev_idx])

# --- Networking ---

## The Server calls this to force everyone to play a specific file
@rpc("authority", "call_local", "reliable")
func sync_music_by_path(path: String, position: float = 0.0):
	if ResourceLoader.exists(path):
		current_track_path = path
		@warning_ignore("shadowed_variable_base_class")
		var stream = ResourceLoader.load(path)
		self.stream = stream
		self.play(position) # Start at specific time (useful for late joiners)
		print("MusicManager: Synced to ", path.get_file())
	else:
		push_error("MusicManager: Path not found during sync: " + path)

## Logic for Late Joiners
func _on_peer_connected(id: int):
	# If we are the server, tell the new person what we are currently playing
	if multiplayer.is_server() and current_track_path != "":
		sync_music_by_path.rpc_id(id, current_track_path, self.get_playback_position())


func _on_track_finished():
	# Only the server should decide what plays next to keep everyone in sync
	if multiplayer.is_server():
		print("Track finished, moving to next...")
		next_track()
