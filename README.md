# Project Variants

Project contains 4 variants (in 4 different branches):

---

## Simple asset version

In this version, the keyboard just sends a tokenized asset name, and the companion app takes the asset with the same name and renders it in the canvas.

### Pros:
- Easy to implement
- Fast
- Lightweight

### Cons:
- The companion app and keyboard app must have the same assets embedded with identical names

---

## Encoded text version

In this version, the keyboard sends image data as an encoded Base64 string.

### Pros:
- Keyboard and companion app are not linked through assets

### Cons:
- For big images, it takes a long time to send through `UIInputViewController.textDocumentProxy.insertText`

---

## Shared UserDefaults version

In this version, the keyboard stores image data in UserDefaults that are shared using App Groups.

### Pros:
- Simple implementation
- Quite fast even for big images
- Keyboard and companion app are not linked through assets

### Cons:
- Need to add apps to the same App Group
- In a security context, this could introduce an attack vector through UserDefaults

---

## Shared Storage version

In this version, the keyboard and companion app communicate using IPC, shared memory, and semaphores.

### Pros:
- Fastest data transfer of all versions

### Cons:
- Added complexity
- Need to consider semaphore deadlocks
- Uses memory-unsafe code with a possibility of memory corruption