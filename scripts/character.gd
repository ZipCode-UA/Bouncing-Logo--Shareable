extends CharacterBody2D

# Creates an image, which overlays a texture, that moves around the screen, changes colors as it bounces...
#...into the walls, and plays a sound effect when it touches the corner. 

# Recommended properties & variables to modulate:
	# Properties: 
		# Image: Color - the initial color of the image.
		# Image: Transform -> Size - the size of the image (in pixels). 
		# Texture: Texture - the picture you want to display. 
		# Texture: 'Size' - the size of the collider, modified in the 2D editor.
		# Collider: 'Size' - the size of the collider, modified in the 2D editor.
		# SFX: Stream - the sound effect that plays when the corner effect occurs.
	# Variables:
		# speed - how fast the image moves.
		# lenience - the distance in pixels from the corner of the screen where a corner hit can occur.

# Note: 'size' is NOT a property that can be modified in the inspector FOR THOSE NODES...
#...to change their sizes, you must modify them in the 2D editor.

# Note: The image size, the texture 'size', and the collider 'size' must all be the same...
#...or else it will not work as intended.

# The speed & direction of the image.
var speed: float = 600 # Amount in pixels.
var direction = Vector2()

# Determines whether the image can corner. 
# This variable prevents corners from occurring multiple times within a specified time span.
var cornered_recently: bool = false

# References to nodes and their properties.
@onready var sfx = $SFX
@onready var corner_prevention_timer = $Timer
@onready var image = $Image
@onready var image_size = $Image.size # The width & height of the image as a 'list'*.
@onready var window_size = get_viewport().size # The width & height of the window as a 'list'*.

# *In Godot, lists are the same as arrays.

# The x & y position of the top left of the window. 
var origin: int = 0 

# The amount of pixels from the corner where a corner hit can occur.
# Controls how easy it is to corner, a lower value makes it harder to corner. Recommended Value: 4
var lenience: float = 4

# Holds the value of the width & height of the image respectively.
var width_of_image: int 
var height_of_image: int  

# Holds the value of the width & height of the window respectively.
var width_of_window: int  
var height_of_window: int  

# When this object is first created...
func _ready() -> void:
	#...it is assigned a random direction, a intial velocity, and the...
	#...width & height of the image and window are assigned to their respective variables.
	direction = randomize_direction()
	velocity = direction * speed
	designate_sizes()

func designate_sizes():
	# The width & height of the image are each assigned to their respective variables.
	width_of_image = image_size[0]
	height_of_image = image_size[1]
	
	# The width & height of the window are each assigned to their respective variables.
	width_of_window = window_size[0]
	height_of_window = window_size[1]

# Randomizes the intial direction of the image.
func randomize_direction():
	# A blank vector that will be modified to change the direction of the image.
	var initial_direction = Vector2()
	
	# Two arrays which hold the values for the x & y directions.
	var direction_selection_x = [4,-4]
	var direction_selection_y = [3,-3]
	
	# Selects a random x & y direction from the array.
	initial_direction.x = direction_selection_x.pick_random()
	initial_direction.y = direction_selection_y.pick_random()
	
	# Returns a normalized vector, with a magnitude of 1, with a randomized x & y direction.
	return initial_direction.normalized()

# Assigns a new randomized color for the image.
func randomize_color():
	# Selects a random float value from 0.0 to 1.0 for the red, green, & blue properties...
	#...& assigns the alpha, how transparency the image is, to a float. 
	# These properties will make the new color of the image.
	var red: float = randf() 
	var green: float = randf()
	var blue: float = randf()
	var alpha: float = 0.5 # Set to 0.5 to make the texture appear while still changing the color.
	
	# Assigns the new color to the color property of the image.
	image.color = Color(red, green, blue, alpha) 

func _physics_process(delta: float) -> void:
	# Handles collisions & randomizes the color of the image upon collisions.
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = (velocity.bounce(collision.get_normal()))
		randomize_color()
	
	# If the image has not cornered recently...
	if (!cornered_recently):
		#...and the position of the image is in within the proper area, close to the corners of the screen...
		#...then the corner effect occurs.
		
		# Top Left Corner 
		if (position.x <= (origin + lenience) && position.y <= (origin + lenience)): 
			corner_hit_occurred()
		
		# Top Right Corner
		if (position.x >= ((width_of_window - width_of_image) - lenience) && position.y <= (origin + lenience)): 
			corner_hit_occurred()
		
		# Bottom Left Corner
		if (position.x <= (origin + lenience) && position.y >= ((height_of_window - height_of_image) - lenience)): 
			corner_hit_occurred()
		
		# Bottom Right Corner
		if (position.x >= ((width_of_window - width_of_image) - lenience) \
		&& position.y >= ((height_of_window - height_of_image) - lenience)):
			corner_hit_occurred()

# Handles the corner effect.
func corner_hit_occurred():
	# Stops the corner effect from occuring.
	cornered_recently = true
	# Starts a timer that will allow corners to occur once the timer ends.
	corner_prevention_timer.start()
	# Plays the sound effect.
	sfx.play()

# When the timer ends, the corner effect can occur again.
func _on_timer_timeout() -> void:
	cornered_recently = false
