# Project Setup Instructions

__Create and launch the vagrant box__

	git git@github.com:cloudspace/rss.cloudspace.com.git
    cd ./rss.cloudspace.com
    librarian-chef install
    vagrant up

__After the box is up, `vagrant ssh`__
  
    sudo gem install bundler
    cd /srv/rss.cloudspace.com
    bundle
    rake db:setup
    rails s
    
***

#API Specification

## Entities

### feed
<small>Represents a `Feed` object, where `feed_items` is an array of up to 10 of the most recent feed_item entities associated with this feed.</small>

    {
    	"id": 16,
    	"name": "Engadget",
    	"url": "http://www.engadget.com/rss.xml",
    	"icon": "http://s3.amazonaws.com/rss.cloudspace.com/feed/16/icon.png",
    	"feed_items": [...]
    }
    
### feed_item
<small>Represents a `FeedItem` object. Associated with a feed.</small>

    {
    	"id": 255,
    	"feed_id": 16,
    	"title": "Lorem ipsum dolor sit amet",
    	"summary": "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
    	"image": "http://s3.amazonaws.com/rss.cloudspace.com/feed_items/255/image.png",
    	"url": "http://engadget.com/articles/lorem.html",
    	"created_at": "2014-03-05T22:32:32+00:00",
    	"updated_at": "2014-03-05T22:32:32+00:00",
    	"published_at": "2014-03-04T19:52:13+00:00",
    }

---
## Routes

##### `GET /v2/feeds/default`
<small>Returns an array of curated feed entities. This will only be used on the first run of the app immediately after installation</small>

__Parameters__

- This route takes no parameters

__Returns__


    {
        feeds: [...]
    }

- HTTP 200 and an array of feed entities
  
---
##### `GET /v2/feeds/search`
<small>Searches through available feeds based on supplied parameters.</small>

__Parameters__

- _Required_ `name` - used to find a partial or complete match to a feed's name attribute

__Returns__

    {
        feeds: [...]
    }

- HTTP 200 and an array of feed entities if any are found
- HTTP 404 if no matches are found

---
##### `POST /v2/feeds/create`
<small>Submits a feed to the API, which then attempts to parse it and return an array containing a single feed object.</small>

__Parameters__

- _Required_ - an `url` parameter, the address of the RSS feed

__Returns__


    {
        feeds: [...]
    }

- HTTP 201 and the resource created if the feed is successfully parsed and created
- HTTP 422 (Unprocessable Entity) if `url` cannot be parsed as a feed

##### `GET /v2/feed_items`
<small>Returns (up to) the most recent 10 `feed_item` entities (created since the date specified) for each feed specified.</small>

__Parameters__

- _Required_ `feed_ids` - an array of integers representing the feeds requested
- _Optional_ `since` - a lower bound for the age of `feed_item`s to be returned

__Returns__

    {
        feeds_items: [...],
        bad_feed_ids: [...]
    }

- HTTP 200 and an array of `feed_items` if all feeds are found
- HTTP 206 and arrays of both `feed_items` and `bad_feed_ids` if some but not all feeds were found
- HTTP 404 if none of the feed_ids provided were found
