# Tips and tricks

While not related to this add-on, there are many techniques you can use to
further improve your scene's performance.

## Use your least detailed LOD mesh as a shadow-only mesh

After selecting a MeshInstance, you can choose to make it cast *only* shadows in
the Geometry Instance section of the inspector. You can also choose to make the
MeshInstance not cast shadows.

You can use this to improve performance. To do so, duplicate your `-lod2`
MeshInstance and set its shadow casting mode as **Shadows Only**. Then set the
shadow casting mode of all your LOD meshes (except the one you just duplicated)
to **Off**. A less detailed variant will now be used for casting shadows, but
the visual difference is usually barely noticeable. However, this can bring
significant performance gains when using many lights with shadows enabled.

**Note:** If your lowest-detailed LOD mesh doesn't cast shadows (e.g. because it
uses Distance Fade), duplicate its material and make it cast shadows first.
Otherwise, the shadow-only duplicate won't cast any shadows.

## Use SpatialMaterial's Distance Fade to smoothly fade out distant objects

You can enable Distance Fade in your mesh's SpatialMaterial. For opaque objects,
make sure to set the fade mode to **Object Dither** rather than **Pixel Alpha**.
Otherwise, the object will be considered transparent and will be slower to
render.

Set the Min Distance property to the LOD 2's maximum distance, then set the Max
Distance property a few units lower. This way, the material will fade out before
disappearing completely.

**Note:** This add-on doesn't support fading between mesh LOD levels by using
Distance Fade yet, since this would require displaying two LOD levels at the
same time.

## Use light coronas to keep distant lights visible

You can use a billboarded sprite to represent distant lights. This way, lights
will fade out in a more discreet way and will remain visible in the distance.

This technique is often used in open world games such as GTA V. This way,
distant cities can be kept illuminated while keeping the rendering cost low.

Here's a step-by-step:

- Create a 256×256 light corona texture. A simple white-to-transparent circular
  gradient made with an image editor will suffice. Make sure to change its
  compression mode to **Lossless** in the Import dock, as **Video RAM** may
  introduce noticeable artifacts.
- Create a MeshInstance node. Select it, add a new QuadMesh and create a new
  SpatialMaterial for it.
- Edit the SpatialMaterial's billboard mode and set it to **Billboard**.
- If you want to hide the light corona when the camera is up close, enable
  **Distance Fade** and configure it accordingly.

**Note:** As explained above, don't make the light corona mesh a child of the
LOD light node. Instead, place it besides the LOD light node in the scene tree.
If you make the light corona mesh a child of the light node, it will disappear
once the light is hidden by the LOD system.
