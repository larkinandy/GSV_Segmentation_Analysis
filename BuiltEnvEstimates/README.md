# GSV_Segmentation_Analysis
Compare object based classification of GSV images with remote sensing imagery

**Author:** [Andrew Larkin](https://www.linkedin.com/in/andrew-larkin-525ba3b5/) <br>
**Co-Author:** [Xiang Gu](https://www.researchgate.net/profile/Xiang_Gu9) <br>
**Affiliation:** [Oregon State University, College of Public Health and Human Sciences](https://health.oregonstate.edu/) <br>
**Principal Investigator:** [Perry Hystad](https://health.oregonstate.edu/people/perry-hystad) <br>
**Co-Investigator:** [Lizhong Chen](http://web.engr.oregonstate.edu/~chenliz/) <br>
**Date Created:** November 14th, 2018

**Summary** <br>
This folder contains built environment estimates derived from Google Street View (GSV) and remote sensing imagery.  Scripts used to derived this estimates are available on other github repositories listed in the external links section below. <br>

**Codebook** <br>
Variables are either built environment measures derived from images, built environment measures derived from remote sensing, or metadata about the GSV image and corresponding location.  Estimates of perceived scores from the Place Pulse dataset are available in the external link listed below.  <br>

**Image based built environment measures** <br>
image measures are either estimates derived from a single image or are the average (mean) of a measure for all images at a single latitute/longitude location.  These measures were derived using the PSPNEt model referenced below <br>

- **x_avg** - average (mean) percent of pixels of object x for all images at the corresponding location<br>
- **x** - percent of pixels classified as object x for a single image <br>

**Remote sensing based environment measures** <br>
all remote sensing measures are based on latitude/longitude coordinates <br>

- **mjRdsXXXm** - length of roads (meters) within XXX meters of a corresponding location. Derived from dataset 1. <br>
- **NO2XXXm** - mean near surface outdoor NO2 concentration (ppb) within XXX meters of a corresponding location.  Deriveed from dataset 2. <br>
- **trXXXm** - mean percent tree cover (%) within XXX meters of a corresponding location.  Derived from dataset 3. <br>
- **imp1000m** - mean percent impervious surface area (%) within 1km of a corresponding location.  Derived from dataset 4. <br>
- **pop1000m** - mean population density (persons/km) within 1km of a corresponding location.  Derived from dataset 5. <br>
- **NDVI250m** - mean NDVI (normalized units) within 250m or a corresponding location.  Derived from dataset 6. <br>
- **PM251000m** - mean outdoor PM2.5 (ug/m3) within 1km of a corresponding location.  Derived from dataset 7. <br>

**Image metadata variables** 

- **loc_id** - unique id for each location <br>
- **latitude** - latitude for each location in WGS1984 <br>
- **longitude** - longitude for each location in WGS1984 <br>
- **imgId** - unique id for each GSV image <br>
- **year** year GSV image was taken <br>
- **month** month GSV image was taken

**Referenced Datasets** <br>
1) **Openstreetmap** - https://wiki.openstreetmap.org/wiki/Main_Page <br>
2) **Larkin et al., 2017** - https://github.com/larkinandy/LUR-NO2-Model <br>
3) **insert tree cover reference** <br>
4) **insert impervious surface area reference** <br>
5) **Gridded World of the Population, v.4** - http://sedac.ciesin.columbia.edu/data/collection/gpw-v4 <br>
6) **MODIS Annual NDVI** - https://modis.gsfc.nasa.gov/data/dataprod/mod13.php <br>
7) **van Donkelaar et al., 2016** - http://sedac.ciesin.columbia.edu/data/set/sdei-global-annual-gwr-pm2-5-modis-misr-seawifs-aod <br>


**External Links** <br>
- **MIT Place Pulse** - http://pulse.media.mit.edu/about/ <br>
- **Image Segmentation Analysis** - TODO: insert Xiang Gu's github page <br>
- **Remote Sensing Buffer Estimates** - https://github.com/larkinandy/LUR-NO2-Model
