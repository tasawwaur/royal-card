from PIL import Image

# Open the portrait login background image
img = Image.open("login_bg.jpg")

# Rotate it 90 degrees counter-clockwise (270 degrees clockwise) to make it landscape
rotated = img.transpose(Image.ROTATE_270)
rotated.save("login_bg_rotated.jpg", "JPEG")
print("Rotated image size:", rotated.size)
