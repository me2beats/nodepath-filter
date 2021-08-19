#=========== Node utils ==================
static func get_nodes(node:Node)->Array:
	var nodes = []
	var stack = [node]
	while stack:
		var n = stack.pop_back()
		nodes.push_back(n)
		stack.append_array(n.get_children())
	return nodes


static func find_node_by_class_path(node:Node, class_path:Array, keep_order: = true)->Node:
	var res:Node
	var stack = []
	var depths = []

	var first = class_path[0]
	for c in node.get_children():
		if c.get_class() == first:
			stack.push_back(c)
			depths.push_back(0)

	if not stack: return res
	
	var max_ = class_path.size()-1

	while stack:
		var d = depths.pop_back()
		var n = stack.pop_back()

		if d>max_:
			continue
		if n.get_class() == class_path[d]:
			if d == max_:
				res = n
				return res

			if keep_order:
				for i in range(n.get_child_count()-1,-1,-1):
					var c = n.get_child(i)
					stack.push_back(c)
					depths.push_back(d+1)
					
			else:
				for c in n.get_children():
					stack.push_back(c)
					depths.push_back(d+1)

	return res






#=========== Script utils ================
static func get_nodepath_props(script:GDScript, script_prop_list = []):
	var result = []
	if not script_prop_list:
		script_prop_list = script.get_script_property_list()

	for i in script_prop_list:
		if i.type == TYPE_NODE_PATH:
			result.push_back(i.name)
	return result


static func get_script_prop_info(script:GDScript, prop:String, script_prop_list:=[])->Dictionary:
	var info:Dictionary
	if not script_prop_list:
		script_prop_list = script.get_script_property_list()
	for i in script_prop_list:
		if i.name == prop:
			return i
	return info


static func get_script_props_names_list(script:GDScript, script_prop_list:=[])->Array:
	var result: = []
	if not script_prop_list:
		script_prop_list = script.get_script_property_list()
	for i in script_prop_list:
		result.push_back(i.name)
	return result


#=========== Inspector utils =============
static func get_nodepath_buttons(inspector:EditorInspector)->Array:
	var buttons: = []
	var inspector_nodes = get_nodes(inspector)
	for node in inspector_nodes:
		if node.get_class() == 'Button' and node.text:
			var grand_parent:Node = node.get_parent().get_parent()
			if grand_parent.get_class() == 'EditorPropertyNodePath':
				buttons.push_back(node)
	return buttons


static func get_visible_scenetree_dialog(inspector:EditorInspector)->AcceptDialog:
	var scene_tree_dialog:AcceptDialog
	var inspector_nodes = get_nodes(inspector)
	for node in inspector_nodes:
		if node.get_class() == 'SceneTreeDialog' and node.visible:
			scene_tree_dialog = node
			break
	return scene_tree_dialog



#=========== TreeItem utils =============
static func get_item_children(item:TreeItem)->Array:
	item = item.get_children()
	var children = []
	while item:
		children.append(item)
		item = item.get_next()
	return children

static func get_item_children_rec(item:TreeItem)->Array:
	var items = [item]
	var result = []
	while items:
		item = items.pop_back()
		result.push_back(item)
		var children = get_item_children(item)
		items.append_array(children)
	return result


#=========== type utils =================
static func get_parent_classes(cls:String)->Array:
	var classes: = []
	cls = ClassDB.get_parent_class(cls)
	while cls:
		classes.push_back(cls)
		cls = ClassDB.get_parent_class(cls)
	return classes


#=========== Sttring utils =================
static func capitaized2snake(string:String)->String:
	return pascal2snake(string.replace(' ', ''))

static func pascal2snake(string:String)->String:
	var result = PoolStringArray()
	for ch in string:
		if ch == ch.to_lower():
			result.append(ch)
		else:
			result.append('_'+ch.to_lower())
	result[0] = result[0][1]
	return result.join('')
