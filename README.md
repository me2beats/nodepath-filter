# nodepath-filter

Filter nodes in Inspector NodePath dialog by type/class.
This is an attempt to solve this https://github.com/godotengine/godot-proposals/issues/934

# usage
Say you have `export (NodePath) var control_path`. This node should be `Control`

Then all you need is to create property named `control` (that is same as `control_path` but without `_path`)  and specify the type:
`var control:Control`

![script](https://user-images.githubusercontent.com/16458555/130135270-25b30e91-cd91-461d-9fde-6945941d058d.JPG)


Now only `Control` nodes can be selected in NodePath dialog.

![inspector](https://user-images.githubusercontent.com/16458555/130135345-034aba2f-1426-4f04-befe-016ca23539c6.JPG)

![select a node dont allow derived](https://user-images.githubusercontent.com/16458555/130135394-8eeed3ce-0381-4f6f-8cf0-34ee754a8a10.JPG)

There is also a setting in EditorSettings

![settings](https://user-images.githubusercontent.com/16458555/130135548-d1afb9d4-fb49-4e05-9c11-1c8765aac415.JPG)


(me2beats_plugins/nodepath_filter/include_derived_classes)
to allow selecting Nodes of derived (child) clases
(in this case, not only Controls but also Containers etc, but still not Nodes).
![select a node allow derived](https://user-images.githubusercontent.com/16458555/130135415-ab64a7f2-527d-468f-954d-e26e4a9eaeeb.JPG)


# Known issues:
- when enabling the plugin (and in some other cases), you should change node selection to make it work.
- currently works only for GDScript
