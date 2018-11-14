# GSV_Segmentation_Analysis
Compare object based classification of GSV images with remote sensing imagery

TODO: Insert image that summarizes repository <br>


**Author:** [Andrew Larkin](https://www.linkedin.com/in/andrew-larkin-525ba3b5/) <br>
**Co-Author:** [Xiang Gu](https://www.researchgate.net/profile/Xiang_Gu9) <br>
**Affiliation:** [Oregon State University, College of Public Health and Human Sciences](https://health.oregonstate.edu/) <br>
**Principal Investigator:** [Perry Hystad](https://health.oregonstate.edu/people/perry-hystad) <br>
**Co-Investigator:** [Lizhong Chen](http://web.engr.oregonstate.edu/~chenliz/) <br>
**Date Created:** November 14th, 2018

**Summary** <br>
The purpose of this project is to evaluate whether GSV image estimates capture characteristics of the built environment, most notably characteristics dependent on visibility (e.g. beauty) compared to traditional estimates based on satellite imagery.  The [MIT Place Pulse dataset](http://pulse.media.mit.edu/about/) is the underlying dataset used for comparisons.  Place Pulse contains georeferenced street view imagery and 1.5 million participant comparisons of images on characteristics such as beauty, safety, and liveliness.  GSV images estimates were derived using a PSPNet model, while remote sensing estimates were derived using buffers around Pulse Place locations in ArcGIS.

**Repository Structure** <br>
Files are divided into two folders, based on their relative stage of project development. Scripts from a [previous project](https://github.com/larkinandy/LUR-NO2-Model) were utilized for downloading remote sensing imagery and generating buffer based estimates <br>

- **[BuiltEnvEstimates](./BuiltEnvEstimates)** - Image and remote sensing estimates of the built environment (may not be available until publication). <br>
- **[StatisticalAnalysis](./StatisticalAnalysis)** - Scripts to perform descriptive statistics and create regression models using built environment estimates.  

**External Links** <br>

TODO: insert link to publication once published <br>

- **MIT Place Pulse** - http://pulse.media.mit.edu/about/ <br>
- **Image Segmentation Analysis** - TODO: insert Xiang Gu's github page <br>
- **Remote Sensing Buffer Estimates** - https://github.com/larkinandy/LUR-NO2-Model
