# BirdsOfAFeather_FlockTogether

![image_oiseau_petit-1](https://github.com/user-attachments/assets/b855764d-54d1-4f12-b404-28302a39d4a9)


* **Developed by:** Thomas & Héloïse
* **Developed for:** Carole & Paul
* **Team:** Manceau
* **Date:** February 2025
* **Software:** Fiji


### Images description

RGB images of birds. A ruler is needed on the image for calibration.

     
### Macro description

1. Indicate the bird's order, family, genus, species, subspecies, and sex.
2. Place two points 1 cm apart on the ruler to calibrate the image.
3. Place 8 landmarks on the bird, crop the image around them, and scale it to a fixed size of 500 × 250 pixels.
4. Specify the number of vertical boundaries and their shape (Line, V, Inverted V, U, or Inverted U).
5. Adjust each vertical boundary to its correct position and create vertical regions accordingly.
6. Specify the number of longitudinal regions and which vertical regions each longitudinal region crosses.
7. Draw each longitudinal region and subtract it from the vertical regions it crosses.
8. For each region (vertical or longitudinal), select the pattern (Uniform, Bars, Scales, or Spots) and specify the colors of both the pattern and the background.

### Dependencies

*orders_families.csv* and *color_palette.png* files

### Version history

Work in progress
