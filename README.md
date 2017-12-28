# honours-project-2017: Web interactive plots in R 

**Duration:** Mar 2017 - Nov 2017

This repository contains all things related to the project.
An online report/dissertation can be found here: https://ysoh286.github.io/honours-project-2017/

(TL;DR - detailed notes for each week can be found [here](https://github.com/ysoh286/honours-project-2017/blob/master/detailed-notes.md))

**Bullet bites:**

- Includes a summary of current tools for creating interactive data visuals in R: 
  shiny, ggvis, crosstalk + plotly, animint (... and bits of other htmlwidgets, ggiraph)
 - A step into gridSVG + DOM packages and bits of experimentation with shiny + gridSVG
 - The creation of a 'convenience' wrapper/experimentation of grid + gridSVG + DOM (interactr) to achieve certain 'challenges'
 - Discussion of 'interactr' and the future of web based interactive statistical graphics will go in R
 
**Verdict:** This topic of interactive web graphics is in fact very huge. 

interactr's only just a set of code 'examples'. In theory it sounds promising, but there are too many flaws with it (specifically with structure and a need for a better user API). It is more of an experimental package for playing around with Murrell's DOM package. 

A major downfall for using SVG is its inability to handle many components on a web page and the browser starts to crawl. For those in need to render more than 1000+ elements, we're in need of openGL/webGL environments. It would be interesting if there happens to be a 'gridGL' in the future for translating grid objects from R to webGL elements.
