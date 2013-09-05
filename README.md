![Amnesty International logotype and logo banner](http://amnesty.ca/sites/default/files/ai-lockup-2c-banner.png)
LCARS
=====

Disclosure statement
--------------------
Amnesty International only uses data towards the universal recognition of human rights.

Purpose
-------
The purpose of this project is to organise and display data in a useful and customised form for individuals and sections within Amnesty International. ;
* Track the success of campaigns
* Determine which issues are important to our supporters
* Responds quickly to changes in the social media sphere

Naming
------

Library Computer Access/Retrieval System, see [Wikipedia article](http://en.wikipedia.org/wiki/LCARS) for more information.

Screencast
----------

[YouTube demo](http://youtu.be/lbcU5ZhoryA)


Screenshot
----------

![Screenshot](https://raw.github.com/AmnestyInternational/dashboard/master/lib/screenshot.png "Screentshot")

Install procedure
-----------------

Viewscreen is an edited instance of [Dashing](http://shopify.github.io/dashing/)

Install the gem from the command line. Make sure you have Ruby 1.9

    $ gem install dashing

Clone dashboard

    $ cd /path/to/install/dir
    $ git clone https://github.com/AmnestyInternational/Viewscreen.git

Bundle gems

    $ bundle

Update /jobs to suit needs and create lib/db_settings.yml

Start the server!

    $ dashing start

Point your browser at localhost:3030 and have fun!

If you want to run the Dashboard as a service check out this [gist](https://gist.github.com/gregology/5313326).

Tables in externaldata database
-------------------------------

 * AreacodeBoundary
   * Shape files for GIS queries
   * Static
 * Articles
   * News and blog articles
   * Updated hourly
 * CensusDivisionBoundary
   * Shape files for GIS queries
   * Static
 * CensusSubDivisionBoundary
   * Shape files for GIS queries
   * Static
 * CensusTractBoundary
   * Shape files for GIS queries
   * Static
 * ENsupporters
   * Supporters pulled from the Engaging Networks API
   * Updated daily
 * ENsupportersActivities
   * Supporter activities pulled from the Engaging Networks API
   * Updated daily
 * ENsupportersAttributes
   * Supporter flags pulled from the Engaging Networks API
   * Updated daily
 * EstPopCenDiv
   * Census data from Statscan
   * Static
 * fb_link_count
   * Counts of amnesty links shared on Facebook
   * Static
 * fb_page_post
   * Posts and comments from our Facebook page
   * Updated hourly
 * fb_page_post_stat
   * Stats over time of posts and comments from our Facebook page
   * Updated hourly
 * FederalElectoralDistrictsBoundary
   * Shape files for GIS queries
   * Static
 * MajorCity
   * Shape files for GIS queries
   * Static
 * MinorCity
   * Shape files for GIS queries
   * Static
 * Municipallty
   * Shape files for GIS queries
   * Static
 * PollingDivisionBoundary
   * Shape files for GIS queries
   * Static
 * PopulationCentresBoundary
   * Shape files for GIS queries
   * Static
 * PostalCodeCensusDivision
   * Shape files for GIS queries
   * Static
 * PostalCodeCensusSubDivision
   * Shape files for GIS queries
   * Static
 * PostalCodes
   * Postal Code GIS data from various sources
   * Static
 * PostalCodesExtra
   * Postal Code data queried against shape files for quicker queries
   * Static
 * ProvinceBoundary
   * Shape files for GIS queries
   * Static
 * TweetHashtags
   * Hashtag data for tweets
   * Updated every 10 mins
 * TweetRegions
   * Region data for tweets
   * Updated every 10 mins
 * Tweets
   * The main text data for tweets
   * Updated every 10 mins
 * tweets_old
   * No longer used, contains old data
   * Static
 * TweetsAnatomize
   * Tweets converted into single words for queries
   * Updated every 10 mins
 * TweetUrls
   * URL data for tweets
   * Updated every 10 mins
 * TweetUserMentions
   * User mentions data for tweets
   * Updated every 10 mins
 * TwitterFollowers
   * Follower data for tweets
   * Updated every 10 mins
 * TwitterUsers
   * User details from tweets
   * Updated every 10 mins

Views in externaldata database
------------------------------

 * vAI_CanadianTweets
   * Contains tweets pulled within Canada with user details
 * vAI_ContactWithAIC
   * List of ID's with date of last contact with AIC
 * vAI_Definition_ActiveSubscriber
 * vAI_Definition_CurrentDonor
 * vAI_Definition_CurrentDonorNew
 * vAI_Definition_CurrentMember
 * vAI_Definition_CurrentMonthlyDonor
 * vAI_Definition_CurrentSupporter
 * vAI_Definition_LapsedDonor
 * vAI_Definition_LapsedMember
 * vAI_Definition_LapsedSupporter
 * vAI_Definition_MajorDonor
 * vAI_SupporterDetails
   * List of users with useful metrics
 * vAI_SupporterDetailsGeo
   * As above with geo data included
 * vAI_Tweets
   * All tweet data with user details
