tool
extends EditorPlugin

const Utils = preload("utils.gd")

var inspector:EditorInspector = get_editor_interface().get_inspector()
var nodepath_classes: ={}

var default_color:Color
var disabled_color:Color

const settings_defaults = {
	include_derived_classes = true
}

const settings_path = 'me2beats_plugins/nodepath_filter/'

const SettingsNames = {
	include_derived_classes = settings_path+'include_derived_classes'
}

var editor_settings:EditorSettings

var plugin

func _enter_tree():
	editor_settings = get_editor_interface().get_editor_settings()
	if !editor_settings.has_setting(SettingsNames.include_derived_classes):
		editor_settings.set_setting(
			SettingsNames.include_derived_classes,
			settings_defaults.include_derived_classes
		)


	plugin = preload("inspector_plugin.gd").new()
	plugin.plugin = self
	add_inspector_plugin(plugin)


func _exit_tree():
	remove_inspector_plugin(plugin)



func handle_object(object:Object):
	yield(get_tree(), "idle_frame")
	var script:GDScript =  object.get_script()
	if not script: return


	if not default_color:
		default_color = inspector.get_color("font_color", "Tree")

	if not disabled_color:
		disabled_color = inspector.get_color("font_color_disabled", "Button")

	update_nodepath_classes(script)
	connect_nodepath_buttons()


func connect_nodepath_buttons():
	var nodepath_buttons = Utils.get_nodepath_buttons(inspector)
	for button in nodepath_buttons:
		if button.is_connected("pressed", self, 'on_set_nodepath_button_pressed'): continue
		var grand_parent:Node = button.get_parent().get_parent()
		(button as Button).connect(
			"pressed",
			self,
			'on_set_nodepath_button_pressed',
			[grand_parent.get('label')]
		)



func update_nodepath_classes(script:GDScript)->void:
	nodepath_classes.clear()
	var script_prop_list = script.get_script_property_list()
	var nodepath_props = Utils.get_nodepath_props(script, script_prop_list)
	if not nodepath_props: return
	nodepath_classes = get_nodepath_class_pairs(script, nodepath_props, script_prop_list)



func get_nodepath_class_pairs(script:GDScript, nodepath_props:Array, script_prop_list:=[]):
	if not script_prop_list:
		script_prop_list = script.get_script_property_list()
	var pairs = {}
	var prop_list = Utils.get_script_props_names_list(script, script_prop_list)
	for nodepath_prop in nodepath_props:
		nodepath_prop = nodepath_prop as String
		if !nodepath_prop.ends_with('_path'): continue
		var prop_name = nodepath_prop.substr(0, nodepath_prop.length()-5)
		var info = Utils.get_script_prop_info(script, prop_name, script_prop_list)
		if info['class_name']:
			pairs[nodepath_prop] = info['class_name']
	return pairs



func set_only_tree_items_with_class_selectable(tree:Tree, cls:String):
	var current_scene_root:Node = get_editor_interface().get_edited_scene_root()
	if not current_scene_root: return

	var dialog_tree_root:TreeItem = tree.get_root()
	if not dialog_tree_root: return

	var tree_items:Array = Utils.get_item_children_rec(dialog_tree_root)
	tree_items.push_back(tree.get_root())

	for i in tree_items:
		i = i as TreeItem
		var nodepath:NodePath = i.get_metadata(0)
		
		var node:Node = current_scene_root.get_node(nodepath)

		# is it possible?
		if not node: continue
		
		var node_class:String = node.get_class()

		if node_class == cls: continue

		var node_classes = Utils.get_parent_classes(node_class)

		var include_derived_classes = editor_settings.get_setting(SettingsNames.include_derived_classes)
		if !include_derived_classes or ! cls in node_classes:
			i.set_selectable(0,0)
			i.set_custom_color(0, disabled_color)





func on_set_nodepath_button_pressed(prop_capitalized:String):
	var prop = Utils.capitaized2snake(prop_capitalized)

	yield(get_tree(), "idle_frame")

	var scene_tree_dialog:AcceptDialog = Utils.get_visible_scenetree_dialog(inspector)
	if not scene_tree_dialog:
		return

	var tree:Tree = Utils.find_node_by_class_path(
		scene_tree_dialog,
		['VBoxContainer', 'SceneTreeEditor', 'Tree'])

	if not tree:
		push_error('no tree!')
		return
	
	# maybe could be done better:
	if not nodepath_classes.get(prop):
		reset_filter(tree)
		return

	var inspector_nodes = Utils.get_nodes(inspector)
	var cls:String = nodepath_classes[prop]
	
	set_only_tree_items_with_class_selectable(tree, cls)

	
	var filter:LineEdit = Utils.find_node_by_class_path(
		scene_tree_dialog,
		['VBoxContainer', 'LineEdit'])

	if not filter.is_connected("text_changed", self, "on_filter_text_changed"):
		filter.connect("text_changed", self, "on_filter_text_changed", [filter, tree, cls])

#	scene_tree_dialog.connect("hide", self, "on_dialog_close", [tree], CONNECT_ONESHOT)


func reset_filter(tree:Tree):
	var root = tree.get_root()
	var items = Utils.get_item_children_rec(root)
	items.push_back(root)
	for item in items:
		item = item as TreeItem
		item.set_selectable(0,true)
		if default_color: #?????
			item.set_custom_color(0, default_color)

# not used now
func on_dialog_close(tree:Tree):
	reset_filter(tree)
	

func on_filter_text_changed(text:String, filter:LineEdit, tree:Tree, cls:String):
	yield(get_tree(), "idle_frame")
	set_only_tree_items_with_class_selectable(tree, cls)
