# BGal_Senescence 

* **Developed by:** Héloïse
* **Developed for:** Adèle
* **Team:** De Thé
* **Date:** February 2025
* **Software:** Fiji


### Images description

2D RGB images taken with a x20 or x40 objective.

     
### Macro description

* Convert RGB image to 8-bits and detect cells with Cellpose
* Perform RGB image color deconvolution with Giemsa stain vectors
* Estimate background noise in methylene blue channel
* Measure each cell mean intensity in methylene blue channel as an indication of cell senescence

### Dependencies

* **PTBIOP** Fiji plugin
* **Cellpose** conda environment + *cyto2* model

### Version history

Version 1 released on February 12, 2025.
