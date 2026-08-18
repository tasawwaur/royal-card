from PIL import Image

# Open original landscape image
img = Image.open("login.jpg")

# Symmetrical pill crop boxes matching the exact Facebook button coordinates (424, 405, 610, 449)
# Height: 44px (Y: 405 to 449)
# Width: 186px
google_box = (108, 405, 294, 449)
btn_google = img.crop(google_box)
btn_google.save("btn_google.png", "PNG")

facebook_box = (424, 405, 610, 449)
btn_facebook = img.crop(facebook_box)
btn_facebook.save("btn_facebook.png", "PNG")

guest_box = (739, 405, 925, 449)
btn_guest = img.crop(guest_box)
btn_guest.save("btn_guest.png", "PNG")

print("Successfully cropped button pills with height 44px!")
