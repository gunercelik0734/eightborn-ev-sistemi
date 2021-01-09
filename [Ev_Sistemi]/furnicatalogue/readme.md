Bu script hcankara35(ibrahim KAVAK) tarafından güncellenmiştir.

# Requirements:

MF_ObjectSpawner
ESX
  * Instance
  * ESX_Property
  * playerhousing

  [*] = optional


# Usage:

In-game:
  /furni - brings up the furniture panel (must be inside a house to use it).

Setup:
  Drag and drop the folder into your resources.
  Don't try and rename the folder, else break.
  Make sure you've been added to the authorized list.
 In server.cfg, you must have a convar set:
  set connection_string "enter your server connection string here (example: my-fivem-server.com OR 112.37.43.00)"
  If you have no idea what this ^ means, contact us through the webstore support chat.

Add Items:
  To add items, add an image into the "img" directory.
  The image filename must be the same as the model name, and .png type.
  Make sure you add the image into the __resource.lua, under "file".
  Open the "furni.lua" file and add a new element to the table. Example:

  [20] = {
    [1] = "Coffee Machine",             -- Item name/label
    [2] = 100,                          -- Price
    [3] = "some_coffee_machine_model",  -- Model name
  },
