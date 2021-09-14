# Sound Methodology for Downloading Webpages

Downloading webpages is a challenging task. In this work, we establish an effective methodology to download a webpage as completely as possible at a given point in time.

This is the code repository for the TMA 2021 paper, "[Sound Methodology for Downloading Webpages](https://www.cs.umd.edu/~dml/papers/webpages_tma21.pdf)". 

This repository contains submodules for our forks of ZBrowse and Crawlium containing the modified nodejs files to disable caching, use our specific User Agent Strings for mobile and desktop browsers and to incorporate the protocol (https vs http) and www subdomain for the website URLs.


## Abstract

Headlessly downloading webpages is a common and useful mechanism in many measurement projects. Such a basic task would seem to require little consideration. Indeed, most prior work of which we are aware chooses a relatively basic tool (like Selenium or Puppeteer) and assumes that downloading a page once yields all of its content—which may work well for static content, but not for dynamic webpages with third-party content. This paper empirically establishes sound methods for downloading webpages. We scan the Alexa top-10,000 most popular websites (and other, less popular sites) with different combinations of tools and reloading strategies. Surprisingly, we find that even sophisticated tools (like Crawlium and ZBrowse) do not get all resources or links alone, and that downloading a page even dozens of times can miss a significant portion of content. We investigate these differences and find that they are, surprisingly, not strictly due to ephemeral content like ads. We conclude with recommendations for how future measurement efforts should download webpages, and what they should report on.


## Try it yourself

To clone the repo, make sure you clone all of the submodules present.

```
# git clone --recursive https://github.com/breakerspace/downloading-webpages
```

You may run the files starting with `tools_30_runs` to download a webpage by repeatedly refreshing 30 times, while you can use the files starting with `tools_adaptive_runs` to download a webpage untill no new data is obtained in the last 3 consecutive page refreshes. The output for Crawlium, ZBrowse and the parsed data are saved in separate folders. 
Example commands to obtain data for top-1000 most popular Alexa websites on desktop browser using the adaptive strategy:

```
$ mkdir deepcrawl_results zbrowse_results tools_results
$ ./tools_adaptive_runs_AWS_desktop.sh alexa.txt 1 7777 1 1000
```

Each of the main files, say `tools_adaptive_runs_AWS_desktop.sh` in turn calls `tools_dp_zb_desktop.sh`, to use Crawlium and ZBrowse consecutively, and `data_collection_desktop.sh`, to parse the Crawlium and Zbrowse output files (using the `.py` files) and collect the data in our required format. 
The file `diif_betn_runs.c` is used by the adaptive strategy to determine that there is no new data in the last 3 consecutive page refreshes.


## Citation

To cite this paper, please use the Bibtex [here]().
