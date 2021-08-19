extends EditorInspectorPlugin

var plugin: EditorPlugin

func can_handle(object:Object):
	return object.get_script()


#func parse_begin(object):
func parse_begin(object:Object):
	plugin.handle_object(object)
