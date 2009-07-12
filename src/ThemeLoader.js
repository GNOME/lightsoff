Clutter = imports.gi.Clutter;

function load_svg(theme, file)
{
	var tx = new Clutter.Texture({filename: imports.path.file_prefix + "themes/"
	                                        + theme + "/" + file});
	tx.filter_quality = Clutter.TextureQuality.HIGH;
	tx.hide();
	return tx;
}

function load_theme(stage, theme)
{
	if(theme.loaded)
		return;
	
	theme.loaded = true;

	for(actor in theme.textures)
		stage.add_actor(theme.textures[actor]);
}
