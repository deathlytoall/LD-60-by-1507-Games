extends CanvasLayer

const frames = preload("res://Items/item.tscn::SpriteFrames_xa11k")
var descriptions = ['Mirror: fire a second zap randomly','Moniter: fFire a second zap near main fire','Lightbulb: Zaps grow with time','Glass Shard: Allows for zaps to peirce','9.0V Battery: You heal more from AAA batteries','Memory Chip: Damage Up','Zap: Damage up','Alien: Damage up','USB: Damage increased by 50%','RAM: Increased movement speed','Horsey: Allows for a double tap dash','Tesla: Burst zaps','Cross: Release zaps in 4 directions at once','CPU: Zaps size doubled', 'Solar Panel: Slows down passive battery drain']

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	%RichTextLabel.clear()
	for x in Global.items:
		%RichTextLabel.add_image(frames.get_frame_texture("default", x + 1), 24, 24)
		%RichTextLabel.add_text(descriptions[x])
		%RichTextLabel.newline()
		
